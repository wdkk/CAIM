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
struct VertexInfo {
    var pos:Vec4 = Vec4()
    var uv:Vec2 = Vec2()
    var rgba:CAIMColor = CAIMColor()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl:CAIMMetalRenderPipeline? // パイプライン
    
    private var mat:Matrix4x4 = .identity                       // 変換行列
    private var quads = CAIMQuadrangles<VertexInfo>(count: 100) // ４頂点メッシュ群
    
    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインの作成
        pl = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragRing")
        pl?.blend_type = .alpha_blend
        
        // 画面サイズのピクセルプロジェクション行列の作成
        mat = Matrix4x4.pixelProjection(CAIMScreenPixel)
        
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        // ４頂点メッシュの個数分、値を設定
        for i:Int in 0 ..< quads.count {
            let x:Float = CAIMRandom(wid)   // 横位置: 0.0 ~ widまでの乱数
            let y:Float = CAIMRandom(hgt)   // 縦位置: 0.0 ~ hgtまでの乱数
            let r:Float = CAIMRandom(100.0) // 円の半径(0.0 ~ 100.0までの乱数)
            let red:Float = CAIMRandom()    // 赤(0.0~1.0までの乱数)
            let green:Float = CAIMRandom()  // 緑(0.0~1.0までの乱数)
            let blue:Float = CAIMRandom()   // 青(0.0~1.0までの乱数)
            let alpha:Float = CAIMRandom()  // アルファ(0.0~1.0までの乱数)
            
            // 四角形メッシュi個目の頂点0
            quads[i][0].pos  = Vec4(x-r, y-r, 0, 1)
            quads[i][0].uv   = Vec2(-1.0, -1.0)
            quads[i][0].rgba = CAIMColor(red, green, blue, alpha)
            // 四角形メッシュi個目の頂点1
            quads[i][1].pos  = Vec4(x+r, y-r, 0, 1)
            quads[i][1].uv   = Vec2(1.0, -1.0)
            quads[i][1].rgba = CAIMColor(red, green, blue, alpha)
            // 四角形メッシュi個目の頂点2
            quads[i][2].pos  = Vec4(x-r, y+r, 0, 1)
            quads[i][2].uv   = Vec2(-1.0, 1.0)
            quads[i][2].rgba = CAIMColor(red, green, blue, alpha)
            // 四角形メッシュi個目の頂点3
            quads[i][3].pos  = Vec4(x+r, y+r, 0, 1)
            quads[i][3].uv   = Vec2(1.0, 1.0)
            quads[i][3].rgba = CAIMColor(red, green, blue, alpha)
        }
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl)
        // CPUメモリからGPUバッファを作成し、シェーダのバッファ番号をリンクする
        renderer.link(quads.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡して４頂点メッシュを描く)
        renderer.draw(quads)
    }
}
