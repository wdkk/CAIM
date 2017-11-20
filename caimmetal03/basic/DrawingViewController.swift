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

}

// パーティクル情報
struct Particle {

}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    // パイプラインやメッシュ群の変数を作る
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
    override func update(renderer:CAIMMetalRenderer) {
        // 円情報の更新

        // 円情報から頂点メッシュ情報を生成

        // 円の描画

        
        // リング情報の更新

        // リング情報から頂点メッシュ情報を生成

        // リングの描画

    }
}



