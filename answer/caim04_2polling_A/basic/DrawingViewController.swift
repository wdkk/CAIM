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
    // 起動時に1度だけ呼ばれる(準備)
    override func setup() {
        // 画面をクリア
        clear()
        // 画面を更新
        redraw()
    }
   
    // 60FPSで繰り返し呼ばれる関数
    override func update() {
        // タッチしているかどうかの反応 = self.touch_pos.countが1つ以上あるとき
        if(self.touch_pos.count > 0) {
           
            for i in 0 ..< self.touch_pos.count {
                let pos = self.touch_pos[i]
            
                // 薄い赤円を描く
                ImageToolBox.fillCircle(self.image, cx: Int(pos.x), cy: Int(pos.y), radius: 20,
                                        color: CAIMColor(R: 1.0, G: 0.0, B: 0.0, A: 1.0), opacity: 0.2)
            }
            
            // 画面を再描画
            redraw()
        }
    }
    
}



