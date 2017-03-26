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
    var rgba:CAIMColor = CAIMColor()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?        // 行列バッファ
    private var tris_buf:CAIMMetalBuffer?       // 頂点バッファ
    
    // CPU:形状メモリ
    private var tris  = CAIMTriangles<VertexInfo>(count: 1)
    
    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインの作成
        pl = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragStandard")
        
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        
        // (GPUバッファ)頂点バッファの作成
        tris_buf  = CAIMMetalBuffer(vertice:tris)
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // 頂点メモリの先頭ポインタを取得
        let p_tris = tris.pointer
  
        // 三角形頂点v0
        p_tris[0].v0.pos  = Vec4(150, 0, 0, 1)
        p_tris[0].v0.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        // 三角形頂点v1
        p_tris[0].v1.pos  = Vec4(300, 300, 0, 1)
        p_tris[0].v1.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        // 三角形頂点v2
        p_tris[0].v2.pos  = Vec4(0, 300, 0, 1)
        p_tris[0].v2.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)

        // GPUバッファの内容を更新(tris -> tris_buf)
        tris_buf?.update(vertice: tris)
        
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl)
        // 使用するバッファと番号をリンクする
        renderer.link(tris_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(trisを渡すと三角形を描いてくれる)
        renderer.draw(tris)
    }
}
