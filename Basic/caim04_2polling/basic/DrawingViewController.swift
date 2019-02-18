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
    // view_allを画面いっぱいのピクセル領域(screenPixelRect)の大きさで用意
    var view_all:CAIMView = CAIMView(pixelFrame: CAIM.screenPixelRect)
    // 画像データimg_allを画面のピクセルサイズ(screenPixelSize)に合わせて用意
    var img_all:CAIMImage = CAIMImage(size: CAIM.screenPixelSize)
    
    // 起動時に1度だけ呼ばれる(準備)
    override func setup() {
        // img_allを白で塗りつぶす
        img_all.fillColor( CAIMColor.white )
        // view_allの画像として、img_allを設定する
        view_all.image = img_all
        // view_allを画面に追加
        self.view.addSubview( view_all )
    }
    
    // 60FPSで繰り返し呼ばれる関数
    override func update() {
     
    }
}



