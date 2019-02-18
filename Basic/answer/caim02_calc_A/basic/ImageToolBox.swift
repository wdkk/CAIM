//
// ImageToolBox.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
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
    
    // 縦方向グラデーションを作る関数
    static func gradY(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                // 2色を混ぜる係数: y方向の位置によって計算 (α = 0.0~1.0)
                let alpha = Float(y) / Float(hgt)
                
                // C = A(1.0-α) + Bα
                mat[y][x].R = color1.R * (1.0-alpha) + color2.R * alpha
                mat[y][x].G = color1.G * (1.0-alpha) + color2.G * alpha
                mat[y][x].B = color1.B * (1.0-alpha) + color2.B * alpha
                mat[y][x].A = color1.A * (1.0-alpha) + color2.A * alpha
            }
        }
    }
    
    // 斜めのグラデーション
    static func gradXY(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                // 2色を混ぜる係数xとyを混ぜて計算 (α = 0.0~1.0)
                let alpha = Float(x+y) / Float(wid+hgt)

                // 係数に合わせて色を混ぜる
                mat[y][x].R = color1.R * (1.0-alpha) + color2.R * alpha
                mat[y][x].G = color1.G * (1.0-alpha) + color2.G * alpha
                mat[y][x].B = color1.B * (1.0-alpha) + color2.B * alpha
                mat[y][x].A = color1.A * (1.0-alpha) + color2.A * alpha
            }
        }
    }
    
    // グラデーションSin(引数kは波を打つ回数)
    static func gradSin(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor, k:Float) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                // 2色を混ぜる係数: x座標をsinカーブ角度に用いて計算
                let sinv  = sin(k * Float(x)/Float(wid) * Float(2*Double.pi))   // sin = -1.0 ~ 1.0
                let alpha = (sinv + 1.0) / 2.0                             // α = 0.0 ~ 1.0
                
                // C = A(1.0-α) + Bα
                mat[y][x].R = color1.R * (1.0-alpha) + color2.R * alpha
                mat[y][x].G = color1.G * (1.0-alpha) + color2.G * alpha
                mat[y][x].B = color1.B * (1.0-alpha) + color2.B * alpha
                mat[y][x].A = color1.A * (1.0-alpha) + color2.A * alpha
            }
        }
    }
    
    // グラデーションSin(引数kは波を打つ回数)
    static func gradSinCircle(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor, k:Float) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // 中心座標(cx, cy)
        let cx = wid / 2
        let cy = hgt / 2
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                // 2色を混ぜる係数: 現在の(x,y)座標が中心(cx,cy)とどれくらいの距離にあるのか求める
                let dx = Float(x-cx)
                let dy = Float(y-cy)
                let dist = sqrt(dx * dx + dy * dy)  // 中心との距離(単位はピクセル)
                let sinv  = sin(k * dist/Float(wid) * Float(2*Double.pi))   // 中心から波が広がるようにするため、距離distを用いてsin値を計算
                let alpha = (sinv + 1.0) / 2.0                         // α = 0.0 ~ 1.0
                
                // C = A(1.0-α) + Bα
                mat[y][x].R = color1.R * (1.0-alpha) + color2.R * alpha
                mat[y][x].G = color1.G * (1.0-alpha) + color2.G * alpha
                mat[y][x].B = color1.B * (1.0-alpha) + color2.B * alpha
                mat[y][x].A = color1.A * (1.0-alpha) + color2.A * alpha
            }
        }
    }
    
    // Cosドーム型
    static func gradCosDome(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // 中心座標(cx, cy)
        let cx = wid / 2
        let cy = hgt / 2
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                // 2色を混ぜる係数: 現在の(x,y)座標が中心(cx,cy)とどれくらいの距離にあるのか求める
                let dx = Float(x-cx)
                let dy = Float(y-cy)
                let dist = sqrt(dx * dx + dy * dy)  // 中心との距離(単位はピクセル)
                let cosv  = cos(dist/Float(wid/2) * Float.pi*0.5) // 画面の端でcos(0.5π)になるようにする
                let alpha = min(1.0-cosv, 1.0)          // α = 1.0(cos0) ~ 0.0(cos0.5π)
                
                // C = A(1.0-α) + Bα
                mat[y][x].R = color1.R * (1.0-alpha) + color2.R * alpha
                mat[y][x].G = color1.G * (1.0-alpha) + color2.G * alpha
                mat[y][x].B = color1.B * (1.0-alpha) + color2.B * alpha
                mat[y][x].A = color1.A * (1.0-alpha) + color2.A * alpha
            }
        }
    }
    
}
