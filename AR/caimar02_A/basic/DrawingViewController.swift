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

// 共有の行列・ベクトル情報
struct SharedUniforms : CAIMMetalBufferAllocatable {
    var projectionMatrix:Matrix4x4 = .identity
    var viewMatrix:Matrix4x4 = .identity
    // Lighting Properties
    var ambientLightColor:Float3 = .zero
    var directionalLightDirection:Float3 = .zero
    var directionalLightColor:Float3 = .zero
    var materialShininess:Float = 0.0
}

// 平面向け行列
struct PlaneUniforms : CAIMMetalBufferAllocatable {
    var model:Matrix4x4 = .identity
}

// オブジェクト向け行列
struct InstanceUniforms : CAIMMetalBufferAllocatable {
    var model:Matrix4x4 = .identity
}

// 1頂点情報の構造体
struct Vertex : CAIMMetalVertexFormatter {
    var pos:Float3 = Float3()
    var uv:Float2 = Float2()
    var rgba:Float4 = Float4()
    
    static func vertexDescriptor(at idx:Int) -> MTLVertexDescriptor {
        return makeVertexDescriptor(at: idx, formats: [.float3, .float2, .float4])
    }
}

// CAIM-Metalのビューコントローラ
class DrawingViewController : CAIMViewController, ARSessionDelegate
{
    private var metal_view:CAIMMetalView?       // Metalビュー

    
    // ARKitセッション
    var ar_session:ARSession?
    // ARKit背景データ
    var ar_capture:CAIMARCapture?
    // 共有行列・ベクトルデータ
    var sharedUniforms:SharedUniforms = SharedUniforms()
    
    // ARKitで認識した平面データ
    private var pipeline_plane:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    private var p_uniforms:[PlaneUniforms] = [PlaneUniforms](repeating: PlaneUniforms(), count: 1)
    private var planes = CAIMMetalQuadrangles<Vertex>(count: 1)
    private var plane_count: Int = 0
 
    // AR平面に表示する実体データ(うさぎ)
    private var pipeline_3d:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    private var uniforms:[InstanceUniforms] = [InstanceUniforms](repeating: InstanceUniforms(), count: 1)
    private var mesh = CAIMMetalMesh(with:"bunny.obj", at:0, addNormal:true, normalThreshold:0.0)
    private var instance_count: Int = 0
    
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
        setupARCapture()
        setup3D()
        setupPlane()
    }
    
    private func setupPlane() {
        pipeline_plane.vertexShader = CAIMMetalShader( "vertPlane" )
        pipeline_plane.fragmentShader = CAIMMetalShader( "fragPlane" )
        // 頂点ディスクリプタの設定
        pipeline_plane.vertexDesc = Vertex.vertexDescriptor(at: 0)
    }
    
    private func setup3D() {
        // シェーダを指定してパイプラインレンダラの作成
        pipeline_3d.vertexShader = CAIMMetalShader( "vert3DObject" )
        pipeline_3d.fragmentShader = CAIMMetalShader( "frag3DObject" )
        // 頂点ディスクリプタの設定
        pipeline_3d.vertexDesc = CAIMMetalMesh.vertexDesc(at: 0)
        // アルファブレンドを無効
        pipeline_3d.blendType = .none
    }
    
    // ARKitの初期化
    func setupAR() {
        ar_session = ARSession()
        ar_session?.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        ar_session?.run(configuration)
    }
    
    // AR背景キャプチャの初期化
    func setupARCapture() {
        ar_capture = CAIMARCapture(session: ar_session!)
    }
    
    // 毎フレームのARの情報から共有行列・ベクトル情報を更新
    func updateSharedUniforms(frame: ARFrame) {
        sharedUniforms.viewMatrix = frame.camera.viewMatrix(for: .portrait)
        sharedUniforms.projectionMatrix = frame.camera.projectionMatrix(for: .portrait, viewportSize: metal_view!.bounds.size, zNear: 0.001, zFar: 1000)
        
        var ambientIntensity: Float = 1.0
        if let lightEstimate = frame.lightEstimate {
            ambientIntensity = Float(lightEstimate.ambientIntensity) / 1000.0
        }
        
        sharedUniforms.ambientLightColor = Float3(1.0, 1.0, 1.0) * ambientIntensity
        sharedUniforms.directionalLightDirection = simd_normalize(Float3(0.0, 0.0, 1.0))
        sharedUniforms.directionalLightColor = Float3(0.6, 0.6, 0.6) * ambientIntensity
        sharedUniforms.materialShininess = 30
    }
    
    // ARの毎フレームの更新
    func updateAnchors(frame: ARFrame) {
        var inst_anchors:[ARAnchor] = []
        var plane_anchors:[ARPlaneAnchor] = []
        // 検出したARアンカーをアンカーと平面アンカーに分別する
        for anchor in frame.anchors {
            if !(anchor is ARPlaneAnchor) { inst_anchors.append(anchor) }
            else { plane_anchors.append(anchor as! ARPlaneAnchor) }
        }
        plane_count = plane_anchors.count
        instance_count = plane_anchors.count
        
        // 平面アンカーに合わせて平面の頂点情報・その上のオブジェクトの情報を更新（ループを使っているが一番目のアンカーのみ設定したら終わり）
        for idx in 0 ..< plane_anchors.count {
            let p_anchor = plane_anchors[idx]
            
            let co = p_anchor.center
            let ext = p_anchor.extent
            
            let ext_x = ext.x / 2.0
            let ext_z = ext.z / 2.0
            // 四角形メッシュi個目の頂点0
            planes[idx].p1 = Vertex( pos:Float3(co.x - ext_x, co.y, co.z - ext_z), uv:Float2(-1.0, -1.0), rgba:Float4(0.0, 0.0, 1.0, 0.75) )
            // 四角形メッシュi個目の頂点1
            planes[idx].p2 = Vertex( pos:Float3(co.x + ext_x, co.y, co.z - ext_z), uv:Float2(1.0, -1.0), rgba:Float4(0.0, 0.0, 1.0, 0.75) )
            // 四角形メッシュi個目の頂点2
            planes[idx].p3 = Vertex( pos:Float3(co.x - ext_x, co.y, co.z + ext_z), uv:Float2(-1.0, 1.0), rgba:Float4(0.0, 0.0, 1.0, 0.75) )
            // 四角形メッシュi個目の頂点3
            planes[idx].p4 = Vertex( pos:Float3(co.x + ext_x, co.y, co.z + ext_z), uv:Float2(1.0, 1.0), rgba:Float4(0.0, 0.0, 1.0, 0.75) )
            
            // 平面用モデル行列の更新
            p_uniforms[idx].model = p_anchor.transform
            
            //// 平面に乗せるオブジェクト（うさぎ）の情報更新
            var coord = Matrix4x4.identity
            coord.Z.z = -1.0
            let scale = Matrix4x4.scale(0.05, 0.05, 0.05)
            let trans = Matrix4x4.translate(0.0, 1.0, 0.0)
            let rotate = Matrix4x4.rotateY(byAngle: 180.0)
            uniforms[idx].model = p_uniforms[idx].model * coord * scale * trans * rotate
            
            // 1点のみ、設定が終わったら終わり
            break
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

        encoder.setCullMode( .none )
        // エンコーダにデプスの設定
        let depth_desc = MTLDepthStencilDescriptor()
        // デプスを有効にする
        depth_desc.depthCompareFunction = .always
        depth_desc.isDepthWriteEnabled = false
        encoder.setDepthStencilDescriptor( depth_desc )
        
        // 準備したpipeline_planeを使って、描画を開始(板)
        encoder.use( pipeline_plane ) {
            guard plane_count > 0 else { return }
            
            $0.setFragmentBuffer( sharedUniforms, index: 1 )
            
            $0.setVertexBuffer( sharedUniforms, index: 1 )
            $0.setVertexBuffer( p_uniforms[0], index: 2 )
            $0.drawShape( planes, index:0 )
        }
        
        encoder.setCullMode( .front )
        // エンコーダにデプスの設定
        let depth_desc2 = MTLDepthStencilDescriptor()
        // デプスを有効にする
        depth_desc2.depthCompareFunction = .less
        depth_desc2.isDepthWriteEnabled = true
        encoder.setDepthStencilDescriptor( depth_desc2 )
        
        // 準備したpipeline_3dを使って、描画を開始(うさぎ)
        encoder.use( pipeline_3d ) {
            guard instance_count > 0 else { return }
            
            $0.setFragmentBuffer( sharedUniforms, index: 1 )
            
            $0.setVertexBuffer( sharedUniforms, index: 1 )
            
            for i in 0 ..< instance_count {
                $0.setVertexBuffer( uniforms[i], index: 2 )
                $0.drawShape( mesh, index:0 )
            }
        }
    }
}
