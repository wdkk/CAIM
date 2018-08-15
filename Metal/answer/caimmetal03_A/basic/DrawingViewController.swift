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
import simd

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct Vertex {
    var pos:Float2 = Float2()
    var uv:Float2 = Float2()
    var rgba:Float4 = Float4()
}

// パーティクル情報
struct Particle {
    var pos:Float2 = Float2()           // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var render_circle:CAIMMetalRenderer?
    private var render_ring:CAIMMetalRenderer?
    
    private var mat:Matrix4x4 = .identity                       // 変換行列
    private var circles = CAIMQuadrangles<Vertex>(count: 100)   // 円用４頂点メッシュ群
    private var rings = CAIMQuadrangles<Vertex>(count: 100)     // リング用４頂点メッシュ群
    
    // パーティクル情報配列
    private var circle_parts = [Particle]()     // 円用パーティクル情報
    private var ring_parts   = [Particle]()     // リング用パーティクル情報
    
    // 円描画の準備関数
    private func setupCircles() {
        // シェーダを指定してパイプラインレンダラの作成
        render_circle = CAIMMetalRenderer(vertname:"vert2d", fragname:"fragCircleCosCurve")
        // アルファブレンドを有効にする
        render_circle?.blendType = .alphaBlend
        // デプスを無効にする
        render_circle?.depthCompare = .always
        render_circle?.depthEnabled = false
        
        // 円のパーティクル情報配列を作る
        let wid = Float(CAIM.screenPixel.width)
        let hgt = Float(CAIM.screenPixel.height)
        for _ in 0 ..< circles.count {
            var p:Particle = Particle()
            
            p.pos = Float2(CAIM.random(wid), CAIM.random(hgt))
            p.rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
            p.radius = CAIM.random(100.0)
            p.life = CAIM.random()
            
            circle_parts.append(p)
        }
    }
    
    // リング描画の準備関数
    private func setupRings() {
        // リング用のレンダラの作成
        render_ring = CAIMMetalRenderer(vertname:"vert2d", fragname:"fragRing")
        // アルファブレンドを有効にする
        render_ring?.blendType = .alphaBlend
        // デプスを無効にする
        render_ring?.depthCompare = .always
        render_ring?.depthEnabled = false
        
        // リング用のパーティクル情報を作る
        let wid = Float(CAIM.screenPixel.width)
        let hgt = Float(CAIM.screenPixel.height)
        for _ in 0 ..< rings.count {
            var p = Particle()
            
            p.pos = Float2(CAIM.random(wid), CAIM.random(hgt))
            p.rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
            p.radius = CAIM.random(100.0)
            p.life = CAIM.random()
            
            ring_parts.append(p)
        }
    }
    
    // 円のパーティクル情報の更新
    private func updateCircles() {
        // パーティクル情報の更新
        let wid = Float(CAIM.screenPixel.width)
        let hgt = Float(CAIM.screenPixel.height)
        for i in 0 ..< circle_parts.count {
            // パーティクルのライフを減らす(3秒間)
            circle_parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if(circle_parts[i].life <= 0.0) {
                circle_parts[i].pos = Float2(CAIM.random(wid), CAIM.random(hgt))
                circle_parts[i].rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
                circle_parts[i].radius = CAIM.random(100.0)
                circle_parts[i].life = 1.0
            }
        }
    }
    
    // 円のパーティクル情報から頂点メッシュ情報を更新
    private func genCirclesMesh() {
        for i in 0 ..< circles.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p = circle_parts[i]
            let x = p.pos.x                   // x座標
            let y = p.pos.y                   // y座標
            let r = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba = p.rgba                 // 色
            rgba.A *= p.life                  // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点0
            circles[i][0].pos  = Float2(x-r, y-r)
            circles[i][0].uv   = Float2(-1.0, -1.0)
            circles[i][0].rgba = rgba.float4
            // 四角形メッシュi個目の頂点1
            circles[i][1].pos  = Float2(x+r, y-r)
            circles[i][1].uv   = Float2(1.0, -1.0)
            circles[i][1].rgba = rgba.float4
            // 四角形メッシュi個目の頂点2
            circles[i][2].pos  = Float2(x-r, y+r)
            circles[i][2].uv   = Float2(-1.0, 1.0)
            circles[i][2].rgba = rgba.float4
            // 四角形メッシュi個目の頂点3
            circles[i][3].pos  = Float2(x+r, y+r)
            circles[i][3].uv   = Float2(1.0, 1.0)
            circles[i][3].rgba = rgba.float4
        }
    }
    
    // 円の描画
    private func drawCircles(on metalView:CAIMMetalView) {
        // パイプライン(シェーダ)の切り替え
        render_circle?.beginDrawing(on: metalView)
        // CPUメモリからGPUバッファを作成し、シェーダ番号をリンクする
        render_circle?.link(circles.metalBuffer, to:.vertex, at:ID_VERTEX)
        render_circle?.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(circlesを渡すと四角形メッシュの中に丸を描く)
        render_circle?.draw(circles)
    }
    
    // リングのパーティクル情報の更新
    private func updateRings() {
        let wid = Float(CAIM.screenPixel.width)
        let hgt = Float(CAIM.screenPixel.height)
        // リング用のパーティクル情報の更新
        for i in 0 ..< ring_parts.count {
            // パーティクルのライフを減らす(3秒間)
            ring_parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if(ring_parts[i].life <= 0.0) {
                ring_parts[i].pos = Float2(CAIM.random(wid), CAIM.random(hgt))
                ring_parts[i].rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
                ring_parts[i].radius = CAIM.random(100.0)
                ring_parts[i].life = 1.0
            }
        }
    }
    
    // リングのパーティクル情報から頂点メッシュ情報を更新
    private func genRingsMesh() {
        // リングの全ての点の情報を更新
        for i in 0 ..< rings.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p = ring_parts[i]
            let x = p.pos.x                   // x座標
            let y = p.pos.y                   // y座標
            let r = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点0
            rings[i][0].pos  = Float2(x-r, y-r)
            rings[i][0].uv   = Float2(-1.0, -1.0)
            rings[i][0].rgba = rgba.float4
            // 四角形メッシュi個目の頂点1
            rings[i][1].pos  = Float2(x+r, y-r)
            rings[i][1].uv   = Float2(1.0, -1.0)
            rings[i][1].rgba = rgba.float4
            // 四角形メッシュi個目の頂点2
            rings[i][2].pos  = Float2(x-r, y+r)
            rings[i][2].uv   = Float2(-1.0, 1.0)
            rings[i][2].rgba = rgba.float4
            // 四角形メッシュi個目の頂点3
            rings[i][3].pos  = Float2(x+r, y+r)
            rings[i][3].uv   = Float2(1.0, 1.0)
            rings[i][3].rgba = rgba.float4
        }
    }
    
    // リングの描画
    private func drawRings(on metalView:CAIMMetalView) {
        // パイプライン(シェーダ)の切り替え
        render_ring?.beginDrawing(on: metalView)
        // CPUの頂点メッシュメモリからGPUバッファを作成し、シェーダ番号をリンクする
        render_ring?.link(rings.metalBuffer, to:.vertex, at:ID_VERTEX)
        render_ring?.link(mat.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quad
        render_ring?.draw(rings)
    }
    
    // 準備関数
    override func setup() {
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat = Matrix4x4.pixelProjection(CAIM.screenPixel)
        // 円描画の準備
        setupCircles()
        // リング描画の準備
        setupRings()
    }
    
    // 繰り返し処理関数
    override func update(metalView: CAIMMetalView) {
        // 円情報の更新
        updateCircles()
        // 円情報で頂点メッシュ情報を更新
        genCirclesMesh()
        // 円の描画
        drawCircles(on:metalView)
        
        // リング情報の更新
        updateRings()
        // リング情報で頂点メッシュ情報を更新
        genRingsMesh()
        // リングの描画
        drawRings(on:metalView)
    }
}


