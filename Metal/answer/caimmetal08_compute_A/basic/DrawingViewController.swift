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

import simd

// 1頂点情報の構造体
struct Vertex {
    var pos:Float2 = Float2()
    var rgba:Float4 = Float4()
}

class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?               // Metalビュー
    private var pipeline = CAIMMetalRenderPipeline()    // Metalパイプライン
    private var pl_compute = CAIMMetalComputePipeline()
    private var mat:Matrix4x4 = .identity                              // 変換行列
    private var tris = CAIMMetalTriangles<Vertex>( count:100 )     // ３頂点メッシュ群
    private var tris2 = CAIMMetalTriangles<Vertex>( count:100, type:.shared )   // ３頂点メッシュ群
    private var quads = CAIMMetalQuadrangles<Vertex>( count:25 )   // ４頂点メッシュ群
    
    private var vertice = [Vertex]()
    private var vertice_buffer:MTLBuffer?
    
    override func setup() {
        super.setup()
        
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        // パイプラインで使用する頂点シェーダを設定
        pipeline.vertexShader = CAIMMetalShader( "vert2d" )
        // パイプラインで使用するフラグメントシェーダを設定
        pipeline.fragmentShader = CAIMMetalShader( "fragStandard" )
        
        pl_compute.computeShader = CAIMMetalShader( "kernelTest" )
        
        // 形状データを作成する関数を呼ぶ
        makeShapes()
    
        // MetalViewのレンダリングを実行
        metal_view?.execute(
            preRenderFunc: { command_buffer in
                CAIMMetalComputer.beginCompute( commandBuffer: command_buffer, compute: self.compute )
            },
            renderFunc: self.render )
    }
    
    // 形状データを作成する関数
    func makeShapes() {
        // ピクセル座標変換行列をmetal_viewのサイズから作成
        mat = Matrix4x4.pixelProjection( metal_view!.pixelBounds.size )
        
        // 三角形の個数分、頂点情報を指定する
        for i:Int in 0 ..< tris.count {
            let x = Float(i % 10)
            let y = Float(i / 10)
            let c = Float(x+y) / 20.0
            
            // 三角形メッシュi個目の頂点p1
            tris[i].p1 = Vertex( pos:Float2( (x+0.5) * 60.0, y * 60.0 ), rgba:Float4( c, 0.0, 0.0, 1.0 ) )
            // 三角形メッシュi個目の頂点p2
            tris[i].p2 = Vertex( pos:Float2( (x+1.0) * 60.0, (y+1) * 60.0 ), rgba:Float4( c, 0.0, 0.0, 1.0 ) )
            // 三角形メッシュi個目の頂点p3
            tris[i].p3 = Vertex( pos:Float2( x * 60.0, (y+1) * 60.0 ), rgba:Float4( c, 0.0, 0.0, 1.0 ) )
        }
        
        // 矩形の個数分、頂点情報を指定する
        for i:Int in 0 ..< quads.count {
            let x = Float(i % 5)
            let y = Float(i / 5)
            let c = Float((8.0 - (x+y)) / 8.0)
            
            let sz  = Float(100) // 四角形のサイズ
            let mgn = Float(20)  // 隙間
            let xx  = Float(40 + x * (sz + mgn))
            let yy  = Float(40 + y * (sz + mgn))
            
            // 四角形メッシュi個目の頂点1
            quads[i].p1 = Vertex( pos:Float2( xx, yy ), rgba:Float4( 0.0, 0.0, 0.0, 0.75 ) )
            // 四角形メッシュi個目の頂点2
            quads[i].p2 = Vertex( pos:Float2( xx+sz, yy ), rgba:Float4( c, 0.0, c / 2.0, 0.75 ) )
            // 四角形メッシュi個目の頂点3
            quads[i].p3 = Vertex( pos:Float2( xx, yy+sz ), rgba:Float4( 0.0, c, c / 2.0, 0.75 ) )
            // 四角形メッシュi個目の頂点4
            quads[i].p4 = Vertex( pos:Float2( xx+sz, yy+sz ), rgba:Float4( c, c, c, 0.75 ) )
        }
    }

    // Metalで実際に描画を指示する関数
    func compute( encoder:MTLComputeCommandEncoder ) {
        encoder.use( pl_compute ) {
            $0.setBuffer( tris, index:0 )
            $0.setBuffer( tris2, index:1 )
            $0.dispatch( dataCount:tris2.count * 3 )
        }
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // 準備したpipelineを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline ) {
            // 頂点シェーダのバッファ1番に行列matをセット
            $0.setVertexBuffer( mat, index:1 )
            // 三角形データ群の頂点をバッファ0番にセットし描画を実行
            $0.drawShape( tris2, index:0 )
            
            // 頂点シェーダのバッファ1番に行列matをセット
            $0.setVertexBuffer( mat, index:1 )
            // 四角形データ群の頂点をバッファ0番にセットし描画を実行
            $0.drawShape( quads, index:0 )
        }
    }
}
