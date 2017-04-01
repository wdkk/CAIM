//
// DrawingViewController.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct VertexInfo : Initializable {
    var pos:Vec4 = Vec4()
    var uv:Vec2 = Vec2()
    var rgba:CAIMColor = CAIMColor()
}

// パーティクル構造体
// ...

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?        // 行列バッファ
    private var quads_buf:CAIMMetalBuffer?      // 頂点バッファ(四角形)
    
    // CPU:形状メモリ
    private var quads = CAIMQuadrangles<VertexInfo>()
    
    // パーティクル情報配列 ...
    
    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインの作成
        pl = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragCircleCosCurve")
        pl?.blend_type = .alpha_blend
        
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        
        // (GPUバッファ)頂点バッファ(四角形)の作成
        quads_buf = CAIMMetalBuffer(vertice:quads)
        
        // パーティクル情報を作成
        // ...
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // パーティクル情報の更新
        // ...
        
        
        // パーティクル情報から頂点情報を作る(parts -> quads)
        // ...
        
        
        // GPUバッファの内容を更新(quads -> quads_buf)
        quads_buf?.update(vertice: quads)
        
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl)
        // 使用するバッファと番号をリンクする
        renderer.link(quads_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡すと四角形を描く)
        renderer.draw(quads)
    }
}
