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

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct VertexInfo {
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
    private var pl_circle:CAIMMetalRenderPipeline?  // パイプライン
    private var pl_ring:CAIMMetalRenderPipeline?    // パイプライン
    
    private var mat:Matrix4x4 = .identity                            // 変換行列
    private var circles = CAIMQuadrangles<VertexInfo>.init(count: 100)   // 円用４頂点メッシュ群
    private var rings = CAIMQuadrangles<VertexInfo>(count: 100)      // リング用４頂点メッシュ群
    
    // パーティクル情報配列
    private var circle_parts = [Particle]()     // 円用パーティクル情報
    private var ring_parts   = [Particle]()     // リング用パーティクル情報
    
    // 円描画の準備関数
    private func setupCircles() {
        // シェーダを指定してパイプラインの作成
        pl_circle = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragCircleCosCurve")
        pl_circle?.blend_type = .alpha_blend
        
        // 円のパーティクル情報配列を作る
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for _ in 0 ..< circles.count {
            var p:Particle = Particle()
            
            p.pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
            p.rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
            p.radius = CAIMRandom(100.0)
            p.life = CAIMRandom()
            
            circle_parts.append(p)
        }
    }
    
    // リング描画の準備関数
    private func setupRings() {
        // リング用のパイプラインの作成
        pl_ring = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragRing")
        pl_ring?.blend_type = .alpha_blend
        
        // リング用のパーティクル情報を作る
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for _ in 0 ..< rings.count {
            var p:Particle = Particle()
            
            p.pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
            p.rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
            p.radius = CAIMRandom(100.0)
            p.life = CAIMRandom()
            
            ring_parts.append(p)
        }
    }
    
    // 円のパーティクル情報の更新
    private func updateCircles() {
        // パーティクル情報の更新
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for i:Int in 0 ..< circle_parts.count {
            // パーティクルのライフを減らす(3秒間)
            circle_parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if(circle_parts[i].life <= 0.0) {
                circle_parts[i].pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
                circle_parts[i].rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
                circle_parts[i].radius = CAIMRandom(100.0)
                circle_parts[i].life = 1.0
            }
        }
    }
    
    // 円のパーティクル情報から頂点メッシュ情報を更新
    private func genCirclesMesh() {
        for i:Int in 0 ..< circles.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p:Particle = circle_parts[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点0
            circles[i][0].pos  = Vec4(x-r, y-r, 0, 1)
            circles[i][0].uv   = Vec2(-1.0, -1.0)
            circles[i][0].rgba = rgba
            // 四角形メッシュi個目の頂点1
            circles[i][1].pos  = Vec4(x+r, y-r, 0, 1)
            circles[i][1].uv   = Vec2(1.0, -1.0)
            circles[i][1].rgba = rgba
            // 四角形メッシュi個目の頂点2
            circles[i][2].pos  = Vec4(x-r, y+r, 0, 1)
            circles[i][2].uv   = Vec2(-1.0, 1.0)
            circles[i][2].rgba = rgba
            // 四角形メッシュi個目の頂点3
            circles[i][3].pos  = Vec4(x+r, y+r, 0, 1)
            circles[i][3].uv   = Vec2(1.0, 1.0)
            circles[i][3].rgba = rgba
        }
    }
    
    // 円の描画
    private func drawCircles(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl_circle)
        // CPUメモリからGPUバッファを作成し、シェーダ番号をリンクする
        renderer.link(circles.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(circlesを渡すと四角形メッシュの中に丸を描く)
        renderer.draw(circles)
    }
    
    // リングのパーティクル情報の更新
    private func updateRings() {
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        // リング用のパーティクル情報の更新
        for i:Int in 0 ..< ring_parts.count {
            // パーティクルのライフを減らす(3秒間)
            ring_parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if(ring_parts[i].life <= 0.0) {
                ring_parts[i].pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
                ring_parts[i].rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
                ring_parts[i].radius = CAIMRandom(100.0)
                ring_parts[i].life = 1.0
            }
        }
    }
    
    // リングのパーティクル情報から頂点メッシュ情報を更新
    private func genRingsMesh() {
        // リングの全ての点の情報を更新
        for i:Int in 0 ..< rings.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p:Particle = ring_parts[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点0
            rings[i][0].pos  = Vec4(x-r, y-r, 0, 1)
            rings[i][0].uv   = Vec2(-1.0, -1.0)
            rings[i][0].rgba = rgba
            // 四角形メッシュi個目の頂点1
            rings[i][1].pos  = Vec4(x+r, y-r, 0, 1)
            rings[i][1].uv   = Vec2(1.0, -1.0)
            rings[i][1].rgba = rgba
            // 四角形メッシュi個目の頂点2
            rings[i][2].pos  = Vec4(x-r, y+r, 0, 1)
            rings[i][2].uv   = Vec2(-1.0, 1.0)
            rings[i][2].rgba = rgba
            // 四角形メッシュi個目の頂点3
            rings[i][3].pos  = Vec4(x+r, y+r, 0, 1)
            rings[i][3].uv   = Vec2(1.0, 1.0)
            rings[i][3].rgba = rgba
        }
    }
    
    // リングの描画
    private func drawRings(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl_ring)
        // CPUの頂点メッシュメモリからGPUバッファを作成し、シェーダ番号をリンクする
        renderer.link(rings.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quad
        renderer.draw(rings)
    }
    
    // 準備関数
    override func setup() {
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat = Matrix4x4.pixelProjection(CAIMScreenPixel)
        // 円描画の準備
        setupCircles()
        // リング描画の準備
        setupRings()
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // 円情報の更新
        updateCircles()
        // 円情報で頂点メッシュ情報を更新
        genCirclesMesh()
        // 円の描画
        drawCircles(renderer: renderer)
        
        // リング情報の更新
        updateRings()
        // リング情報で頂点メッシュ情報を更新
        genRingsMesh()
        // リングの描画
        drawRings(renderer: renderer)
    }
}


