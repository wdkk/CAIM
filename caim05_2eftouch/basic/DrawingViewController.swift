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
    
    
    // 準備
    override func setup() {
        clear()        // 画面をクリア
        redraw()       // 画面を更新
    }

    // ポーリング
    override func update() {
        clear()     // 毎回クリア
  
        
        
        redraw()    // 画面を更新
    }
}



