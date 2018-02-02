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
let ID_UNIFORM:Int = 1
let ID_SHARED_UNIFORM:Int = 2

// 1頂点情報の構造体(VertexDescriptorを使うため、CAIMVertexFormatterプロトコルを使用する)
struct Vertex : CAIMVertexFormatter {    
    var pos:Float2 = Float2()
    var rgba:Float4 = Float4()

    // CAIMVertexFormatterで作成を義務付けられる関数: 構造体の型と同じ型をformats: [...]のなかで指定していく
    static func vertexDescriptor(at idx: Int) -> MTLVertexDescriptor {
        return makeVertexDescriptor(at: idx, formats: [.float2, .float4])
    }
}

struct Uniform : CAIMBufferAllocatable {
    var modelMatrix:Matrix4x4 = .identity
}

struct SharedUniform : CAIMBufferAllocatable {
    var viewMatrix:Matrix4x4 = .identity
    var projectionMatrix:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var render_3d:CAIMMetalRenderer?
    
    private var shared_uniform = SharedUniform()
    private var uniform = Uniform()
    private var mesh = CAIMMetalMesh.sphere(at: ID_VERTEX)
    private var texture:CAIMMetalTexture = CAIMMetalTexture(with:"earth.jpg")
    
    private func setup3D() {
        // シェーダを指定してパイプラインレンダラの作成
        render_3d = CAIMMetalRenderer(vertname:"vert3d", fragname:"frag3d")
        // 頂点をどのように使うのかを設定
        render_3d?.vertexDesc = CAIMMetalMesh.vertexDesc(at: ID_VERTEX)
        // カリングの設定
        render_3d?.culling = .front
        render_3d?.blendType = .alphaBlend
    }
    
    // 3D情報の描画
    private func draw3D(on metalView:CAIMMetalView) {
        // パイプラインレンダラで描画開始
        render_3d?.beginDrawing(on: metalView)
        // 使用するバッファと番号をリンクする
        render_3d?.link(mesh.metalVertexBuffer, to:.vertex, at: ID_VERTEX)
        render_3d?.link(uniform.metalBuffer, to:.vertex, at:ID_UNIFORM)
        render_3d?.link(shared_uniform.metalBuffer, to:.vertex, at: ID_SHARED_UNIFORM)
        // 使用するバッファと番号をリンク(フラグメントシェーダ)
        render_3d?.link(shared_uniform.metalBuffer, to:.fragment, at: ID_SHARED_UNIFORM)
        // テクスチャの読み込みと設定・サンプラの設定
        render_3d?.linkFragmentSampler(CAIMMetalSampler.default, at: 0)
        render_3d?.linkFragmentTexture(texture.metalTexture, at: 0)
        // GPU描画実行
        render_3d?.draw(mesh)
    }
    
    // 準備関数
    override func setup() {
        // 3D描画の準備
        setup3D()
    }
    
    // 繰り返し処理関数
    var move:Float = 0.0
    override func update(metalView:CAIMMetalView) {
        metalView.clearColor = CAIMColor(R: 0.88, G: 0.88, B: 0.88, A: 1.0)
        
        let aspect = Float(CAIM.screenPixel.width / CAIM.screenPixel.height)
        
        let trans  = Matrix4x4.translate(0.0, 0.0, 0.0)
        let rotate_y = Matrix4x4.rotateY(byAngle: move.toRadian)
        move += 0.5
        
        uniform.modelMatrix = trans * rotate_y
        
        shared_uniform.viewMatrix = Matrix4x4.translate(0.0, 0.0, -10.0)
        shared_uniform.projectionMatrix = Matrix4x4.perspective(aspect: aspect, fieldOfViewY: 60.0, near: 0.01, far: 1000.0)
        
        // 3Dの描画
        draw3D(on:metalView)
    }
}

