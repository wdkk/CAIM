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
import simd

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct Vertex {
    var pos:Float2  = Float2()
    var uv:Float2   = Float2()
    var rgba:Float4 = Float4()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var renderer:CAIMMetalRenderer?                     // パイプラインレンダラ
    private var mat:Matrix4x4 = .identity                       // 変換行列
    private var quads = CAIMQuadrangles<Vertex>(count: 100)     // ４頂点メッシュ群
    
    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインレンダラの作成
        renderer = CAIMMetalRenderer(vertname:"vert2d", fragname:"fragRing")
        // アルファブレンドを有効にする
        renderer?.blendType = .alphaBlend
        // デプスを無効にする
        renderer?.depthCompare = .always
        renderer?.depthEnabled = false
        
        // ピクセル座標変換行列を作成
        mat = Matrix4x4.pixelProjection(CAIM.screenPixel)
        
        let wid = Float(CAIM.screenPixel.width)
        let hgt = Float(CAIM.screenPixel.height)
        // ４頂点メッシュの個数分、値を設定
        for i:Int in 0 ..< quads.count {
            let x = CAIM.random(wid)   // 横位置: 0.0 ~ widまでの乱数
            let y = CAIM.random(hgt)   // 縦位置: 0.0 ~ hgtまでの乱数
            let r = CAIM.random(100.0) // 円の半径(0.0 ~ 100.0までの乱数)
            let red = CAIM.random()    // 赤(0.0~1.0までの乱数)
            let green = CAIM.random()  // 緑(0.0~1.0までの乱数)
            let blue = CAIM.random()   // 青(0.0~1.0までの乱数)
            let alpha = CAIM.random()  // アルファ(0.0~1.0までの乱数)
            
            // 四角形メッシュi個目の頂点0
            quads[i][0].pos  = Float2(x-r, y-r)
            quads[i][0].uv   = Float2(-1.0, -1.0)
            quads[i][0].rgba = CAIMColor(red, green, blue, alpha).float4
            // 四角形メッシュi個目の頂点1
            quads[i][1].pos  = Float2(x+r, y-r)
            quads[i][1].uv   = Float2(1.0, -1.0)
            quads[i][1].rgba = CAIMColor(red, green, blue, alpha).float4
            // 四角形メッシュi個目の頂点2
            quads[i][2].pos  = Float2(x-r, y+r)
            quads[i][2].uv   = Float2(-1.0, 1.0)
            quads[i][2].rgba = CAIMColor(red, green, blue, alpha).float4
            // 四角形メッシュi個目の頂点3
            quads[i][3].pos  = Float2(x+r, y+r)
            quads[i][3].uv   = Float2(1.0, 1.0)
            quads[i][3].rgba = CAIMColor(red, green, blue, alpha).float4
        }
    }
    
    // 繰り返し処理関数
    override func update(metalView: CAIMMetalView) {
        // パイプラインレンダラで描画開始
        renderer?.beginDrawing(on: metalView)
        
        // 使用するCPUメモリからGPUバッファを作成し、シェーダの番号をリンクする
        renderer?.link(quads.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer?.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡して４頂点メッシュを描く)
        renderer?.draw(quads)
    }
}
