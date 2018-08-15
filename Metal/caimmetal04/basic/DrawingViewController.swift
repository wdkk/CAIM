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

// 頂点情報の構造体
struct Vertex {

}

// パーティクル情報
struct Particle {

}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    // 資料にある各種変数を実装する
    // ...
    
    
    
    // 準備関数
    override func setup() {
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)

        // 円描画シェーダの準備

    }
    
    // 繰り返し処理関数
    override func update(metalView: CAIMMetalView) {
        // タッチ位置にパーティクル発生
        for pos in self.touchPos {
            // 新しいパーティクルを生成

            
            
            // パーティクルを追加

        }
        
        // 円パーティクルのライフの更新

        
        // 不要な円パーティクルの削除

        
        

        // パーティクル情報からメッシュ情報を更新

        // 円の描画

    }
}

