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
    // 起動時に1度だけ呼ばれる(準備)
    override func setup() {
        // 画面をクリア
        clear()
        // 画面を更新
        redraw()
    }
    
    /*
    // タッチ開始の時に呼ばれる
    override func touchPressed() {
        // タッチ座標の1つ目を取得する
        let pos = self.touchPos[0]
        
        // 青円を描く
        ImageToolBox.fillCircle(self.image, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
            color: CAIMColor(R: 0.0, G: 0.0, B: 1.0, A: 1.0), opacity: 1.0)
        
        redraw()
    }
    
    // 指でなぞった時に呼ばれる
    override func touchMoved() {
        // タッチ座標の1つ目を取得する
        let pos = self.touchPos[0]

        // 薄い赤円を描く
        ImageToolBox.fillCircle(self.image, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
            color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0), opacity: 0.2)
        
        redraw()
    }
    
    // 指を離した時に呼ばれる
    override func touchReleased() {
        // リリース座標の1つ目を取得する
        let pos = self.releasePos[0]
        
        // 緑円を描く
        ImageToolBox.fillCircle(self.image, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
            color: CAIMColor(R: 0.0, G: 1.0, B: 0.0, A: 1.0), opacity: 1.0)
        
        redraw()
    }
    */
    
    // 指でなぞった時に呼ばれる
    override func touchMoved() {
        // マルチタッチの数
        let count = self.touchPos.count
        
        for i in 0 ..< count {
            let pos = self.touchPos[i]
            
            // 薄い赤円を描く
            ImageToolBox.fillCircle(self.image, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
                color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0), opacity: 0.2)
        }
        
        redraw()
    }
}



