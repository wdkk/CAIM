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
    // 表示ビューと画像データの変数
    var view_grad_x:CAIMView = CAIMView(x: 0, y: 0, width: 320, height: 320)
    var img_grad_x:CAIMImage = CAIMImage(width:320, height:320)

    var view_grad_y:CAIMView = CAIMView(x: 320, y: 0, width: 320, height: 320)
    var img_grad_y:CAIMImage = CAIMImage(width:320, height:320)

    var view_grad_xy:CAIMView = CAIMView(x: 0, y: 320, width: 320, height: 320)
    var img_grad_xy:CAIMImage = CAIMImage(width:320, height:320)
    
    var view_grad_sin:CAIMView = CAIMView(x: 320, y: 320, width: 320, height: 320)
    var img_grad_sin:CAIMImage = CAIMImage(width:320, height:320)
    
    var view_grad_circle:CAIMView = CAIMView(x: 0, y: 640, width: 320, height: 320)
    var img_grad_circle:CAIMImage = CAIMImage(width:320, height:320)
    
    var view_grad_dome:CAIMView = CAIMView(x: 320, y: 640, width: 320, height: 320)
    var img_grad_dome:CAIMImage = CAIMImage(width:320, height:320)
    
    // はじめに1度だけ呼ばれる関数(アプリの準備)
    override func setup() {
        // 横方向グラデーション画像の作成
        let cx1 = CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0)
        let cx2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        ImageToolBox.gradX(img_grad_x, color1:cx1, color2:cx2)
        // view_grad_xの画像として、img_grad_xを設定する
        view_grad_x.image = img_grad_x
        // view_grad_xを画面に追加
        self.view.addSubview( view_grad_x )
  
        // 縦方向グラデーション画像の作成
        let cy1 = CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0)
        let cy2 = CAIMColor(R: 0.2, G: 0.2, B: 1.0, A: 1.0)
        ImageToolBox.gradY(img_grad_y, color1:cy1, color2:cy2)
        // view_grad_yの画像として、img_grad_yを設定する
        view_grad_y.image = img_grad_y
        // view_grad_yを画面に追加
        self.view.addSubview( view_grad_y )
        
        // 斜め方向グラデーション画像の作成
        let cxy1 = CAIMColor(R: 0.0, G: 0.5, B: 0.0, A: 1.0)
        let cxy2 = CAIMColor(R: 1.0, G: 1.0, B: 0.0, A: 1.0)
        ImageToolBox.gradXY(img_grad_xy, color1:cxy1, color2:cxy2)
        // view_grad_xyの画像として、img_grad_xyを設定する
        view_grad_xy.image = img_grad_xy
        // view_grad_xを画面に追加
        self.view.addSubview( view_grad_xy )
 
        // 横方向Sin波グラデーション画像の作成
        let csin1 = CAIMColor(R: 1.0, G: 1.0, B: 1.0, A: 1.0)
        let csin2 = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)
        ImageToolBox.gradSin(img_grad_sin, color1:csin1, color2:csin2, k: 4.0)
        // view_grad_sinの画像として、img_grad_sinを設定する
        view_grad_sin.image = img_grad_sin
        // view_grad_sinを画面に追加
        self.view.addSubview( view_grad_sin )
        
        // 同心円グラデーション画像の作成
        let ccir1 = CAIMColor(R: 1.0, G: 0.5, B: 0.0, A: 1.0)
        let ccir2 = CAIMColor(R: 1.0, G: 1.0, B: 1.0, A: 1.0)
        ImageToolBox.gradSinCircle(img_grad_circle, color1:ccir1, color2:ccir2, k:4.0)
        // view_grad_circleの画像として、img_grad_circleを設定する
        view_grad_circle.image = img_grad_circle
        // view_grad_circleを画面に追加
        self.view.addSubview( view_grad_circle )
        
        // Cosドーム画像の作成
        let cdom1 = CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0)
        let cdom2 = CAIMColor(R: 1.0, G: 1.0, B: 1.0, A: 1.0)
        ImageToolBox.gradCosDome(img_grad_dome, color1:cdom1, color2:cdom2)
        // view_grad_domeの画像として、img_grad_domeを設定する
        view_grad_dome.image = img_grad_dome
        // view_grad_domeを画面に追加
        self.view.addSubview( view_grad_dome )
    
    }
    
}



