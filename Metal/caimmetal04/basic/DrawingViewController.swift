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

import Metal
import simd
import QuartzCore

// 頂点情報の構造体
struct Vertex {

}

// パーティクル情報
struct Particle {

}

class DrawingViewController : CAIMViewController
{
    // 資料にある各種変数を実装する
    // ...
    private var metal_view:CAIMMetalView?                   // Metalビュー
    
    
    // 準備関数
    override func setup() {
        super.setup()
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)

        // 円描画の準備

    }
    
    // 繰り返し処理関数
    override func update() {
        super.update()
        
        // タッチ位置にパーティクル発生
        for pos in metal_view!.touchPixelPos {
            // 新しいパーティクルを生成

            
            
            // パーティクルを追加

        }
        
        // 円パーティクルのライフの更新

        
        // 不要な円パーティクルの削除

        
        

        // パーティクル情報からメッシュ情報を更新
        
        // MetalViewのレンダリングを実行

    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
    
    
    
    }
}

