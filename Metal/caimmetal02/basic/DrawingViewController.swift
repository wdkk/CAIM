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
