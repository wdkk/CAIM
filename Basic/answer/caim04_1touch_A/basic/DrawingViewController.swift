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
        
        // view_all上のタッチ開始時の処理として、touchPressedOnView関数を指定
        view_all.touchPressed = self.touchPressedOnView
        // view_all上のタッチ移動時の処理として、touchMovedOnView関数を指定
        view_all.touchMoved = self.touchMovedOnView
        // view_all上のタッチ終了時の処理として、touchReleasedOnView関数を指定
        view_all.touchReleased = self.touchReleasedOnView
        
        // view_all上のタッチ移動時の処理に、マルチタッチ対応したmultiTouchMovedOnView関数を指定
        view_all.touchMoved = self.multiTouchMovedOnView
    }
    
    // viewのタッチ開始の時に呼び出す関数
    func touchPressedOnView() {
        // view_all上でのタッチ座標の1つ目を取得し、posに代入
        let pos = view_all.touchPixelPos[0]
        // posの位置に青円を描く
        ImageToolBox.fillCircle(img_all, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
            color: CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0), opacity: 1.0)
        
        // 画像の内容を更新したので、view_allの表示も更新する
        view_all.redraw()
    }
    
    // viewをタッチして指でなぞった時に呼び出す関数
    func touchMovedOnView() {
        // view_all上でのタッチ座標の1つ目を取得し、posに代入
        let pos = view_all.touchPixelPos[0]
        // posの位置に薄い赤円を描く
        ImageToolBox.fillCircle(img_all, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
            color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0), opacity: 0.2)
        
        // 画像の内容を更新したので、view_allの表示も更新する
        view_all.redraw()
    }
    
    // 指を離した時に呼ばれる
    func touchReleasedOnView() {
        // view_all上でのリリース座標の1つ目を取得し、posに代入
        let pos = view_all.releasePixelPos[0]
        // posの位置に緑円を描く
        ImageToolBox.fillCircle(img_all, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
            color: CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0), opacity: 1.0)
        
        // 画像の内容を更新したので、view_allの表示も更新する
        view_all.redraw()
    }
    
    // 指でなぞった時に呼ばれる
    func multiTouchMovedOnView() {
        // タッチしている指の数を取得
        let count = view_all.touchPixelPos.count
        
        // タッチしている指すべての位置を取得して、円を描く
        for i in 0 ..< count {
            // i本目の指のタッチ位置のピクセル座標posを取得
            let pos = view_all.touchPixelPos[i]
            // posの位置に薄い赤円を描く
            ImageToolBox.fillCircle( img_all, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
                color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0), opacity: 0.2)
        }
       
        // 画像の内容を更新したので、view_allの表示も更新する
        view_all.redraw()
    }
}
