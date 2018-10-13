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

import simd

// 1頂点情報の構造体
struct Vertex {
    var pos:Float4 = Float4()
    var rgba:Float4 = Float4()
    var tex_coord:Float2 = Float2()
}

struct Uniforms : CAIMMetalBufferAllocatable {
    var view:Matrix4x4 = .identity
    var model:Matrix4x4 = .identity
    var projection:Matrix4x4 = .identity
}

class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?       // Metalビュー
    
    private var pipeline_3d:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    private var uniforms:Uniforms = Uniforms()   // 行列群
    private let texture:CAIMMetalTexture = CAIMMetalTexture(with:"LilyNoAlpha.png")
    private var cubes = CAIMCubes<Vertex>(count: 1)
    
    // 準備関数
    override func setup() {
        super.setup()
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        let aspect = Float( metal_view!.pixelBounds.width / metal_view!.pixelBounds.height )
        
        // ビュー行列(平行移動)
        uniforms.view = Matrix4x4.translate(0, 0, -10)
        // モデル行列(回転)
        uniforms.model = Matrix4x4.rotate(axis: Float4(1.0, 1.0, 0.0, 1.0), byAngle: -30.toRadian)
        // 透視投影行列
        uniforms.projection = Matrix4x4.perspective(aspect: aspect, fieldOfViewY: 60.0, near: 0.01, far: 100.0)
        
        // 3D描画の準備
        setup3D()
    }
    
    private func setup3D() {
        // シェーダを指定してパイプライン作成
        pipeline_3d.vertexShader = CAIMMetalShader( "vertPers" )
        pipeline_3d.fragmentShader = CAIMMetalShader( "fragStandard" )
        
        let red   = CAIMColor(1, 0, 0, 1).float4
        let green = CAIMColor(0, 1, 0, 1).float4
        let blue  = CAIMColor(0, 0, 1, 1).float4
        let gray  = CAIMColor(0.5, 0.5, 0.5, 1.0).float4
        
        cubes.set(idx: 0, pos: Float3(0, 0, 0), size: 2.0) { (idx:Int, info:CAIMPanelCubeParam) -> Vertex in
            var vi       = Vertex()
            vi.pos       = info.pos
            vi.tex_coord = info.uv
            switch(info.side) {
            case .front: vi.rgba = red
            case .left:  vi.rgba = green
            case .right: vi.rgba = blue
            default: vi.rgba = gray
            }
            return vi
        }
    }
    
    // 繰り返し処理関数
    override func update() {
        super.update()
        // MetalViewのレンダリングを実行
        metal_view?.execute( renderFunc: self.render )
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // エンコーダにカリングの設定
        encoder.setCullMode( .back )
        // エンコーダにデプスの設定
        let depth_desc = MTLDepthStencilDescriptor()
        // デプスを有効にする
        depth_desc.depthCompareFunction = .less
        depth_desc.isDepthWriteEnabled = true
        encoder.setDepthStencilDescriptor( depth_desc )
        
        // 準備したpipeline_3dを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_3d ) {
            // 頂点シェーダのバッファ1番に行列uniformをセット
            $0.setVertexBuffer( uniforms, index: 1 )
            // フラグメントシェーダのサンプラ0番にデフォルトのサンプラを設定
            $0.setFragmentSamplerState( CAIMMetalSampler.default, index: 0 )
            // フラグメントシェーダのテクスチャ0番にtextureを設定
            $0.setFragmentTexture( texture.metalTexture, index: 0 )
            // モデルデータ群の頂点をバッファ0番にセットして描画を実行
            $0.drawShape( cubes, index: 0 )
        }
    }
}

