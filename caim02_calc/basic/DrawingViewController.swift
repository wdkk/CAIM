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

// 自由にピクセルを塗って絵を作れるView
class DrawingViewController : CAIMViewController
{
    var img_grad_x:CAIMImage = CAIMImage(wid:320, hgt:320)  // 横方向グラデーション用画像

    // はじめに1度だけ呼ばれる関数(ここで準備する)
    override func setup() {        
        // 画面をクリア
        clear()
        
        // 横方向グラデーション画像の作成
        let cx1 = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        let cx2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        ImageToolBox.gradX(img_grad_x, color1:cx1, color2:cx2)
        // 横方向グラデーション画像を貼り付け
        self.image.paste(img_grad_x, x: 0, y: 0)
        
        
        
        // 画面を更新
        redraw()
    }
    
}



