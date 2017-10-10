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

// パーティクル情報
struct Particle {
    var pos:Vec2 = Vec2()               // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl_circle:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?            // 行列バッファ
    private var circle_quads_buf:CAIMMetalBuffer?   // 頂点バッファ(円を描く四角形)

    // CPU:形状メモリ
    private var circle_quads = CAIMQuadrangles<VertexInfo>()    // 円用メモリ
    
    // パーティクル情報配列
    private var circle_parts = [Particle]()     // 円用パーティクル情報

    
    // 準備関数
    override func setup() {

        
        
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // タッチ位置にパーティクル発生
        for pos:CGPoint in touch_pos {

            
            
        }
    }
}
