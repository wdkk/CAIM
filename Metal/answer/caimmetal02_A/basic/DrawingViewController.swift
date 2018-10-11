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

// 1頂点情報の構造体
struct Vertex {
    var pos:Float2  = Float2()
    var uv:Float2   = Float2()
    var rgba:Float4 = Float4()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?       // Metalビュー
    private var pipeline = CAIMMetalRenderPipeline()  // Metalレンダパイプライン
    private var mat:Matrix4x4 = .identity       // 変換行列
    private var quads = CAIMMetalQuadrangles<Vertex>( count: 100, at:0 )    // ４頂点メッシュ群
    
    // 準備関数
    override func setup() {
        super.setup()
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        // レンダパイプラインで使用する頂点シェーダを設定
        pipeline.vertexShader = CAIMMetalShader( "vert2d" )
        // レンダパイプラインで使用するフラグメントシェーダを設定
        pipeline.fragmentShader = CAIMMetalShader( "fragRing" )
        
        // 形状データを作成する関数を呼ぶ
        makeShapes()
        
        // MetalViewのレンダリングを実行
        metal_view?.execute( renderFunc: self.render )
    }
    
    // 形状データを作成する関数
    func makeShapes() {
        // ピクセル座標変換行列をmetal_viewのサイズから作成
        mat = Matrix4x4.pixelProjection( metal_view!.pixelBounds.size )
        
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        
        // ４頂点メッシュの個数分、値を設定
        for i:Int in 0 ..< quads.count {
            let x = CAIM.random(wid)   // 横位置: 0.0 ~ widまでの乱数
            let y = CAIM.random(hgt)   // 縦位置: 0.0 ~ hgtまでの乱数
            let r = CAIM.random(100.0) // 円の半径(0.0 ~ 100.0までの乱数)
            let red = CAIM.random()    // 赤(0.0~1.0までの乱数)
            let green = CAIM.random()  // 緑(0.0~1.0までの乱数)
            let blue = CAIM.random()   // 青(0.0~1.0までの乱数)
            let alpha = CAIM.random()  // アルファ(0.0~1.0までの乱数)
            let color = Float4( red, green, blue, alpha )   // 上4つを合わせたRGBA色値
            
            // 四角形メッシュi個目の頂点1
            quads[i].p1 = Vertex( pos:Float2( x-r, y-r ), uv:Float2( -1.0, -1.0 ), rgba:color )
            // 四角形メッシュi個目の頂点2
            quads[i].p2 = Vertex( pos:Float2( x+r, y-r ), uv:Float2( 1.0, -1.0 ), rgba:color )
            // 四角形メッシュi個目の頂点3
            quads[i].p3 = Vertex( pos:Float2( x-r, y+r ), uv:Float2( -1.0, 1.0 ), rgba:color )
            // 四角形メッシュi個目の頂点4
            quads[i].p4 = Vertex( pos:Float2( x+r, y+r ), uv:Float2( 1.0, 1.0 ), rgba:color )
        }
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // 準備したpipelineを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline ) {
            // 頂点シェーダのバッファ1番に行列matをセット
            $0.setVertexBuffer( mat, at: 1 )
            // 四角形データ群の描画実行(※バッファ0番に頂点情報が自動セットされる)
            $0.drawShape( quads )
        }
    }
}
