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

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct VertexInfo : Initializable {
    var pos:Vec4 = Vec4()
    var uv:Vec2 = Vec2()
    var rgba:CAIMColor = CAIMColor()
}

// パーティクル情報
struct Particle {
    var pos:Vec2 = Vec2()               // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?        // 行列バッファ
    private var quads_buf:CAIMMetalBuffer?      // 頂点バッファ(四角形)
    
    // CPU:形状メモリ
    private var quads = CAIMQuadrangles<VertexInfo>()
    
    // パーティクル情報配列
    private var parts = [Particle]()
    
    // 準備関数
    override func setup() {
        // シェーダを指定してパイプラインの作成
        pl = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragCircleCosCurve")
        pl?.blend_type = .alpha_blend
        
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        
        // (GPUバッファ)頂点バッファ(四角形)の作成
        quads_buf = CAIMMetalBuffer(vertice:quads)
        
        // パーティクル情報配列を作る
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for _ in 0 ..< 100 {
            var p:Particle = Particle()
            
            p.pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
            p.rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
            p.radius = CAIMRandom(100.0)
            p.life = CAIMRandom()
            
            parts.append(p)
        }
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // パーティクル情報の更新
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for i:Int in 0 ..< parts.count {
            // パーティクルのライフを減らす(3秒間)
            parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if(parts[i].life <= 0.0) {
                parts[i].pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
                parts[i].rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
                parts[i].radius = CAIMRandom(100.0)
                parts[i].life = 1.0
            }
        }
        
        // パーティクル配列からCPUメモリの作成(parts -> quads)
        quads.resize(count: parts.count)
        let p_quads = quads.pointer
        for i:Int in 0 ..< quads.count {
            // パーティクル情報を展開する
            let p:Particle = parts[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形頂点v0
            p_quads[i].v0.pos  = Vec4(x-r, y-r, 0, 1)
            p_quads[i].v0.uv   = Vec2(-1.0, -1.0)
            p_quads[i].v0.rgba = rgba
            // 四角形頂点v1
            p_quads[i].v1.pos  = Vec4(x+r, y-r, 0, 1)
            p_quads[i].v1.uv   = Vec2(1.0, -1.0)
            p_quads[i].v1.rgba = rgba
            // 四角形頂点v2
            p_quads[i].v2.pos  = Vec4(x-r, y+r, 0, 1)
            p_quads[i].v2.uv   = Vec2(-1.0, 1.0)
            p_quads[i].v2.rgba = rgba
            // 四角形頂点v3
            p_quads[i].v3.pos  = Vec4(x+r, y+r, 0, 1)
            p_quads[i].v3.uv   = Vec2(1.0, 1.0)
            p_quads[i].v3.rgba = rgba
        }
        
        // GPUバッファの内容を更新(quads -> quads_buf)
        quads_buf?.update(vertice: quads)
        
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl)
        // 使用するバッファと番号をリンクする
        renderer.link(quads_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡すと四角形を描く)
        renderer.draw(quads)
    }
}
