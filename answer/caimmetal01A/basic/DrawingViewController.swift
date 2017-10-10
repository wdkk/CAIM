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
    var rgba:CAIMColor = CAIMColor()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?        // 行列バッファ
    private var tris_buf:CAIMMetalBuffer?       // 頂点バッファ(三角形)
    private var quads_buf:CAIMMetalBuffer?      // 頂点バッファ(四角形)
    
    // CPU:形状メモリ
    private var tris  = CAIMTriangles<VertexInfo>(count: 100)
    private var quads = CAIMQuadrangles<VertexInfo>(count: 25)

    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインの作成
        pl = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragStandard")
        pl?.blend_type = .alpha_blend
        
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        
        // (GPUバッファ)頂点バッファ(三角形)の作成
        tris_buf  = CAIMMetalBuffer(vertice:tris)
        // (GPUバッファ)頂点バッファ(四角形)の作成
        quads_buf = CAIMMetalBuffer(vertice:quads)
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // 頂点メモリ(三角形)の先頭ポインタを取得
        let p_tris = tris.pointer

        /*
        // 演習1
        // 三角形0番目の頂点v0
        p_tris[0].v0.pos  = Vec4(150, 0, 0, 1)
        p_tris[0].v0.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        // 三角形0番目の頂点v1
        p_tris[0].v1.pos  = Vec4(300, 300, 0, 1)
        p_tris[0].v1.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        // 三角形0番目の頂点v2
        p_tris[0].v2.pos  = Vec4(0, 300, 0, 1)
        p_tris[0].v2.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        */
        
        /*
        // 演習2
        // 三角形0番目の頂点v0
        p_tris[0].v0.pos  = Vec4(0, 0, 0, 1)
        p_tris[0].v0.rgba = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)  // 赤
        // 三角形0番目の頂点v1
        p_tris[0].v1.pos  = Vec4(300, 150, 0, 1)
        p_tris[0].v1.rgba = CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0)  // 緑
        // 三角形0番目の頂点v2
        p_tris[0].v2.pos  = Vec4(120, 300, 0, 1)
        p_tris[0].v2.rgba = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)  // 青
        */

        // 演習3
        // 三角形の個数
        let tri_count:Int = tris.count
        for i:Int in 0 ..< tri_count {
            let x:Float32 = Float32(i % 10)
            let y:Float32 = Float32(i / 10)
            let c:Float   = Float(x+y) / 20.0
            
            // 三角形頂点v0
            p_tris[i].v0.pos  = Vec4((x+0.5)*60.0, y*60.0, 0, 1)
            p_tris[i].v0.rgba = CAIMColor(R: c, G: 0.0, B: 0.0, A: 1.0)
            // 三角形頂点v1
            p_tris[i].v1.pos  = Vec4((x+1.0)*60.0, (y+1)*60.0, 0, 1)
            p_tris[i].v1.rgba = CAIMColor(R: c, G: 0.0, B: 0.0, A: 1.0)
            // 三角形頂点v2
            p_tris[i].v2.pos  = Vec4(x*60.0, (y+1)*60.0, 0, 1)
            p_tris[i].v2.rgba = CAIMColor(R: c, G: 0.0, B: 0.0, A: 1.0)
        }
        
        // GPUバッファの内容を更新(tris -> tris_buf)
        tris_buf?.update(vertice: tris)
        
        // 演習4(1)
        // 頂点メモリ(四角形)の先頭ポインタを取得
        let p_quads = quads.pointer
        // 膝下系sの個数
        let quad_count:Int = quads.count
        for i:Int in 0 ..< quad_count {
            let x:Float32 = Float32(i % 5)
            let y:Float32 = Float32(i / 5)
            let c:Float   = Float((8.0 - (x+y)) / 8.0)
            
            let sz:Float32  = 100 // 四角形のサイズ
            let mgn:Float32 = 20  // 隙間
            let xx:Float32  = 40 + x*(sz+mgn)
            let yy:Float32  = 40 + y*(sz+mgn)
            
            // 四角形頂点v0
            p_quads[i].v0.pos  = Vec4(xx, yy, 0, 1)
            p_quads[i].v0.rgba = CAIMColor(R: 0.0, G: 0.0, B: 0.0,   A: 0.75)
            // 四角形頂点v1
            p_quads[i].v1.pos  = Vec4(xx+sz, yy, 0, 1)
            p_quads[i].v1.rgba = CAIMColor(R: c,   G: 0.0, B: c/2.0, A: 0.75)
            // 四角形頂点v2
            p_quads[i].v2.pos  = Vec4(xx, yy+sz, 0, 1)
            p_quads[i].v2.rgba = CAIMColor(R: 0.0, G: c,   B: c/2.0, A: 0.75)
            // 四角形頂点v3
            p_quads[i].v3.pos  = Vec4(xx+sz, yy+sz, 0, 1)
            p_quads[i].v3.rgba = CAIMColor(R: c,   G: c,   B: c,     A: 0.75)
        }
        
        // GPUバッファの内容を更新(quads -> quads_buf)
        quads_buf?.update(vertice: quads)
        
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl)
        
        // 使用するバッファと番号をリンクする
        renderer.link(tris_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(trisを渡すと三角形を描く)
        renderer.draw(tris)
        
        // 演習4(2)
        // 使用するバッファと番号をリンクする
        renderer.link(quads_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡すと四角形を描く)
        renderer.draw(quads)
    }
}
