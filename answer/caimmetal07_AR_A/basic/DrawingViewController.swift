//
// DrawingViewController.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit
import ARKit

// The max number anchors our uniform buffer will hold
let kMaxAnchorInstanceCount: Int = 64
// バッファID番号
let ID_VERTEX:Int = 0
let ID_SHARED_UNIFORMS:Int = 1
let ID_UNIFORMS:Int = 2

struct SharedUniforms : CAIMBufferAllocatable {
    var projectionMatrix:Matrix4x4 = .identity
    var viewMatrix:Matrix4x4 = .identity
    // Lighting Properties
    var ambientLightColor:Float3 = .zero
    var directionalLightDirection:Float3 = .zero
    var directionalLightColor:Float3 = .zero
    var materialShininess:Float = 0.0
}

struct InstanceUniforms : CAIMBufferAllocatable {
    var model:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController, ARSessionDelegate
{
    private var render_3d:CAIMMetalRenderer?
    
    private var uniforms:[InstanceUniforms] = [InstanceUniforms].init(repeating: InstanceUniforms(), count: 64)
    private var mesh = CAIMMetalMesh(with:"realship.obj", at:ID_VERTEX)
    private var texture:CAIMMetalTexture = CAIMMetalTexture(with:"shipDiffuse.png")
    private var instanceCount: Int = 0
    
    private func setup3D() {
        // シェーダを指定してパイプラインレンダラの作成
        render_3d = CAIMMetalRenderer(vertname:"vert3dAR", fragname:"frag3dAR")
        // 頂点ディスクリプタの設定
        render_3d?.vertexDesc = CAIMMetalMesh.vertexDesc(at: ID_VERTEX)
        // カリングの設定
        render_3d?.culling = .front
    }
    
    // 3D情報の描画
    private func draw3D(on metalView:CAIMMetalView) {
        guard instanceCount > 0 else { return }
        
        // パイプラインレンダラで描画開始
        render_3d?.beginDrawing(on: metalView)
        // テクスチャの読み込みと設定・サンプラの設定
        render_3d?.linkFragmentSampler(CAIMMetalSampler.default, at: 0)
        render_3d?.linkFragmentTexture(texture.metalTexture, at: 0)
        
        // 使用するバッファと番号をリンク(頂点シェーダ)
        render_3d?.link(mesh.metalVertexBuffer, to:.vertex, at: ID_VERTEX)
        render_3d?.link(sharedUniforms.metalBuffer, to:.vertex, at: ID_SHARED_UNIFORMS)
        // 使用するバッファと番号をリンク(フラグメントシェーダ)
        render_3d?.link(sharedUniforms.metalBuffer, to:.fragment, at: ID_SHARED_UNIFORMS)
        
        for i in 0 ..< instanceCount {
            render_3d?.link(uniforms[i].metalBuffer, to:.vertex, at:ID_UNIFORMS)
            // GPU描画実行
            render_3d?.draw(mesh)
        }
    }
    
    //////
    var ar_session:ARSession?
    var ar_capture:CAIMARCapture?
    var sharedUniforms:SharedUniforms = SharedUniforms()
    
    func setupAR() {
        ar_session = ARSession()
        ar_session?.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        ar_session?.run(configuration)
        
        ar_capture = CAIMARCapture(session: ar_session!)
    }
    
    func updateSharedUniforms(frame: ARFrame) {
        sharedUniforms.viewMatrix = frame.camera.viewMatrix(for: .portrait)
        sharedUniforms.projectionMatrix = frame.camera.projectionMatrix(for: .portrait, viewportSize: CAIM.screenPoint, zNear: 0.001, zFar: 1000)
        
        var ambientIntensity: Float = 1.0
        if let lightEstimate = frame.lightEstimate {
            ambientIntensity = Float(lightEstimate.ambientIntensity) / 1000.0
        }
        
        sharedUniforms.ambientLightColor = Float3(0.5, 0.5, 0.5) * ambientIntensity
        sharedUniforms.directionalLightDirection = simd_normalize(Float3(0.0, 0.0, -1.0))
        sharedUniforms.directionalLightColor = Float3(0.6, 0.6, 0.6) * ambientIntensity
        sharedUniforms.materialShininess = 10
    }
    
    func updateAnchors(frame: ARFrame) {
        // Update the anchor uniform buffer with transforms of the current frame's anchors
        instanceCount = min(frame.anchors.count, kMaxAnchorInstanceCount)
        
        var anchorOffset: Int = 0
        if instanceCount == kMaxAnchorInstanceCount {
            anchorOffset = max(frame.anchors.count - kMaxAnchorInstanceCount, 0)
        }
        
        for index in 0 ..< instanceCount {
            let anchor = frame.anchors[index + anchorOffset]
            
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = Matrix4x4.identity
            coordinateSpaceTransform.Z.z = -1.0
            
            uniforms[index].model = anchor.transform * coordinateSpaceTransform
                                    * Matrix4x4.rotateZ(byAngle: 90.toRadian)
                                    * Matrix4x4.rotateY(byAngle: 180.toRadian)
        }
    }
    
    /////////////////
    // ビューコントローラから去る時の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ar_session?.pause()
    }
    
    // 準備関数
    override func setup() {
        setupAR()
        setup3D()
    }
    
    // 繰り返し処理関数
    override func update(metalView:CAIMMetalView) {
        // ARフレームの取得
        guard let currentFrame = ar_session?.currentFrame else { return }
    
        // カメラキャプチャの更新と設定、描画
        ar_capture?.checkTextures(viewController: self)
        ar_capture?.updateCapturedImageTextures(frame: currentFrame)
        ar_capture?.updateImagePlane(frame: currentFrame)
        ar_capture?.drawCapturedImage(on: metalView)
  
        // ARKitからの共通の変換行列を更新
        updateSharedUniforms(frame: currentFrame)
        // 各ARアンカーの変換行列を更新
        updateAnchors(frame: currentFrame)

        // 3Dモデルの描画
        draw3D(on:metalView)
    }
    
    override func touchPressed() {
        // Create anchor using the camera's current position
        if let currentFrame = ar_session?.currentFrame {
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = Matrix4x4.identity
            translation.W.z = -1.0
            // 飛行機の大きさを50%にする
            let scale = Matrix4x4.scale(0.5, 0.5, 0.5)
            // カメラによる変換行列に移動 + 拡大縮小の行列をかける
            let transform = currentFrame.camera.transform * translation * scale
            
            // Add a new anchor to the session
            ar_session?.add(anchor: ARAnchor(transform: transform))
        }
    }
}

