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


import Foundation
import Metal

public enum CAIMMetalBlendType : Int
{
    case none
    case alphaBlend
}

// Metalパイプラインを持つレンダラ
public class CAIMMetalRenderer
{
    // パイプライン
    internal(set) var metalPipeline:MTLRenderPipelineState?
    // パイプラインディスクリプター
    fileprivate var _render_pipeline_desc:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
    // エンコーダー
    private(set) weak var currentEncoder:MTLRenderCommandEncoder?
    // カリング
    public var culling:MTLCullMode = .none
    // デプス判定
    public var depthCompare:MTLCompareFunction = .less
    // デプス有効
    public var depthEnabled:Bool = true
    // 頂点シェーダー
    public var vertexShader:CAIMMetalShader?
    // フラグメントシェーダー
    public var fragmentShader:CAIMMetalShader?
    // 合成タイプ
    public var blendType:CAIMMetalBlendType = .none
    // 頂点ディスクリプタ
    var vertexDesc:MTLVertexDescriptor? = nil
    
    // 外部からシェーダを指定する
    init(vertex vsh:CAIMMetalShader?, fragment fsh:CAIMMetalShader?, blend:CAIMMetalBlendType = .none) {
        blendType = blend
        vertexShader = vsh
        fragmentShader = fsh
    }
    // 内部にシェーダを持たせる
    init(vertname:String, fragname:String, blend:CAIMMetalBlendType = .none) {
        blendType = blend
        vertexShader = CAIMMetalShader(vertname)
        fragmentShader = CAIMMetalShader(fragname)
    }
    
    private func setupRenderPipelineDesc(on metalView:CAIMMetalView) {
        _render_pipeline_desc.vertexFunction = vertexShader!.function
        _render_pipeline_desc.fragmentFunction = fragmentShader!.function
        // パイプラインdescのデプス・ステンシル情報を設定
        _render_pipeline_desc.vertexDescriptor = vertexDesc
        _render_pipeline_desc.sampleCount = metalView.sampleCount
        _render_pipeline_desc.depthAttachmentPixelFormat = .depth32Float_stencil8
        _render_pipeline_desc.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
        let color_attachment:MTLRenderPipelineColorAttachmentDescriptor = _render_pipeline_desc.colorAttachments[0]
        color_attachment.pixelFormat = .bgra8Unorm
        
        switch(self.blendType) {
        case .none:
            color_attachment.isBlendingEnabled = false
            break
        case .alphaBlend:
            color_attachment.isBlendingEnabled = true
            // 2値の加算方法
            color_attachment.rgbBlendOperation           = .add
            color_attachment.alphaBlendOperation         = .add
            // 入力データ = α
            color_attachment.sourceRGBBlendFactor        = .sourceAlpha
            color_attachment.sourceAlphaBlendFactor      = .sourceAlpha
            // 合成先データ = 1-α
            color_attachment.destinationRGBBlendFactor   = .oneMinusSourceAlpha
            color_attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
    }
    
    private func makePipeline() {
        do {
            metalPipeline = try CAIMMetal.device.makeRenderPipelineState(descriptor: _render_pipeline_desc)
        }
        catch {
            print(error.localizedDescription)
            metalPipeline = nil
        }
    }
        
    private func settingEncoder() {
        // エンコーダにカリングの設定
        currentEncoder?.setFrontFacing(.counterClockwise)
        currentEncoder?.setCullMode(self.culling)
        
        // エンコーダにデプスの設定
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = self.depthCompare
        depthDescriptor.isDepthWriteEnabled = self.depthEnabled
        let depthStencilState = CAIMMetal.device.makeDepthStencilState(descriptor: depthDescriptor)
        currentEncoder?.setDepthStencilState(depthStencilState)
        
        // エンコーダにパイプラインの設定
        currentEncoder?.setRenderPipelineState(metalPipeline!)
    }
    
    func link(_ buffer:MTLBuffer, to type:CAIMMetalShaderType, at idx:Int) {
        switch(type) {
        case .vertex:   currentEncoder?.setVertexBuffer(buffer, offset: 0, index: idx)
        case .fragment: currentEncoder?.setFragmentBuffer(buffer, offset: 0, index: idx)
        default:
            break
        }
    }
    
    func linkVertexBuffer(_ buffer:MTLBuffer, at idx:Int) {
        currentEncoder?.setVertexBuffer(buffer, offset: 0, index: idx)
    }
    func linkFragmentBuffer(_ buffer:MTLBuffer, at idx:Int) {
        currentEncoder?.setFragmentBuffer(buffer, offset: 0, index: idx)
    }
    func linkFragmentSampler(_ sampler:MTLSamplerState, at idx:Int) {
        currentEncoder?.setFragmentSamplerState(sampler, index: idx)
    }
    func linkFragmentTexture(_ texture:MTLTexture, at idx:Int) {
        currentEncoder?.setFragmentTexture(texture, index: idx)
    }
    
    // レンダラの準備を行い描画を開始
    func beginDrawing(on metalView:CAIMMetalView) {
        // エンコーダの指定
        currentEncoder = metalView.encoder
        
        // パイプラインディスクリプタの準備
        setupRenderPipelineDesc(on:metalView)
        // パイプラインの生成
        makePipeline()
        // エンコーダの設定
        settingEncoder()
    }
    
    func draw(_ shape:CAIMMetalDrawable) {
        shape.draw(with:self)
    }
}
