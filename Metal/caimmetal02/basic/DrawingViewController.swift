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

// 1頂点情報の構造体
struct Vertex {

}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController
{

    // 準備関数
    override func setup() {
        super.setup()

        
        // 形状データを作成する関数を呼ぶ
        makeShapes()
        

    }
    
    // 形状データを作成する関数
    func makeShapes() {

        
        
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {

        
        
    }
}
