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

// 1頂点情報の構造体
struct Vertex {

}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController
{
    // MetalView、レンダラ、メッシュ群、行列などの変数を作る
    // ...
    
    // 準備関数
    override func setup() {
        super.setup()
        
        // ... ビューの生成、レンダラの生成 ... //
        
        // 形状データを作成する関数を呼ぶ
        makeShapes()
        
        // ... ビューの描画実行 ... //
    }
    
    // 形状データを作成する関数
    func makeShapes() {
        
        // ... 座標値などをつくる ... //
        
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        
        // ... Metalの描画命令を実行する ... //
        
    }
}
