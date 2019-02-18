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
// バッファID番号
let ID_VERTEX:Int = 0
let ID_SHARED_UNIFORMS:Int = 1
let ID_UNIFORMS:Int = 2

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

class DrawingViewController : CAIMViewController, ARSessionDelegate
{
    private var metal_view:CAIMMetalView?       // Metalビュー
    private var pipeline_3d:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    
    private var uniforms:[InstanceUniforms] = [InstanceUniforms].init(repeating: InstanceUniforms(), count: 64)
    private var mesh = CAIMMetalMesh(with:"realship.obj", at:ID_VERTEX)
    private var texture:CAIMMetalTexture = CAIMMetalTexture(with:"shipDiffuse.png")
    private var instance_count: Int = 0
    
    // 準備関数
    override func setup() {
        super.setup()
        
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        metal_view?.touchPressed = self.touchPressed
        
        setupAR()
        setup3D()
    }
    
    // ビューコントローラから去る時の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ar_session?.pause()
    }
    
    private func setup3D() {
        // シェーダを指定してパイプラインレンダラの作成
        pipeline_3d.vertexShader = CAIMMetalShader( "vert3dAR" )
        pipeline_3d.fragmentShader = CAIMMetalShader( "frag3dAR" )
        // 頂点ディスクリプタの設定
        pipeline_3d.vertexDesc = CAIMMetalMesh.vertexDesc( at:0 )
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
        // Update the anchor uniform buffer with transforms of the current frame's anchors
        instance_count = min(frame.anchors.count, kMaxAnchorinstance_count)
        
        var anchorOffset: Int = 0
        if instance_count == kMaxAnchorinstance_count {
            anchorOffset = max(frame.anchors.count - kMaxAnchorinstance_count, 0)
        }
        
        for index in 0 ..< instance_count {
            let anchor = frame.anchors[index + anchorOffset]
            
            // Flip Z axis to convert geometry from right handed to left handed
            var coordinateSpaceTransform = Matrix4x4.identity
            coordinateSpaceTransform.Z.z = -1.0
            
            uniforms[index].model = anchor.transform * coordinateSpaceTransform
                                    * Matrix4x4.rotateZ(byAngle: 90.toRadian)
                                    * Matrix4x4.rotateY(byAngle: 180.toRadian)
        }
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
        
        encoder.setCullMode( .front )
        // エンコーダにデプスの設定
        let depth_desc2 = MTLDepthStencilDescriptor()
        // デプスを有効にする
        depth_desc2.depthCompareFunction = .less
        depth_desc2.isDepthWriteEnabled = true
        encoder.setDepthStencilDescriptor( depth_desc2 )
        
        // 準備したpipeline_3dを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_3d ) {
            guard instance_count > 0 else { return }
            
            $0.setFragmentSamplerState( CAIMMetalSampler.default, index:0 )
            $0.setFragmentTexture( texture.metalTexture, index:0 )
            $0.setFragmentBuffer( sharedUniforms, index: 1 )
            
            $0.setVertexBuffer( sharedUniforms, index: 1 )
            
            for i in 0 ..< instance_count {
                $0.setVertexBuffer( uniforms[i], index: 2 )
                $0.drawShape( mesh, index:0 )
            }
        }
    }
    
    func touchPressed() {
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

