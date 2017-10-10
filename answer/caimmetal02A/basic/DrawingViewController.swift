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

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct VertexInfo : Initializable {
    var pos:Vec4 = Vec4()
    var uv:Vec2 = Vec2()
    var rgba:CAIMColor = CAIMColor()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?        // 行列バッファ
    private var quads_buf:CAIMMetalBuffer?      // 頂点バッファ(四角形)
    
    // CPU:形状メモリ
    private var quads = CAIMQuadrangles<VertexInfo>(count: 100)
    
    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインの作成
        pl = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragRing")
        pl?.blend_type = .alpha_blend
        
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        
        // (GPUバッファ)頂点バッファ(四角形)の作成
        quads_buf = CAIMMetalBuffer(vertice:quads)
        
        // 頂点メモリ(四角形)の先頭ポインタを取得
        let p_quads = quads.pointer
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        let quad_count:Int = quads.count
        for i:Int in 0 ..< quad_count {
            let x:Float = CAIMRandom(wid)   // 横位置: 0.0 ~ widまでの乱数
            let y:Float = CAIMRandom(hgt)   // 0.0 ~ hgtまでの乱数
            let r:Float = CAIMRandom(100.0) // 0.0 ~ 100.0までの乱数
            let red:Float = CAIMRandom()    // 赤(0.0~1.0までの乱数)
            let green:Float = CAIMRandom()  // 緑(0.0~1.0までの乱数)
            let blue:Float = CAIMRandom()   // 青(0.0~1.0までの乱数)
            let alpha:Float = CAIMRandom()  // アルファ(0.0~1.0までの乱数)
            
            // 四角形頂点v0
            p_quads[i].v0.pos  = Vec4(x-r, y-r, 0, 1)
            p_quads[i].v0.uv   = Vec2(-1.0, -1.0)
            p_quads[i].v0.rgba = CAIMColor(R: red, G: green, B: blue, A: alpha)
            // 四角形頂点v1
            p_quads[i].v1.pos  = Vec4(x+r, y-r, 0, 1)
            p_quads[i].v1.uv   = Vec2(1.0, -1.0)
            p_quads[i].v1.rgba = CAIMColor(R: red, G: green, B: blue, A: alpha)
            // 四角形頂点v2
            p_quads[i].v2.pos  = Vec4(x-r, y+r, 0, 1)
            p_quads[i].v2.uv   = Vec2(-1.0, 1.0)
            p_quads[i].v2.rgba = CAIMColor(R: red, G: green, B: blue, A: alpha)
            // 四角形頂点v3
            p_quads[i].v3.pos  = Vec4(x+r, y+r, 0, 1)
            p_quads[i].v3.uv   = Vec2(1.0, 1.0)
            p_quads[i].v3.rgba = CAIMColor(R: red, G: green, B: blue, A: alpha)
        }
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
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
