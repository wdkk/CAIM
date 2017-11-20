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
    // パーティクル情報の構造体
    struct Particle {
        var cx:Int = 0
        var cy:Int = 0
        var radius:Int = 0
        var color:CAIMColor = CAIMColor(R: 0.0, G: 0.0, B: 0.0, A: 1.0)
        var step:Float = 0.0
    }
    
    // パーティクルの変数
    var parts:[Particle] = [Particle]()
    
    // パーティクル情報を作る関数
    func generateParticle() -> Particle {
        let wid:Int = self.image.width
        let hgt:Int = self.image.height
        
        var p = Particle()
        p.cx = Int(arc4random()) % wid
        p.cy = Int(arc4random()) % hgt
        p.radius = Int(arc4random()) % 40 + 20
        p.color = CAIMColor(
            R: Float(arc4random() % 1000)/1000.0,
            G: Float(arc4random() % 1000)/1000.0,
            B: Float(arc4random() % 1000)/1000.0,
            A: 1.0)
        return p
    }
    
    // 準備
    override func setup() {
        // パーティクルの作成
        for _ in 0 ..< 20 {
            var p = generateParticle()
            p.step = Float(arc4random() % 1000)/1000.0
            parts.append(p)
        }
        
        clear()        // 画面をクリア
        redraw()       // 画面を更新
    }

    // ポーリング
    override func update() {
        clear() // 毎回クリア
        
        // parts内のパーティクル情報をすべてスキャンする
        let count:Int = parts.count
        for i in 0 ..< count {
            parts[i].step += 0.01    // 1回処理をするごとにstepを0.01足す
            // stepがマイナスの値の場合処理しない
            if(parts[i].step < 0.0) { continue }
            // stepが1.0以上になったら0.0に戻す
            if(parts[i].step >= 1.0) {
                parts[i] = generateParticle()
                parts[i].step = 0.0
                continue
            }
            
            var opacity:Float = 0.0
            if(parts[i].step < 0.5) { opacity = parts[i].step * 2.0 }
            else { opacity = (1.0-parts[i].step) * 2.0 }
            
            let radius:Int = Int(Float(parts[i].radius) * parts[i].step * 2.0)
            
            ImageToolBox.fillDomeFast(self.image, cx: parts[i].cx, cy: parts[i].cy,
                radius: radius, color: parts[i].color, opacity: opacity)
        }
        
        redraw()    // 画面を更新
        
        CAIMFPS()
    }
    
}



