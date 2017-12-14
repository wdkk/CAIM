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
let ID_VERTEX:Int = 0
let ID_UNIFORMS:Int = 1

// 1頂点情報の構造体
struct Vertex {
    var pos:Float4 = Float4()
    var rgba:Float4 = Float4()
    var tex_coord:Float2 = Float2()
}

struct Uniforms : CAIMBufferAllocatable {
    var view:Matrix4x4 = .identity
    var model:Matrix4x4 = .identity
    var projection:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var render_3d:CAIMMetalRenderer?     // パイプラインレンダラ
    private var uniforms:Uniforms = Uniforms()   // 行列群
    private let texture:CAIMMetalTexture = CAIMMetalTexture(with:"LilyNoAlpha.png")
    private var cubes = CAIMPanelCubes<Vertex>(count: 1)
    
    private func setup3D() {
        // シェーダを指定してパイプラインの作成
        render_3d = CAIMMetalRenderer(vertname:"vertPers", fragname:"fragStandard")
        // アルファブレンドを無効にする
        render_3d?.blendType = .none
        // デプスを有効にする
        render_3d?.depthCompare = .less
        render_3d?.depthEnabled = true
        
        let red   = CAIMColor(1, 0, 0, 1).float4
        let green = CAIMColor(0, 1, 0, 1).float4
        let blue  = CAIMColor(0, 0, 1, 1).float4
        let gray  = CAIMColor(0.5, 0.5, 0.5, 1.0).float4
        
        // キューブ情報をセットすると、コールバック関数で各頂点の情報が繰り返し送られてくるので、
        // 引数のinfoから情報を抜き出し、Vertex構造体に値を詰めて返すようにする。
        cubes.set(idx: 0, pos: Float3(0, 0, 0), size: 2.0) { (idx:Int, info:CAIMPanelCubeParam) -> Vertex in
            var vi       = Vertex()
            vi.pos       = info.pos
            vi.tex_coord = info.uv
            switch(info.side) {
            case .front: vi.rgba = red
            case .left:  vi.rgba = green
            case .right: vi.rgba = blue
            default: vi.rgba = gray
            }
            return vi
        }
    }
    
    // 3D情報の描画
    private func draw3D(on metalView:CAIMMetalView) {
        // パイプラインレンダラで描画開始
        render_3d?.beginDrawing(on: metalView)
        // 使用するバッファと番号をリンクする
        render_3d?.link(cubes.metalBuffer, to:.vertex, at: ID_VERTEX)
        render_3d?.link(uniforms.metalBuffer, to:.vertex, at:ID_UNIFORMS)
        // テクスチャの読み込みと設定・サンプラの設定
        render_3d?.linkFragmentSampler(CAIMMetalSampler.default, at: 0)
        render_3d?.linkFragmentTexture(texture.metalTexture, at: 0)
        // GPU描画実行
        render_3d?.draw(cubes)
    }
    
    // 準備関数
    override func setup() {
        // 画面のアスペクト比を計算
        let aspect = Float32(CAIM.screenPixel.width / CAIM.screenPixel.height)

        // ビュー行列(平行移動)
        uniforms.view = Matrix4x4.translate(0, 0, -10)
        // モデル行列(回転)
        uniforms.model = Matrix4x4.rotate(axis: Float4(1.0, 1.0, 0.0, 1.0), byAngle: -30.toRadian)
        // 透視投影行列
        uniforms.projection = Matrix4x4.perspective(aspect: aspect, fieldOfViewY: 60.0, near: 0.01, far: 100.0)
        
        // 3D描画の準備
        setup3D()
    }
    
    // 繰り返し処理関数
    override func update(metalView:CAIMMetalView) {
        // 円の描画
        draw3D(on:metalView)
    }
}

