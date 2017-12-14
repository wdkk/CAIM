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
import ARKit

// The max number anchors our uniform buffer will hold
let kMaxAnchorInstanceCount: Int = 64
// バッファID番号
let ID_VERTEX:Int = 0
let ID_SHARED_UNIFORMS:Int = 1
let ID_UNIFORMS:Int = 2

struct SharedUniforms : CAIMBufferAllocatable {
    var projectionMatrix:Matrix4x4 = .identity
    var viewMatrix:Matrix4x4 = .identity
    // Lighting Properties
    var ambientLightColor:Float3 = .zero
    var directionalLightDirection:Float3 = .zero
    var directionalLightColor:Float3 = .zero
    var materialShininess:Float = 0.0
}

struct InstanceUniforms : CAIMBufferAllocatable {
    var model:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController, ARSessionDelegate
{
    private var render_3d:CAIMMetalRenderer?
    
    private var uniforms:[InstanceUniforms] = [InstanceUniforms].init(repeating: InstanceUniforms(), count: 64)
    private var mesh = CAIMMetalMesh(with:"realship.obj", at:ID_VERTEX)
    private var texture:CAIMMetalTexture = CAIMMetalTexture(with:"shipDiffuse.png")
    private var instanceCount: Int = 0
    
    private func setup3D() {

    }
    
    // 3D情報の描画
    private func draw3D(on metalView:CAIMMetalView) {
        guard instanceCount > 0 else { return }
        
    }
    
    //////
    var ar_session:ARSession?
    var ar_capture:CAIMARCapture?
    var sharedUniforms:SharedUniforms = SharedUniforms()
    
    func setupAR() {

    }
    
    func updateSharedUniforms(frame: ARFrame) {

    }
    
    func updateAnchors(frame: ARFrame) {

    }
    
    /////////////////
    // ビューコントローラから去る時の処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    // 準備関数
    override func setup() {

    }
    
    // 繰り返し処理関数
    override func update(metalView:CAIMMetalView) {

    }
    
    override func touchPressed() {

    }
}

