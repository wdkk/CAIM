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
import UIKit

class DrawingViewController : CAIMViewController
{
    // 表示ビューと画像データの変数
    var view_grad_x:CAIMView = CAIMView(x: 0, y: 0, width: 320, height: 320)
    var img_grad_x:CAIMImage = CAIMImage(width:320, height:320)

    // はじめに1度だけ呼ばれる関数(ここで準備する)
    override func setup() {        
        // 横方向グラデーション画像の作成
        let cx1 = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        let cx2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        ImageToolBox.gradX(img_grad_x, color1:cx1, color2:cx2)
        // view_grad_xの画像として、img_grad_xを設定する
        view_grad_x.image = img_grad_x
        // view_grad_xを画面に追加
        self.view.addSubview( view_grad_x )
        
    
        
    }
}



