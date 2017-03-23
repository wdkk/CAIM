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
    var img_grad_x:CAIMImage = CAIMImage(wid:320, hgt:320)  // 横方向グラデーション用画像
    var img_grad_y:CAIMImage = CAIMImage(wid:320, hgt:320)   // 縦方向グラデーション用画像
    var img_grad_xy:CAIMImage = CAIMImage(wid:320, hgt:320)   // 斜め方向グラデーション用画像
    var img_grad_sin:CAIMImage = CAIMImage(wid:320, hgt:320) // Sinを使った波画像
    var img_grad_circle:CAIMImage = CAIMImage(wid:320, hgt:320)  // Sinを使った同心円の波画像
    var img_grad_dome:CAIMImage = CAIMImage(wid:320, hgt:320)    // Cosを使ったドーム状画像
    
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
        
        // 縦方向グラデーション画像の作成
        let cy1 = CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0)
        let cy2 = CAIMColor(R: 0.2, G: 0.2, B: 1.0, A: 1.0)
        ImageToolBox.gradY(img_grad_y, color1:cy1, color2:cy2)
        // 縦方向グラデーション画像を貼り付け
        self.image.paste(img_grad_y, x: 320, y: 0)
        
        // 斜め方向グラデーション画像の作成
        let cxy1 = CAIMColor(R: 0.0, G: 0.5, B: 0.0, A: 1.0)
        let cxy2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        ImageToolBox.gradXY(img_grad_xy, color1:cxy1, color2:cxy2)
        // 斜め方向グラデーション画像を貼り付け
        self.image.paste(img_grad_xy, x: 0, y: 320)
        
        // 横方向Sin波グラデーション画像の作成
        let csin1 = CAIMColor(R: 1.0, G: 1.0, B: 1.0, A: 1.0)
        let csin2 = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)
        ImageToolBox.gradSin(img_grad_sin, color1:csin1, color2:csin2, k: 4.0)
        // 横方向Sin波グラデーション画像を貼り付け
        self.image.paste(img_grad_sin, x: 320, y: 320)

        // 同心円グラデーション画像の作成
        let ccir1 = CAIMColor(R: 1.0, G: 0.5, B: 0.0, A: 1.0)
        let ccir2 = CAIMColor(R: 1.0, G: 1.0, B: 1.0, A: 1.0)
        ImageToolBox.gradSinCircle(img_grad_circle, color1:ccir1, color2:ccir2, k:4.0)
        // 同心円グラデーション画像を貼り付け
        self.image.paste(img_grad_circle, x: 0, y: 640)
        
        // Cosドーム画像の作成
        let cdom1 = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)
        let cdom2 = CAIMColor(R: 1.0, G: 1.0, B: 1.0, A: 1.0)
        ImageToolBox.gradCosDome(img_grad_dome, color1:cdom1, color2:cdom2)
        // Cos同心円グラデーション画像を貼り付け
        self.image.paste(img_grad_dome, x: 320, y: 640)
        
        // 画面を更新
        redraw()
    
    }
    
}



