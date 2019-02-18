//
// DrawingViewController.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import ARKit

// The max number anchors our uniform buffer will hold
let kMaxAnchorinstance_count: Int = 64

struct SharedUniforms : CAIMMetalBufferAllocatable {
    var projectionMatrix:Matrix4x4 = .identity
    var viewMatrix:Matrix4x4 = .identity
    // Lighting Properties
    var ambientLightColor:Float3 = .zero
    var directionalLightDirection:Float3 = .zero
    var directionalLightColor:Float3 = .zero
    var materialShininess:Float = 0.0
}

struct InstanceUniforms : CAIMMetalBufferAllocatable {
    var model:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController, ARSessionDelegate
{
    private var metal_view:CAIMMetalView?       // Metalビュー
    private var pipeline_3d:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    
    private var uniforms:[InstanceUniforms] = [InstanceUniforms].init(repeating: InstanceUniforms(), count: 64)
    private var mesh = CAIMMetalMesh(with:"realship.obj", at:0)
    private var texture:CAIMMetalTexture = CAIMMetalTexture(with:"shipDiffuse.png")
    
    /////////////////
    // ビューコントローラから去る時の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ar_session?.pause()
    }
    
    // 準備関数
    override func setup() {
        super.setup()
        
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        setupAR()
        setup3D()
    }
    
    private func setup3D() {

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
        sharedUniforms.projectionMatrix = frame.camera.projectionMatrix(for: .portrait, viewportSize: metal_view!.bounds.size, zNear: 0.001, zFar: 1000)
        
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

    }
    
    // 繰り返し処理関数
    override func update() {
        // ARフレームの取得
        guard let currentFrame = ar_session?.currentFrame else { return }
        
        // カメラキャプチャの更新と設定、描画
        ar_capture?.updateCapturedImageTextures(frame: currentFrame)
        ar_capture?.updateImagePlane(frame: currentFrame)
        // ARKitからの共通の変換行列を更新
        updateSharedUniforms(frame: currentFrame)
        // 各ARアンカーの変換行列を更新
        updateAnchors(frame: currentFrame)
        
        // MetalViewのレンダリングを実行
        metal_view?.execute( renderFunc: self.render )
        
        // カメラデータのクリア
        ar_capture?.clearTextures()
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // ar_captureにエンコーダを渡して描画してもらう
        ar_capture?.drawCapturedImage( encoder: encoder )
    }
}

