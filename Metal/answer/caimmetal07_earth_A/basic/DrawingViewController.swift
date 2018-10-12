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

// 1頂点情報の構造体(VertexDescriptorを使うため、CAIMMetalVertexFormatterプロトコルを使用する)
struct Vertex : CAIMMetalVertexFormatter {
    var pos:Float2 = Float2()
    var rgba:Float4 = Float4()

    // CAIMMetalVertexFormatterで作成を義務付けられる関数: 構造体の型と同じ型をformats: [...]のなかで指定していく
    static func vertexDescriptor(at idx: Int) -> MTLVertexDescriptor {
        return makeVertexDescriptor(at: idx, formats: [.float2, .float4])
    }
}

struct Uniform : CAIMMetalBufferAllocatable {
    var modelMatrix:Matrix4x4 = .identity
}

struct SharedUniform : CAIMMetalBufferAllocatable {
    var viewMatrix:Matrix4x4 = .identity
    var projectionMatrix:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?       // Metalビュー
    
    private var pipeline_3d:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    private var shared_uniform = SharedUniform()
    private var uniform = Uniform()
    private var mesh = CAIMMetalMesh.sphere(at: 0)
    private var texture:CAIMMetalTexture = CAIMMetalTexture(with:"earth.jpg")
    
    // 準備関数
    override func setup() {
        super.setup()
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        metal_view?.clearColor = CAIMColor(R: 0.88, G: 0.88, B: 0.88, A: 1.0)
        self.view.addSubview( metal_view! )
        
        // 3D描画の準備
        setup3D()
    }
    
    private func setup3D() {
        // シェーダを指定してパイプライン作成
        pipeline_3d.vertexShader = CAIMMetalShader( "vert3d" )
        pipeline_3d.fragmentShader = CAIMMetalShader( "frag3d" )
        // 頂点をどのように使うのかを設定
        pipeline_3d.vertexDesc = CAIMMetalMesh.vertexDesc( at: 0 )
        // カリングの設定
        pipeline_3d.blendType = .alphaBlend
    }
    
    // 繰り返し処理関数
    var move:Float = 0.0
    // 繰り返し処理関数
    override func update() {
        super.update()
        
        let aspect = Float( metal_view!.pixelBounds.width / metal_view!.pixelBounds.height )
        
        let trans  = Matrix4x4.translate(0.0, 0.0, 0.0)
        let rotate_y = Matrix4x4.rotateY(byAngle: move.toRadian)
        move += 0.5
        
        uniform.modelMatrix = trans * rotate_y
        
        shared_uniform.viewMatrix = Matrix4x4.translate(0.0, 0.0, -10.0)
        shared_uniform.projectionMatrix = Matrix4x4.perspective(aspect: aspect, fieldOfViewY: 60.0, near: 0.01, far: 1000.0)
        
        // MetalViewのレンダリングを実行
        metal_view?.execute( renderFunc: self.render )
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // エンコーダにカリングの設定
        encoder.setCullMode( .front )
        // エンコーダにデプスの設定
        let depth_desc = MTLDepthStencilDescriptor()
        // デプスを有効にする
        depth_desc.depthCompareFunction = .less
        depth_desc.isDepthWriteEnabled = true
        encoder.setDepthStencilDescriptor( depth_desc )
        
        // 準備したpipeline_3dを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_3d ) {
            // 頂点シェーダのバッファ1番に行列uniformをセット
            $0.setVertexBuffer( uniform, at: 1 )
            // 頂点シェーダのバッファ2番にユニフォーム行列shared_uniformをセット
            $0.setVertexBuffer( shared_uniform, at: 2 )
            // フラグメントシェーダのサンプラ0番にデフォルトのサンプラを設定
            $0.setFragmentSamplerState( CAIMMetalSampler.default, index: 0 )
            // フラグメントシェーダのテクスチャ0番にtextureを設定
            $0.setFragmentTexture( texture.metalTexture, index: 0 )
            // モデルデータ群の描画実行(※バッファ0番に頂点情報が自動セットされる)
            $0.drawShape( mesh )
        }
    }
}
