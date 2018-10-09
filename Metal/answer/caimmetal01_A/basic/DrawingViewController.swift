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

// 1頂点情報の構造体
struct Vertex {
    var pos:Float2 = Float2()
    var rgba:Float4 = Float4()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController
{
    var metal_view:CAIMMetalView?               // Metalビュー
    private var renderer = CAIMMetalRenderer()  // Metalレンダラ
    private var mat:Matrix4x4 = .identity                              // 変換行列
    private var tris = CAIMMetalTriangles<Vertex>(count:100, at:0)     // ３頂点メッシュ群
    private var quads = CAIMMetalQuadrangles<Vertex>(count:25, at:0)   // ４頂点メッシュ群
    
    override func setup() {
        super.setup()
        
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView(frame: view.bounds)
        self.view.addSubview( metal_view! )
        
        // レンダラで使用する頂点シェーダを設定
        renderer.vertexShader = CAIMMetalShader( "vert2d" )
        // レンダラで使用するフラグメントシェーダを設定
        renderer.fragmentShader = CAIMMetalShader( "fragStandard" )
        
        // 形状データを作成する関数を呼ぶ
        makeShapes()
        
        // MetalViewのレンダリングを実行
        metal_view?.execute( renderFunc: self.render )
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
            tris[i].p1 = Vertex( pos:[ (x+0.5) * 60.0, y * 60.0 ], rgba:[ c, 0.0, 0.0, 1.0 ] )
            // 三角形メッシュi個目の頂点p2
            tris[i].p2 = Vertex( pos:[ (x+1.0) * 60.0, (y+1) * 60.0 ], rgba:[ c, 0.0, 0.0, 1.0 ] )
            // 三角形メッシュi個目の頂点p3
            tris[i].p3 = Vertex( pos:[ x * 60.0, (y+1) * 60.0 ], rgba:[ c, 0.0, 0.0, 1.0 ] )
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
            quads[i].p1 = Vertex( pos:[ xx, yy ], rgba:[ 0.0, 0.0, 0.0, 0.75 ] )
            // 四角形メッシュi個目の頂点2
            quads[i].p2 = Vertex( pos:[ xx+sz, yy ], rgba:[ c, 0.0, c / 2.0, 0.75 ] )
            // 四角形メッシュi個目の頂点3
            quads[i].p3 = Vertex( pos:[ xx, yy+sz ], rgba:[ 0.0, c, c / 2.0, 0.75 ] )
            // 四角形メッシュi個目の頂点4
            quads[i].p4 = Vertex( pos:[ xx+sz, yy+sz ], rgba:[ c, c, c, 0.75 ] )
        }
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // rendererをつかって、描画を開始
        renderer.begin { encoder in
            // 図形描画のためにエンコーダを設定
            tris.encoder = encoder
            // 頂点シェーダのバッファ1番に行列matをセット
            tris.setVertexBuffer( mat, at: 1 )
            // 三角形データ群の描画実行(※バッファ0番に頂点情報が自動セットされる)
            tris.draw()

            // 図形描画のためにエンコーダを設定
            quads.encoder = encoder
            // 頂点シェーダのバッファ1番に行列matをセット
            quads.setVertexBuffer( mat, at: 1 )
            // 四角形データ群の描画実行(※バッファ0番に頂点情報が自動セットされる)
            quads.draw()
        }
    }
}
