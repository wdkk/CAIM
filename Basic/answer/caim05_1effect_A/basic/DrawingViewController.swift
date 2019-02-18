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
    
    // パーティクル情報の構造体
    struct Particle {
        var cx:Int = 0
        var cy:Int = 0
        var radius:Int = 0
        var color:CAIMColor = CAIMColor(R: 0.0, G: 0.0, B: 0.0, A: 1.0)
        var step:Float = 0.0
    }
    
    // パーティクル群を保存しておく配列
    var parts:[Particle] = [Particle]()
    
    // 新しいパーティクル情報を作り、返す関数
    func generateParticle() -> Particle {
        let wid:Int = img_all.width
        let hgt:Int = img_all.height
        // 位置(cx,cy)、半径(radius)、色(color)を指定した範囲のランダム値で設定
        var p = Particle()
        p.cx = Int(arc4random()) % wid
        p.cy = Int(arc4random()) % hgt
        p.radius = Int(arc4random()) % 40 + 20
        p.color = CAIMColor(
            R: Float(arc4random() % 1000)/1000.0,
            G: Float(arc4random() % 1000)/1000.0,
            B: Float(arc4random() % 1000)/1000.0,
            A: 1.0)
        // 作成したパーティクル情報を返す
        return p
    }
    
    // 準備
    override func setup() {
        // img_allを白で塗りつぶす
        img_all.fillColor( CAIMColor.white )
        // view_allの画像として、img_allを設定する
        view_all.image = img_all
        // view_allを画面に追加
        self.view.addSubview( view_all )
        
        // パーティクルを20個作成
        for _ in 0 ..< 20 {
            var p = generateParticle()
            p.step = Float(arc4random() % 1000)/1000.0
            parts.append(p)
        }
    }

    // ポーリング
    override func update() {
        // 毎フレームごと、はじめにimg_allを白で塗りつぶす
        img_all.fillColor( CAIMColor.white )
        
        // parts内のパーティクル情報をすべてスキャンする
        for i in 0 ..< parts.count {
            // 1回処理をするごとにstepを0.01足す
            parts[i].step += 0.01
            // stepがマイナスの値の場合処理せず、次のパーティクルに移る
            if(parts[i].step < 0.0) { continue }
            // stepが1.0以上になったら、現在のパーティクル(parts[i])は処理を終えたものとする
            // 次に、parts[i]はgenerateParticle()から新しいパーティクル情報を受け取り、新パーティクルとして再始動する
            // parts[i]のstepを0.0に戻して初期化したのち、この処理は中断して次のパーティクルに移る
            if(parts[i].step >= 1.0) {
                parts[i] = generateParticle()
                parts[i].step = 0.0
                continue
            }
            
            // 不透明度(opacity)はstep=0.0~0.5の増加に合わせて最大まで濃くなり、0.5~1.0までに最小まで薄くなる
            var opacity:Float = 0.0
            if(parts[i].step < 0.5) { opacity = parts[i].step * 2.0 }
            else { opacity = (1.0 - parts[i].step) * 2.0 }
            
            // 半径は基本半径(parts[i].radius)にstepと係数2.0を掛け算する
            let radius:Int = Int(Float(parts[i].radius) * parts[i].step * 2.0)
            
            // パーティクル情報から求めた計算結果を用いてドームを描く
            ImageToolBox.fillDomeFast(img_all, cx: parts[i].cx, cy: parts[i].cy,
                radius: radius, color: parts[i].color, opacity: opacity)
        }
        
        // 画像が更新されている可能性があるので、view_allを再描画して結果を表示
        view_all.redraw()

    }
}



