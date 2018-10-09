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

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Metal
import QuartzCore

public class CAIMMetalView: CAIMView, CAIMMetalViewProtocol
{
    // UI
    public private(set) lazy var metalLayer:CAMetalLayer = CAMetalLayer()
    // デプス
    public private(set) var depthState:CAIMMetalDepthState = CAIMMetalDepthState()
    public private(set) var depthTexture:MTLTexture?
    // クリアカラー
    public var clearColor:CAIMColor = .white
    // カリング
    public var culling:MTLCullMode = .none
    // デプス判定
    public var depthCompare:MTLCompareFunction = .always
    public var depthEnabled:Bool = false
    
    public override var bounds:CGRect {
        didSet { metalLayer.frame = self.bounds }
    }
    
    public override var frame:CGRect {
        didSet { metalLayer.frame = self.bounds }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupMetal()
    }
    
    public override init(pixelFrame pfrm: CGRect) {
        super.init(pixelFrame: pfrm)
        setupMetal()
    }
    
    public override init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(x: x, y: y, width: width, height: height)
        setupMetal()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // Metalの初期化 / Metal Layerの準備
    private func setupMetal() {
        metalLayer.device = CAIMMetal.device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = false
        metalLayer.frame = self.bounds
        metalLayer.contentsScale = UIScreen.main.scale
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
        let depth_stencil_state = CAIMMetal.device?.makeDepthStencilState( descriptor: depth_desc )
        encoder.setDepthStencilState( depth_stencil_state )
    }
    
    // Metalコマンドの開始(CAIMMetalViewから呼び出せる簡易版。本体はCAIMMetal.execute)
    public func execute( preRenderFunc:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                         renderFunc:( _ renderEncoder:MTLRenderCommandEncoder )->(),
                         postRenderFunc:( _ commandBuffer:MTLCommandBuffer )->() = { _ in } )
    {
        CAIMMetal.execute(
        prev: preRenderFunc,
        main: { ( commandBuffer:MTLCommandBuffer ) in
            self.beginDraw( commandBuffer:commandBuffer, renderFunc:renderFunc )
        },
        post: postRenderFunc )
    }
    
    @discardableResult
    public func beginDraw( commandBuffer command_buffer:MTLCommandBuffer,
                           renderFunc:( _ renderEncoder:MTLRenderCommandEncoder )->() ) -> Bool {
        if( metalLayer.bounds.width < 1 || metalLayer.bounds.height < 1 ) { return false }
        
        guard let drawable:CAMetalDrawable = metalLayer.nextDrawable() else {
            print("cannot get Metal drawable.")
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
            print("don't get RenderCommandEncoder.")
            return false
        }
        
        // エンコーダの整備
        treatEncoder( &encoder )
        // 現在のエンコーダを更新
        CAIMMetal.currentRenderEncoder = encoder
        
        // 指定された関数オブジェクトの実行
        renderFunc( encoder )
        
        // エンコーダの終了
        encoder.endEncoding()
        
        // コマンドバッファを画面テクスチャへ反映
        command_buffer.present( drawable )
        
        return true
    }
    
    public func makeDepthTexture( drawable:CAMetalDrawable, depthDesc depth_desc:MTLTextureDescriptor, depthState depth_state:CAIMMetalDepthState ) {
        // まだテクスチャメモリが生成されていない場合、もしくはサイズが変更された場合、新しいテクスチャを生成する
        if(depthTexture == nil || depthTexture!.width != depth_desc.width || depthTexture!.height != depth_desc.height) {
            depthTexture = CAIMMetal.device?.makeTexture( descriptor: depth_desc )
        }
    }
}

#endif
