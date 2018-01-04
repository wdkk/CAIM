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

// 1頂点情報の構造体
struct Vertex : CAIMVertexFormatter {
    var pos:Float3 = Float3()
    var uv:Float2 = Float2()
    var rgba:Float4 = Float4()
    
    static func vertexDescriptor(at idx:Int) -> MTLVertexDescriptor {
        return makeVertexDescriptor(at: idx, formats: [.float3, .float2, .float4])
    }
}

struct PlaneUniforms : CAIMBufferAllocatable {
    var model:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController, ARSessionDelegate
{
    private var render_3d:CAIMMetalRenderer?
    
    private var uniforms:[InstanceUniforms] = [InstanceUniforms](repeating: InstanceUniforms(), count: 64)
    private var mesh = CAIMMetalMesh(with:"bunny.obj", at:ID_VERTEX, addNormal:true, normalThreshold:0.0)
    private var instance_count: Int = 0
  
    private var render_plane:CAIMMetalRenderer?
    private var p_uniforms:[PlaneUniforms] = [PlaneUniforms](repeating: PlaneUniforms(), count: 1)
    private var planes = CAIMQuadrangles<Vertex>(count: 1)
    private var plane_count: Int = 0
    
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
        guard instance_count > 0 else { return }
        // パイプラインレンダラで描画開始
        render_3d?.beginDrawing(on: metalView)
        // 使用するバッファと番号をリンク(頂点シェーダ)
        render_3d?.link(mesh.metalVertexBuffer, to:.vertex, at: ID_VERTEX)
        render_3d?.link(sharedUniforms.metalBuffer, to:.vertex, at: ID_SHARED_UNIFORMS)
        // 使用するバッファと番号をリンク(フラグメントシェーダ)
        render_3d?.link(sharedUniforms.metalBuffer, to:.fragment, at: ID_SHARED_UNIFORMS)
        
        for i in 0 ..< instance_count {
            render_3d?.link(uniforms[i].metalBuffer, to:.vertex, at:ID_UNIFORMS)
            // GPU描画実行
            render_3d?.draw(mesh)
        }
    }
    
    private func setupPlane() {
        render_plane = CAIMMetalRenderer(vertname: "vert3d", fragname: "fragStandard")
        // 頂点ディスクリプタの設定
        render_plane?.vertexDesc = Vertex.vertexDescriptor(at: 0)
        // カリングの設定
        render_plane?.culling = .none
        render_plane?.blendType = .alphaBlend
    }
    
    private func drawPlane(on metalView:CAIMMetalView) {
        guard plane_count > 0 else { return }
        // パイプラインレンダラで描画開始
        render_plane?.beginDrawing(on: metalView)

        // 使用するバッファと番号をリンク(頂点シェーダ)
        render_plane?.link(planes.metalBuffer, to:.vertex, at: ID_VERTEX)
        render_plane?.link(sharedUniforms.metalBuffer, to:.vertex, at: ID_SHARED_UNIFORMS)
        // 使用するバッファと番号をリンク(フラグメントシェーダ)
        render_plane?.link(sharedUniforms.metalBuffer, to:.fragment, at: ID_SHARED_UNIFORMS)
        
        // 最初の1点のみ利用
        render_plane?.link(p_uniforms[0].metalBuffer, to:.vertex, at:ID_UNIFORMS)
        render_plane?.draw(planes)
    }
    
    //////
    var ar_session:ARSession?
    var ar_capture:CAIMARCapture?
    var sharedUniforms:SharedUniforms = SharedUniforms()
    
    func setupAR() {
        ar_session = ARSession()
        ar_session?.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
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
        var inst_anchors:[ARAnchor] = []
        var plane_anchors:[ARPlaneAnchor] = []
        for anchor in frame.anchors {
            if !(anchor is ARPlaneAnchor) { inst_anchors.append(anchor) }
            else { plane_anchors.append(anchor as! ARPlaneAnchor) }
        }
        instance_count = inst_anchors.count
        plane_count = plane_anchors.count
        
        for idx in 0 ..< inst_anchors.count {
            let anchor = inst_anchors[idx]
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = Matrix4x4.identity
            coordinateSpaceTransform.Z.z = -1.0
            
            uniforms[idx].model = anchor.transform * coordinateSpaceTransform * Matrix4x4.rotateZ(byAngle: 90.toRadian) * Matrix4x4.rotateY(byAngle: 180.toRadian)
        }
        
        for idx in 0 ..< plane_anchors.count {
            let p_anchor = plane_anchors[idx]
            
            let co = p_anchor.center
            let ext = p_anchor.extent
            print(ext)
            
            let ext_x = ext.x / 2.0
            let ext_z = ext.z / 2.0
            // 四角形メッシュi個目の頂点0
            planes[idx][0].pos  = Float3(co.x - ext_x, co.y, co.z - ext_z)
            planes[idx][0].uv   = Float2(-1.0, -1.0)
            planes[idx][0].rgba = Float4(0.0, 0.0, 1.0, 0.75)
            // 四角形メッシュi個目の頂点1
            planes[idx][1].pos  = Float3(co.x + ext_x, co.y, co.z - ext_z)
            planes[idx][1].uv   = Float2(1.0, -1.0)
            planes[idx][1].rgba = Float4(0.0, 0.0, 1.0, 0.75)
            // 四角形メッシュi個目の頂点2
            planes[idx][2].pos  = Float3(co.x - ext_x, co.y, co.z + ext_z)
            planes[idx][2].uv   = Float2(-1.0, 1.0)
            planes[idx][2].rgba = Float4(0.0, 0.0, 1.0, 0.75)
            // 四角形メッシュi個目の頂点3
            planes[idx][3].pos  = Float3(co.x + ext_x, co.y, co.z + ext_z)
            planes[idx][3].uv   = Float2(1.0, 1.0)
            planes[idx][3].rgba = Float4(0.0, 0.0, 1.0, 0.75)
            
            p_uniforms[idx].model = p_anchor.transform
            
            // 1点のみつかったら終わり
            break
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
        setupPlane()
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
        
        // ARKitで検出したプレーンを描画
        drawPlane(on: metalView)
        // 3Dモデルの描画
        draw3D(on: metalView)
    }
    
    override func touchPressed() {
        // Create anchor using the camera's current position
        if let currentFrame = ar_session?.currentFrame {
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = Matrix4x4.identity
            translation.W.z = -0.2
            // 飛行機の大きさを50%にする
            let scale = Matrix4x4.scale(0.05, 0.05, 0.05)
            // カメラによる変換行列に移動 + 拡大縮小の行列をかける
            let transform = currentFrame.camera.transform * translation * scale
            
            // Add a new anchor to the session
            ar_session?.add(anchor: ARAnchor(transform: transform))
        }
    }
}

