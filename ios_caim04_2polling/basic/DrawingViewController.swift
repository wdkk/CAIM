//
// DrawingViewController.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit

// 自由にピクセルを塗って絵を作れるView
class DrawingViewController : CAIMViewController
{
    // 起動時に1度だけ呼ばれる(準備)
    override func setup() {
        // 画面をクリア
        clear()
        // 画面を更新
        redraw()
    }
   
    // 60FPSで繰り返し呼ばれる関数
    override func update() {
     
    
    }
}



