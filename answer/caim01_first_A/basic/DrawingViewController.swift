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

// 自由にピクセルを塗って絵を作れるViewController
class DrawingViewController: CAIMViewController
{
    // 画像データの変数
    var img_red:CAIMImage = CAIMImage(wid:320, hgt:320)
    var img_fill:CAIMImage = CAIMImage(wid:320, hgt:320)
    var img_2div:CAIMImage = CAIMImage(wid:320, hgt:320)
    var img_4div:CAIMImage = CAIMImage(wid:320, hgt:320)
    var img_checker:CAIMImage = CAIMImage(wid:320, hgt:320)

    // はじめに1度だけ呼ばれる関数(ここで準備する)
    override func setup() {
        // 画面をクリア
        clear()
    
        // 画面全体の画像(self.image)にfillRed関数をかけて真っ赤にする
        //ImageToolBox.fillRed(self.image)
        
        // img_redをImageToolBoxのfillRed関数に渡して赤にする
        ImageToolBox.fillRed(img_red)
    
        // img_redを(x,y)の位置に貼り付け
        self.image.paste(img_red, x: 0, y: 0)
        
        // 4色好きな色を作る
        let c1 = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)
        let c2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        let c3 = CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0)
        let c4 = CAIMColor(R: 1.0, G: 0.5, B: 0.0, A: 1.0)
        
        // img_fillをfillColor関数に渡してc1の色で塗る
        ImageToolBox.fillColor(img_fill, color: c1)
        
        // img_fillを(x,y)の位置に貼り付け
        self.image.paste(img_fill, x: 320, y: 0)
        
        
        // img_2divをfill2div関数に渡してc1,c2の色で塗る
        ImageToolBox.fill2div(img_2div, color1: c1, color2: c2)
        
        // img_2divを(0,320)の位置に貼り付け
        self.image.paste(img_2div, x: 0, y: 320)
        
        
        // img_4divをfill4div関数に渡してc1,c2,c3,c4の色で塗る
        ImageToolBox.fill4div(img_4div, color1: c1, color2: c2, color3: c3, color4: c4)
        
        // img_4divを(320,320)の位置に貼り付け
        self.image.paste(img_4div, x: 320, y: 320)
        
        
        // img_checkerをfill2div関数に渡してc1,c2の色で塗る
        ImageToolBox.checkerBoard(img_checker, color1: c1, color2: c2)

        // img_checkerを(0,640)の位置に貼り付け
        self.image.paste(img_checker, x: 0, y: 640)
        
        // 画面を更新
        redraw()
    }
    
}



