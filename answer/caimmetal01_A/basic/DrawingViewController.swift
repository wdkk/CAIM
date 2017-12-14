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
    var pos:Float2 = Float2()
    var rgba:Float4 = Float4()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var renderer:CAIMMetalRenderer?                 // パイプラインレンダラ
    private var mat:Matrix4x4 = .identity                   // 変換行列
    private var tris = CAIMTriangles<Vertex>(count:100)     // ３頂点メッシュ群
    private var quads = CAIMQuadrangles<Vertex>(count:25)   // ４頂点メッシュ群

    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインレンダラの作成
        renderer = CAIMMetalRenderer(vertname:"vert2d", fragname:"fragStandard")
        // アルファブレンドを有効にする
        renderer?.blendType = .alphaBlend
        // デプスを無効にする
        renderer?.depthCompare = .always
        renderer?.depthEnabled = false

        // ピクセル座標変換行列を作成
        mat = Matrix4x4.pixelProjection(CAIM.screenPixel)
        
        // 演習1
        /*
        // 三角形メッシュ0個目の頂点0
        tris[0][0].pos  = Float2(150, 0)
        tris[0][0].rgba = CAIMColor(1.0, 0.0, 0.0, 1.0).float4
        // 三角形メッシュ0個目の頂点1
        tris[0][1].pos  = Float2(300, 300)
        tris[0][1].rgba = CAIMColor(1.0, 0.0, 0.0, 1.0).float4
        // 三角形メッシュ0個目の頂点2
        tris[0][2].pos  = Float2(0, 300)
        tris[0][2].rgba = CAIMColor(1.0, 0.0, 0.0, 1.0).float4
        */
        
        // 演習2
        /*
        // 三角形メッシュ0個目の頂点0
        tris[0][0].pos  = Float2(0, 0)
        tris[0][0].rgba = CAIMColor(1.0, 0.0, 0.0, 1.0).float4  // 赤
        // 三角形メッシュ0個目の頂点1
        tris[0][1].pos  = Float2(300, 150)
        tris[0][1].rgba = CAIMColor(0.0, 1.0, 0.0, 1.0).float4  // 緑
        // 三角形メッシュ0個目の頂点2
        tris[0][2].pos  = Float2(120, 300)
        tris[0][2].rgba = CAIMColor(0.0, 0.0, 1.0, 1.0).float4  // 青
        */
        
        // 演習3
        // 三角形の個数分、頂点情報を指定する
        for i:Int in 0 ..< tris.count {
            let x = Float(i % 10)
            let y = Float(i / 10)
            let c = Float(x+y) / 20.0
            
            // 三角形メッシュi個目の頂点0
            tris[i][0].pos  = Float2( (x+0.5)*60.0, y*60.0 )
            tris[i][0].rgba = CAIMColor(c, 0.0, 0.0, 1.0).float4
            // 三角形メッシュi個目の頂点1
            tris[i][1].pos  = Float2( (x+1.0)*60.0, (y+1)*60.0 )
            tris[i][1].rgba = CAIMColor(c, 0.0, 0.0, 1.0).float4
            // 三角形メッシュi個目の頂点2
            tris[i][2].pos  = Float2( x*60.0, (y+1)*60.0 )
            tris[i][2].rgba = CAIMColor(c, 0.0, 0.0, 1.0).float4
        }
        
        // 演習4
        // 矩形の個数分、頂点情報を指定する
        for i:Int in 0 ..< quads.count {
            let x = Float(i % 5)
            let y = Float(i / 5)
            let c = Float((8.0 - (x+y)) / 8.0)
            
            let sz  = Float(100) // 四角形のサイズ
            let mgn = Float(20)  // 隙間
            let xx  = Float(40 + x * (sz + mgn))
            let yy  = Float(40 + y * (sz + mgn))
            
            // 四角形メッシュi個目の頂点0
            quads[i][0].pos  = Float2(xx, yy)
            quads[i][0].rgba = CAIMColor(0.0, 0.0, 0.0, 0.75).float4
            // 四角形メッシュi個目の頂点1
            quads[i][1].pos  = Float2(xx+sz, yy)
            quads[i][1].rgba = CAIMColor(c, 0.0, c/2.0, 0.75).float4
            // 四角形メッシュi個目の頂点2
            quads[i][2].pos  = Float2(xx, yy+sz)
            quads[i][2].rgba = CAIMColor(0.0, c, c/2.0, 0.75).float4
            // 四角形メッシュi個目の頂点3
            quads[i][3].pos  = Float2(xx+sz, yy+sz)
            quads[i][3].rgba = CAIMColor(c, c, c, 0.75).float4
        }
    }
    
    // 繰り返し処理関数
    override func update(metalView: CAIMMetalView) {
        // パイプラインレンダラで描画開始
        renderer?.beginDrawing(on: metalView)
        
        // 演習1,2,3
        // CPUの頂点メッシュメモリからGPUバッファを作成し、シェーダ番号をリンクする
        renderer?.link(tris.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer?.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(trisを渡して３頂点メッシュを描く）
        renderer?.draw(tris)

        // 演習4
        // 使用するCPUメモリからGPUバッファを作成し、シェーダの番号をリンクする
        renderer?.link(quads.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer?.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡して４頂点メッシュを描く）
        renderer?.draw(quads)
    }
}
