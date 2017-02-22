//
// ImageToolBox.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Foundation

// 画像処理ツールクラス
class ImageToolBox
{
    // 横方向グラデーションを作る関数
    static func gradX(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                // 2色を混ぜる係数: x方向の位置によって計算 (α = 0.0~1.0)
                let alpha = Float(x) / Float(wid)
                
                // C = A(1.0-α) + Bα
                mat[y][x].R = color1.R * (1.0-alpha) + color2.R * alpha
                mat[y][x].G = color1.G * (1.0-alpha) + color2.G * alpha
                mat[y][x].B = color1.B * (1.0-alpha) + color2.B * alpha
                mat[y][x].A = color1.A * (1.0-alpha) + color2.A * alpha
            }
        }
    }
    

}
