//
// LLMetalView.swift
// Lily Project
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Metal
import QuartzCore

open class LLMTLView: LLView, LLMTLViewProtocol
{
    // UI
    public private(set) lazy var metalLayer:CAMetalLayer = CAMetalLayer()
    // デプス
    public private(set) var depthState:LLMTLDepthState = LLMTLDepthState()
    public private(set) var depthTexture:MTLTexture?
    // クリアカラー
    public var clearColor:LLColor = .white
    
    // カリング
    public var culling:MTLCullMode = .none
    // デプス判定
    public var depthCompare:MTLCompareFunction = .always
    public var depthEnabled:Bool = false
    
    open override func setup() {
        super.setup()
        setupMetal()
    }
    
    open override func buildup() {
        super.buildup()
        metalLayer.frame = self.bounds
    }
    
    // Metalの初期化 / Metal Layerの準備
    private func setupMetal() {
        metalLayer.device = LLMTL.device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = false
        metalLayer.frame = self.bounds
        metalLayer.contentsScale = LLSys.retinaScale.cgf
        self.layer.addSublayer( metalLayer )
    }
    
    private func treatEncoder( _ encoder:inout MTLRenderCommandEncoder ) {
        // エンコーダにカリングの設定
        encoder.setFrontFacing( .counterClockwise )
        encoder.setCullMode( culling )
        
        // エンコーダにデプスの設定
        let depth_desc = MTLDepthStencilDescriptor()
        depth_desc.depthCompareFunction = self.depthCompare
        depth_desc.isDepthWriteEnabled = self.depthEnabled
        let depth_stencil_state = LLMTL.device?.makeDepthStencilState( descriptor: depth_desc )
        encoder.setDepthStencilState( depth_stencil_state )
    }
    
    // Metalコマンドの開始(LLMTLViewから呼び出せる簡易版。本体はLLMTL.execute)
    public func execute( preRenderFunc:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                         renderFunc:( _ renderEncoder:MTLRenderCommandEncoder )->(),
                         postRenderFunc:( _ commandBuffer:MTLCommandBuffer )->() = { _ in } )
    {
        LLMTL.execute(
        prev: preRenderFunc,
        main: { ( commandBuffer:MTLCommandBuffer ) in
            self.beginDraw( commandBuffer:commandBuffer, renderFunc:renderFunc )
        },
        post: postRenderFunc )
    }
    
    @discardableResult
    public func beginDraw( commandBuffer command_buffer:MTLCommandBuffer,
                             renderFunc:( _ renderEncoder:MTLRenderCommandEncoder )->() ) -> Bool {
        if( metalLayer.width < 1 || metalLayer.height < 1 ) { return false }
        
        guard let drawable:CAMetalDrawable = metalLayer.nextDrawable() else {
            LLLog("cannot get Metal drawable.")
            return false
        }
        
        // デプステクスチャディスクリプタの設定
        let depth_desc:MTLTextureDescriptor = makeDepthTextureDescriptor( drawable:drawable, depthState:depthState )
        // デプステクスチャの作成
        makeDepthTexture( drawable:drawable, depthDesc:depth_desc, depthState:depthState )
        // レンダーパスディスクリプタの設定
        let r_pass_desc:MTLRenderPassDescriptor = makeRenderPassDescriptor( drawable:drawable, color:clearColor, depthTexture:depthTexture! )
        
        // エンコーダ生成
        guard var encoder:MTLRenderCommandEncoder = command_buffer.makeRenderCommandEncoder( descriptor: r_pass_desc ) else {
            LLLog("don't get RenderCommandEncoder.")
            return false
        }
        
        // エンコーダの整備
        treatEncoder( &encoder )
        // 現在のエンコーダを更新
        LLMTL.currentRenderEncoder = encoder
        
        // 指定された関数オブジェクトの実行
        renderFunc( encoder )
        
        // エンコーダの終了
        encoder.endEncoding()
        
        // コマンドバッファを画面テクスチャへ反映
        command_buffer.present( drawable )
        
        return true
    }
    
    public func makeDepthTexture( drawable:CAMetalDrawable, depthDesc depth_desc:MTLTextureDescriptor, depthState depth_state:LLMTLDepthState ) {
        // まだテクスチャメモリが生成されていない場合、もしくはサイズが変更された場合、新しいテクスチャを生成する
        if(depthTexture == nil || depthTexture!.width != depth_desc.width || depthTexture!.height != depth_desc.height) {
            depthTexture = LLMTL.device?.makeTexture( descriptor: depth_desc )
        }
    }
}

#endif
