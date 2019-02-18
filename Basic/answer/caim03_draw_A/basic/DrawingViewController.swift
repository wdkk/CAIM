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
    
    // はじめに1度だけ呼ばれる関数(アプリの準備)
    override func setup() {
        // img_allを白で塗りつぶす
        img_all.fillColor( CAIMColor.white )
        // view_allの画像として、img_allを設定する
        view_all.image = img_all
        // view_allを画面に追加
        self.view.addSubview( view_all )
       
        // 四角をずらしながら６つ描く
        ImageToolBox.fillRect(img_all, x1: 30, y1: 20, x2: 110, y2: 100,
                              color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0) )
        
        ImageToolBox.fillRect(img_all, x1: 130, y1: 20, x2: 210, y2: 100,
                              color: CAIMColor(R: 0.8, G: 0.0, B: 0.2, A: 1.0) )
        
        ImageToolBox.fillRect(img_all, x1: 230, y1: 20, x2: 310, y2: 100,
                              color: CAIMColor(R: 0.6, G: 0.0, B: 0.4, A: 1.0) )
        
        ImageToolBox.fillRect(img_all, x1: 330, y1: 20, x2: 410, y2: 100,
                              color: CAIMColor(R: 0.4, G: 0.0, B: 0.6, A: 1.0) )
        
        ImageToolBox.fillRect(img_all, x1: 430, y1: 20, x2: 510, y2: 100,
                              color: CAIMColor(R: 0.2, G: 0.0, B: 0.8, A: 1.0) )
        
        ImageToolBox.fillRect(img_all, x1: 530, y1: 20, x2: 610, y2: 100,
                              color: CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0) )
        
        // 透明度付きの四角を描く
        for i in 0 ..< 6 {
            ImageToolBox.fillRect(img_all, x1: 30+100*i, y1: 120, x2: 110+100*i, y2: 200,
                                  color: CAIMColor(R: 1.0 - Float(i) * 0.2, G: 0.0, B: Float(i) * 0.2, A: 1.0),
                                  opacity:0.8 - Float(i) * 0.1 )
        }
        
        // 丸を描く
        for i in 0 ..< 6 {
            ImageToolBox.fillCircle(img_all, cx: 70+100*i, cy: 260, radius: 40,
                                    color: CAIMColor(R: 1.0, G: 0.5 + Float(i) * 0.1, B:Float(i) * 0.1, A: 1.0))
        }
        
        // 丸を描く（透明度付き）
        for i in 0 ..< 6 {
            ImageToolBox.fillCircle(img_all, cx: 70+100*i, cy: 360, radius: 40,
                                    color: CAIMColor(R: 1.0, G: 0.5, B: 0.0, A: 1.0),
                                    opacity:1.0 - Float(i) * 0.15 )
        }
        
        // 丸を重ねて描く
        for i in 0 ..< 12 {
            ImageToolBox.fillCircle(img_all, cx: 70+45*i, cy: 460, radius: 40,
                                    color: CAIMColor(R: 1.0, G: 0.2, B: 0.2, A: 1.0),
                                    opacity:0.3 - Float(i) * 0.02 )
        }
        
        // ドームを描く(透明度付き)
        for i in 0 ..< 6 {
            ImageToolBox.fillDome(img_all, cx: 70+100*i, cy: 560, radius: 40,
                                  color: CAIMColor(R: 0.0, G: 0.5, B: 0.0, A: 1.0),
                                  opacity:1.00 - Float(i)*0.15 )
        }
        
        // ドームを重ねて描く(透明度付き)
        for i in 0 ..< 12 {
            ImageToolBox.fillDome(img_all, cx: 70+45*i, cy: 660, radius: 40,
                                  color: CAIMColor(R: 0.0, G: 0.5, B: 0.0, A: 1.0),
                                  opacity:0.5 - Float(i)*0.025 )
        }
        
        // 直線を描く
        for i in 0 ..< 10 {
            ImageToolBox.drawLine(img_all, x1: 30, y1: 728+8*i, x2: 600, y2: 800,
                                  color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0),
                                  opacity: 1.0)
        }
    }
    
}



