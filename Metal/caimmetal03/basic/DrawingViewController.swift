//
// DrawingViewController.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import simd

// 1頂点情報の構造体
struct Vertex {

}

// パーティクル情報
struct Particle {

}

class DrawingViewController : CAIMViewController
{
    // Metalビュー、パイプライン、メッシュ群などの変数を作る
    // ...

    
    // 演習資料にある各関数を実装してsetup, update関数内で呼び出す
    // ...
    
    
    
    // 準備関数
    override func setup() {
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)

        // 円描画の準備

        // リング描画の準備

    }
    
    // 繰り返し処理関数
    override func update() {
        super.update()
        // 円情報の更新

        // 円情報から頂点メッシュ情報を生成
        
        // リング情報の更新

        // リング情報から頂点メッシュ情報を生成

        // Metalビューのレンダリングを実行

    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
    
        // encoderを使ってMetalの描画を実行
        
    }
}



