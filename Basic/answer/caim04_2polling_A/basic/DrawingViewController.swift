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
        // タッチ数のカウントをcountにとる
        let count:Int = view_all.touchPixelPos.count
        // タッチしているかどうかを判定 => countが1以上のときはタッチがある
        if count > 0 {
            // タッチしている指の数分繰り返す
            for i in 0 ..< count {
                // i本目の指のタッチ位置のピクセル座標posを取得
                let pos = view_all.touchPixelPos[i]
                // posの位置に薄い赤円を描く
                ImageToolBox.fillCircle(img_all, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
                                        color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0), opacity: 0.2)
            }
            
            // 画像の内容を更新したので、view_allの表示も更新する
            view_all.redraw()
        }
    }
}



