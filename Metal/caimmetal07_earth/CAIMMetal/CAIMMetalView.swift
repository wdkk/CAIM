//
// CAIMMetalView.swift
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

public class CAIMMetalView: CAIMView
{    
    // Metal Objects
    private(set) var drawable:CAMetalDrawable?
    private(set) var commandBuffer:MTLCommandBuffer?
    private(set) var encoder:MTLRenderCommandEncoder?
    // レンダーパスディスクリプター
    private var _render_pass_desc:MTLRenderPassDescriptor = MTLRenderPassDescriptor()
    // デプス
    var depthTexture:MTLTexture?
    var sampleCount:Int = 1
    // Metalレイヤー
    private var _metal_layer:CAMetalLayer?
    var metalLayer:CAMetalLayer? { return _metal_layer }
    // クリアカラー
    public var clearColor:CAIMColor = .white
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        initializeMetal()
    }

    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // Metalの初期化 / Metal Layerの準備
    private func initializeMetal() {
        // layer's frame
        _metal_layer = CAMetalLayer()
        _metal_layer?.device = CAIMMetal.device
        _metal_layer?.pixelFormat = .bgra8Unorm
        _metal_layer?.framebufferOnly = false
        _metal_layer?.frame = self.bounds
        _metal_layer?.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(_metal_layer!)
    }
    
    private func makeEncoder(color:CAIMColor) {
        // レンダーパスディスクリプタの設定
        setupRenderPassDescriptor(drawable: drawable!, color: color)
        // デプステクスチャの設定
        setDepthTexture(drawable: drawable!)
        // エンコーダ生成
        encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: _render_pass_desc)
    }
    
    // Metal描画のセッティング
    @discardableResult
    public func ready(completion:@escaping ()->() = {}) -> Bool {
        drawable = self.metalLayer?.nextDrawable()
        if(drawable == nil) { print("cannot get Metal drawable."); return false }
        
        // 描画コマンドエンコーダ
        commandBuffer = CAIMMetal.commandQueue.makeCommandBuffer()
        commandBuffer!.addCompletedHandler{ commandBuffer in
            completion()
        }
        
        // エンコーダの生成
        makeEncoder(color:self.clearColor)
        
        return true
    }
    
    public func project() {
        encoder?.endEncoding()
        makeEncoder(color:.clear)
    }
    
    // 描画結果の確定（画面へ反映)
    public func commit() {
        encoder?.endEncoding()
        
        if(commandBuffer != nil) {
            // コマンドバッファを画面テクスチャへ反映
            commandBuffer?.present(drawable!)
            // コマンドバッファの確定
            commandBuffer?.commit()
            // コマンドバッファ解放
            commandBuffer = nil
        }
    }
    
    private func setDepthTexture(drawable:CAMetalDrawable) {
        // depthテクスチャの設定
        let depth_desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float_stencil8,
                                                                  width: drawable.texture.width,
                                                                  height: drawable.texture.height,
                                                                  mipmapped: false)
        depth_desc.textureType = (sampleCount > 1) ? .type2DMultisample : .type2D
        depth_desc.sampleCount = sampleCount
        depth_desc.usage = .renderTarget
        // まだテクスチャメモリが生成されていない場合、もしくはサイズが変更された場合、生成する
        if(depthTexture == nil || depthTexture!.width != depth_desc.width || depthTexture!.height != depth_desc.height) {
            depthTexture = CAIMMetal.device.makeTexture(descriptor: depth_desc)
        }
        _render_pass_desc.depthAttachment.texture = depthTexture
        _render_pass_desc.depthAttachment.loadAction = .clear
        _render_pass_desc.depthAttachment.storeAction = .dontCare
        _render_pass_desc.depthAttachment.clearDepth = 1.0
        
        _render_pass_desc.stencilAttachment.texture = depthTexture
        _render_pass_desc.stencilAttachment.loadAction = .clear
        _render_pass_desc.stencilAttachment.storeAction = .dontCare
        _render_pass_desc.stencilAttachment.clearStencil = 0
    }
    
    private func setupRenderPassDescriptor(drawable:CAMetalDrawable, color:CAIMColor) {
        _render_pass_desc.colorAttachments[0].texture = drawable.texture
        _render_pass_desc.colorAttachments[0].loadAction = (color != .clear) ? .clear : .load
        if(color != .clear) { _render_pass_desc.colorAttachments[0].clearColor = clearColor.metalColor }
        _render_pass_desc.colorAttachments[0].storeAction = .store
    }
}
