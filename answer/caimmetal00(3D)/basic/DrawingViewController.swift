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
    var rgba:CAIMColor = CAIMColor()
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl_3d:CAIMMetalRenderPipeline?
    
    private var mat_pers:Matrix4x4 = .identity  // 透視変換行列
    private var cubes = CAIMCubes<VertexInfo>(count: 1)
    private var tris = CAIMTriangles<VertexInfo>(count: 1)
    
    private func setup3D() {
        // シェーダを指定してパイプラインの作成
        pl_3d = CAIMMetalRenderPipeline(vertname:"vertPers", fragname:"fragStandard")
        pl_3d?.blend_type = .alpha_blend
        
        let p = [
            VertexInfo(pos: Vec4(-1.0, 1.0, -10, 1.0), rgba: CAIMColor(1.0, 0.0, 0.0, 1.0)),
            VertexInfo(pos: Vec4(-1.0,-1.0, -10, 1.0), rgba: CAIMColor(0.0, 1.0, 0.0, 1.0)),
            VertexInfo(pos: Vec4( 1.0,-1.0, -10, 1.0), rgba: CAIMColor(0.0, 0.0, 1.0, 1.0)),
            VertexInfo(pos: Vec4( 1.0, 1.0, -10, 1.0), rgba: CAIMColor(0.1, 0.6, 0.4, 1.0)),
            VertexInfo(pos: Vec4(-1.0, 1.0, -10, 1.0), rgba: CAIMColor(1.0, 0.0, 0.0, 1.0)),
            VertexInfo(pos: Vec4( 1.0, 1.0, -10, 1.0), rgba: CAIMColor(0.0, 1.0, 0.0, 1.0)),
            VertexInfo(pos: Vec4(-1.0,-1.0, -10, 1.0), rgba: CAIMColor(0.0, 0.0, 1.0, 1.0)),
            VertexInfo(pos: Vec4( 1.0,-1.0, -10, 1.0), rgba: CAIMColor(0.1, 0.6, 0.4, 1.0))
            ]
        
        let v = [
            p[0],p[1],p[2], p[0],p[2],p[3],   //Front
            p[5],p[7],p[6] ,p[4],p[5],p[6],   //Back
            
            p[4],p[6],p[1] ,p[4],p[1],p[0],   //Left
            p[3],p[2],p[7] ,p[3],p[7],p[5],   //Right
            
            p[4],p[0],p[3] ,p[4],p[3],p[5],   //Top
            p[1],p[6],p[7] ,p[1],p[7],p[2]    //Bot
        ]

        let cube = cubes[0]
        for i in 0 ..< 36 {
            cube[i] = v[i]
        }
    }
    
    // 3D情報の描画
    private func draw3D(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl_3d)
        // 使用するバッファと番号をリンクする
        renderer.link(cubes.metalBuffer, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_pers.metalBuffer, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行
        renderer.draw(cubes)
    }
    
    // 準備関数
    override func setup() {
        let aspect = Float32(CAIMScreenPixel.width / CAIMScreenPixel.height)
        mat_pers = Matrix4x4.perspectiveProjection(aspect: aspect, fieldOfViewY: 60.0, near: 0.1, far: 100.0)
        // 3D描画の準備
        setup3D()
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // 円の描画
        draw3D(renderer: renderer)
    }
}

