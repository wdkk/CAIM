//
// CAIMMetalRenderer.swift
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
import Metal
import QuartzCore

class CAIMMetalRenderer
{
    public private(set) static weak var current:CAIMMetalRenderer?
    
    private weak var _metal_view:CAIMMetalView?
    private var _drawable:CAMetalDrawable?
    private var _render_pass_desc:MTLRenderPassDescriptor?
    private var _command_buffer:MTLCommandBuffer?
    
    public private(set) var encoder:MTLRenderCommandEncoder?
    public private(set) weak var pipeline:CAIMMetalRenderPipeline?
    
    public var culling:MTLCullMode = .front
    
    private var _bg_color:MTLClearColor? = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public var bgColor:CAIMColor? {
        get { return _bg_color != nil ? CAIMColor(R: Float(_bg_color!.red),
                                                  G: Float(_bg_color!.green),
                                                  B: Float(_bg_color!.blue),
                                                  A: Float(_bg_color!.alpha)) : nil }
        set {
            if(newValue == nil) { _bg_color = nil; return }
            _bg_color = MTLClearColor(red: Double(newValue!.R), green: Double(newValue!.G), blue: Double(newValue!.B), alpha: Double(newValue!.A))
        }
    }
    
    // Metal描画のセッティング
    @discardableResult
    func ready(view:CAIMMetalView) -> Bool {
        _metal_view = view
        if(_metal_view == nil) { print("CAIMMetalView is nil."); return false }
        _drawable = view.metal_layer?.nextDrawable()
        if(_drawable == nil) { print("cannot get Metal drawable."); return false }
        
        // カレントの設定
        CAIMMetalRenderer.current = self
    
        // レンダーパスの属性（コマンドエンコーダの生成に必要）
        _render_pass_desc = MTLRenderPassDescriptor()
        _render_pass_desc?.colorAttachments[0].texture = _drawable!.texture
        _render_pass_desc?.colorAttachments[0].loadAction = self._bg_color != nil ? .clear : .load
        if(self._bg_color != nil) { _render_pass_desc?.colorAttachments[0].clearColor = self._bg_color! }
        _render_pass_desc?.colorAttachments[0].storeAction = .store
        
        // 描画コマンドエンコーダの入力
        _command_buffer = CAIMMetal.command_queue.makeCommandBuffer()
        encoder = _command_buffer?.makeRenderCommandEncoder(descriptor: _render_pass_desc!)
    
        // カリングの設定
        encoder?.setFrontFacing(.counterClockwise)
        encoder?.setCullMode(self.culling)

        return true
    }
    
    // 描画結果の確定（画面へ反映)
    func commit() {
        // コマンドエンコーダの完了
        encoder?.endEncoding()
        // コマンドバッファの確定
        _command_buffer?.present(_drawable!)
        _command_buffer?.commit()
        // コマンドバッファ解放
        _command_buffer = nil
    }
    
    // 使用するパイプラインの設定
    func use(_ pipeline:CAIMMetalRenderPipeline?) {
        self.encoder?.setRenderPipelineState(pipeline!.mtl_pipeline!)
        self.pipeline = pipeline
    }
    
    func link(_ buffer:CAIMMetalBufferBase, to type:CAIMMetalShaderType, at idx:Int) {
        switch(type) {
        case .vertex:
            self.encoder?.setVertexBuffer(buffer.mtlbuf, offset: 0, index: idx)
        case .fragment:
            self.encoder?.setFragmentBuffer(buffer.mtlbuf, offset: 0, index: idx)
        default:
            break
        }
    }
    
    func linkVertexBuffer(_ buffer:CAIMMetalBufferBase, at idx:Int) {
        encoder?.setVertexBuffer(buffer.mtlbuf, offset: 0, index: idx)
    }    
    func linkFragmentBuffer(_ buffer:CAIMMetalBufferBase, at idx:Int) {
        encoder?.setFragmentBuffer(buffer.mtlbuf, offset: 0, index: idx)
    }
    // エンコーダにサンプラを設定
    func linkFragmentSampler(_ sampler:CAIMMetalSampler, at idx:Int) {
        encoder?.setFragmentSamplerState(sampler.metalSampler, index: idx)
    }
    // エンコーダにテクスチャを設定
    func linkFragmentTexture(_ texture:CAIMMetalTexture, at idx:Int) {
        encoder?.setFragmentTexture(texture.metalTexture, index: idx)
    }
    
    func draw<T>(_ shape:CAIMShape<T>) {
        shape.render(by:self)
    }
}

