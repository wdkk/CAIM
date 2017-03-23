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
    // はじめに1度だけ呼ばれる関数(ここで準備する)
    override func setup() {
        // 画面をクリア
        clear()
       
        
        
        // 画面を更新
        redraw()
    }
    
}



