//
// ImageToolBox.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Foundation

// 画像処理ツールクラス
class ImageToolBox
{
    // 画像全体を赤で塗りつぶす関数
    static func fillRed(_ img:CAIMImage) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // (y,x)=(0,0)の1ピクセルの色を塗る
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                mat[y][x].R = 1.0
                mat[y][x].G = 0.0
                mat[y][x].B = 0.0
                mat[y][x].A = 1.0
            }
        }
    }
    
    // 画像全体を指定した色で塗りつぶす関数
    static func fillColor(_ img:CAIMImage, color:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                mat[y][x].R = color.R
                mat[y][x].G = color.G
                mat[y][x].B = color.B
                mat[y][x].A = color.A
            }
        }
    }
    
    // 2色塗り
    static func fill2div(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                if(x < wid / 2) { // 横方向に左半分までの場合
                    // 左半分まではcolor1を設定
                    mat[y][x].R = color1.R
                    mat[y][x].G = color1.G
                    mat[y][x].B = color1.B
                    mat[y][x].A = color1.A
                }
                else {   // それ以外の場合
                    // 右半分はcolor2を設定
                    mat[y][x].R = color2.R
                    mat[y][x].G = color2.G
                    mat[y][x].B = color2.B
                    mat[y][x].A = color2.A
                }
            }
        }
    }
    
    // 4色塗り
    static func fill4div(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor, color3:CAIMColor, color4:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                if(x < wid / 2 && y < hgt / 2) {
                    // 左上にcolor1を設定
                    mat[y][x].R = color1.R
                    mat[y][x].G = color1.G
                    mat[y][x].B = color1.B
                    mat[y][x].A = color1.A
                }
                else if(x < wid / 2 && y >= hgt / 2) {
                    // 左下にcolor2を設定
                    mat[y][x].R = color2.R
                    mat[y][x].G = color2.G
                    mat[y][x].B = color2.B
                    mat[y][x].A = color2.A
                }
                else if(x < wid / 2 && y < hgt / 2) {
                    // 右上にcolor3を設定
                    mat[y][x].R = color3.R
                    mat[y][x].G = color3.G
                    mat[y][x].B = color3.B
                    mat[y][x].A = color3.A
                }
                else {
                    // 右下にcolor4を設定
                    mat[y][x].R = color4.R
                    mat[y][x].G = color4.G
                    mat[y][x].B = color4.B
                    mat[y][x].A = color4.A
                }
            }
        }
    }
    
    // チェッカーボード
    static func checkerBoard(_ img:CAIMImage, color1:CAIMColor, color2:CAIMColor) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                if( (x / 32 + y / 32) % 2 == 0 ) {
                    mat[y][x].R = color1.R
                    mat[y][x].G = color1.G
                    mat[y][x].B = color1.B
                    mat[y][x].A = color1.A
                }
                else {
                    mat[y][x].R = color2.R
                    mat[y][x].G = color2.G
                    mat[y][x].B = color2.B
                    mat[y][x].A = color2.A
                }
            }
        }
    }
    
}
