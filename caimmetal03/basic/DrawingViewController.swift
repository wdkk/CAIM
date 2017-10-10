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
    
    // 演習資料にある各種関数を作成
    // ...
    
    
    
    // 準備関数
    override func setup() {
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        // 円描画の準備

        // リング描画の準備

    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // 円情報の更新

        // 円情報からGPUバッファを生成

        // 円の描画

        
        // リング情報の更新

        // リング情報からGPUバッファを生成

        // リングの描画

    }
}
