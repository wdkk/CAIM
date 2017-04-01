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
    private var pl_circle:CAIMMetalRenderPipeline?
    private var pl_ring:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?            // 行列バッファ
    private var circle_quads_buf:CAIMMetalBuffer?   // 頂点バッファ(円を描く四角形)
    private var ring_quads_buf:CAIMMetalBuffer?     // 頂点バッファ(リングを描く四角形)

    // CPU:形状メモリ
    private var circle_quads = CAIMQuadrangles<VertexInfo>()    // 円用メモリ
    private var ring_quads = CAIMQuadrangles<VertexInfo>()      // リング用メモリ
    
    // パーティクル情報配列
    private var circle_parts = [Particle]()     // 円用パーティクル情報
    private var ring_parts   = [Particle]()     // リング用パーティクル情報

    // 円描画の準備関数
    private func setupCircles() {
        // シェーダを指定してパイプラインの作成
        pl_circle = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragCircleCosCurve")
        pl_circle?.blend_type = .alpha_blend
        
        // (GPUバッファ)頂点バッファ(四角形)の作成
        circle_quads_buf = CAIMMetalBuffer(vertice:circle_quads)
        
        // パーティクル情報配列を作る
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for _ in 0 ..< 100 {
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
        
        // (GPUバッファ)頂点バッファ(四角形)の作成
        ring_quads_buf = CAIMMetalBuffer(vertice:ring_quads)
        
        // リング用のパーティクル情報配列を作る
        let wid:Float = Float(CAIMScreenPixel.width)
        let hgt:Float = Float(CAIMScreenPixel.height)
        for _ in 0 ..< 100 {
            var p:Particle = Particle()
            
            p.pos = Vec2(CAIMRandom(wid), CAIMRandom(hgt))
            p.rgba = CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom())
            p.radius = CAIMRandom(100.0)
            p.life = CAIMRandom()
            
            ring_parts.append(p)
        }
    }
    
    // 円情報の更新
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
    
    // 円情報からCPUメモリの更新、GPUメモリに転送
    private func genCirclesBuffer() {
        // パーティクル配列からCPUメモリの作成(circle_parts -> circle_quads)
        circle_quads.resize(count: circle_parts.count)
        let p_circle_quads = circle_quads.pointer
        for i:Int in 0 ..< circle_quads.count {
            // パーティクル情報を展開する
            let p:Particle = circle_parts[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形頂点v0
            p_circle_quads[i].v0.pos  = Vec4(x-r, y-r, 0, 1)
            p_circle_quads[i].v0.uv   = Vec2(-1.0, -1.0)
            p_circle_quads[i].v0.rgba = rgba
            // 四角形頂点v1
            p_circle_quads[i].v1.pos  = Vec4(x+r, y-r, 0, 1)
            p_circle_quads[i].v1.uv   = Vec2(1.0, -1.0)
            p_circle_quads[i].v1.rgba = rgba
            // 四角形頂点v2
            p_circle_quads[i].v2.pos  = Vec4(x-r, y+r, 0, 1)
            p_circle_quads[i].v2.uv   = Vec2(-1.0, 1.0)
            p_circle_quads[i].v2.rgba = rgba
            // 四角形頂点v3
            p_circle_quads[i].v3.pos  = Vec4(x+r, y+r, 0, 1)
            p_circle_quads[i].v3.uv   = Vec2(1.0, 1.0)
            p_circle_quads[i].v3.rgba = rgba
        }
        
        // GPUバッファの内容を更新(circle_quads -> circle_quads_buf)
        circle_quads_buf?.update(vertice: circle_quads)
    }
    
    // 円の描画
    private func drawCircles(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl_circle)
        // 使用するバッファと番号をリンクする
        renderer.link(circle_quads_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡すと四角形を描く)
        renderer.draw(circle_quads)
    }

    // リング情報の更新
    private func updateRings() {
        // パーティクル情報の更新
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
    
    // リング情報からCPUメモリの更新、GPUバッファへの転送
    private func genRingsBuffer() {
        // パーティクル配列からCPUメモリの作成(parts -> quads)
        ring_quads.resize(count: ring_parts.count)
        let p_ring_quads = ring_quads.pointer
        for i:Int in 0 ..< ring_quads.count {
            // パーティクル情報を展開する
            let p:Particle = ring_parts[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形頂点v0
            p_ring_quads[i].v0.pos  = Vec4(x-r, y-r, 0, 1)
            p_ring_quads[i].v0.uv   = Vec2(-1.0, -1.0)
            p_ring_quads[i].v0.rgba = rgba
            // 四角形頂点v1
            p_ring_quads[i].v1.pos  = Vec4(x+r, y-r, 0, 1)
            p_ring_quads[i].v1.uv   = Vec2(1.0, -1.0)
            p_ring_quads[i].v1.rgba = rgba
            // 四角形頂点v2
            p_ring_quads[i].v2.pos  = Vec4(x-r, y+r, 0, 1)
            p_ring_quads[i].v2.uv   = Vec2(-1.0, 1.0)
            p_ring_quads[i].v2.rgba = rgba
            // 四角形頂点v3
            p_ring_quads[i].v3.pos  = Vec4(x+r, y+r, 0, 1)
            p_ring_quads[i].v3.uv   = Vec2(1.0, 1.0)
            p_ring_quads[i].v3.rgba = rgba
        }
        
        // GPUバッファの内容を更新(quads -> quads_buf)
        ring_quads_buf?.update(vertice: ring_quads)
    }
    
    // リングの描画
    private func drawRings(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl_ring)
        // 使用するバッファと番号をリンクする
        renderer.link(ring_quads_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡すと四角形を描く)
        renderer.draw(ring_quads)
    }
    
    // 準備関数
    override func setup() {
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        // 円描画の準備
        setupCircles()
        // リング描画の準備
        setupRings()
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // 円情報の更新
        updateCircles()
        // 円情報からGPUバッファを生成
        genCirclesBuffer()
        // 円の描画
        drawCircles(renderer: renderer)
        
        // リング情報の更新
        updateRings()
        // リング情報からGPUバッファを生成
        genRingsBuffer()
        // リングの描画
        drawRings(renderer: renderer)
    }
}
