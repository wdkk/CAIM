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

// 自由にピクセルを塗って絵を作れるViewController
class DrawingViewController: CAIMViewController
{
    // 表示ビューと画像データの変数
    var view_red:CAIMView = CAIMView(x: 0, y: 0, width: 320, height: 320)
    var img_red:CAIMImage = CAIMImage(width:320, height:320)
    
    var view_fill:CAIMView = CAIMView(x: 320, y: 0, width: 320, height: 320)
    var img_fill:CAIMImage = CAIMImage(width:320, height:320)
    
    var view_2div:CAIMView = CAIMView(x: 0, y: 320, width: 320, height: 320)
    var img_2div:CAIMImage = CAIMImage(width:320, height:320)
    
    var view_4div:CAIMView = CAIMView(x: 320, y: 320, width: 320, height: 320)
    var img_4div:CAIMImage = CAIMImage(width:320, height:320)

    var view_checker:CAIMView = CAIMView(x: 0, y: 640, width: 320, height: 320)
    var img_checker:CAIMImage = CAIMImage(width:320, height:320)

    // はじめに1度だけ呼ばれる関数(アプリの準備)
    override func setup() {
        // img_redをImageToolBoxのfillRed関数に渡して赤く塗る
        ImageToolBox.fillRed( img_red )
        // view_redの画像として、img_redを設定する
        view_red.image = img_red
        // view_redを画面に追加
        self.view.addSubview( view_red )
        
        // 4色好きな色を作る
        let c1 = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)
        let c2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        let c3 = CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0)
        let c4 = CAIMColor(R: 1.0, G: 0.5, B: 0.0, A: 1.0)
        
        // img_fillをImageToolBoxのfillColor関数に渡して、c1の色で塗る
        ImageToolBox.fillColor( img_fill, color:c1 )
        // view_fillの画像として、img_fillを設定する
        view_fill.image = img_fill
        // view_fillを画面に追加
        self.view.addSubview( view_fill )
        
        // img_2divをfill2div関数に渡してc1,c2の色で塗る
        ImageToolBox.fill2div( img_2div, color1: c1, color2: c2 )
        // view_2divの画像として、img_2divを設定する
        view_2div.image = img_2div
        // view_2divを画面に追加
        self.view.addSubview( view_2div )
        
        // img_4divをfill4div関数に渡してc1,c2,c3,c4の色で塗る
        ImageToolBox.fill4div( img_4div, color1: c1, color2: c2, color3: c3, color4: c4 )
        // view_4divの画像として、img_4divを設定する
        view_4div.image = img_4div
        // view_4divを画面に追加
        self.view.addSubview( view_4div )
        
        // img_checkerをcheckerBoard関数に渡してc1,c2の色で塗る
        ImageToolBox.checkerBoard( img_checker, color1: c1, color2: c2 )
        // view_checkerの画像として、img_checkerを設定する
        view_checker.image = img_checker
        // view_checkerを画面に追加
        self.view.addSubview( view_checker )
    }
}
