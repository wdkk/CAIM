//
// CAIMMetalRenderPipeline.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Foundation
import Metal

public enum CAIMMetalBlendType : Int
{
    case none
    case alphaBlend
}

public struct CAIMMetalDepthState
{
    var sampleCount:Int = 1
    var depthFormat:MTLPixelFormat = .depth32Float_stencil8
}

// Metalパイプライン
public class CAIMMetalRenderPipeline
{
    // エンコーダー
    public private(set) var state:MTLRenderPipelineState?
    private var _depth_state:CAIMMetalDepthState
    // 頂点シェーダー
    public var vertexShader:CAIMMetalShader?
    // フラグメントシェーダー
    public var fragmentShader:CAIMMetalShader?
    // 合成タイプ
    public var blendType:CAIMMetalBlendType = .alphaBlend
    // 頂点ディスクリプタ
    var vertexDesc:MTLVertexDescriptor? = nil

    public init() {
        _depth_state = CAIMMetalDepthState()
    }
    
    public init( depthState dstate:CAIMMetalDepthState ) {
        _depth_state = dstate
    }
    
    private func makeRenderPipelineDesc() -> MTLRenderPipelineDescriptor {
        // パイプラインディスクリプター
        let r_pipeline_desc:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        r_pipeline_desc.vertexFunction = vertexShader!.function
        r_pipeline_desc.fragmentFunction = fragmentShader!.function
        // パイプラインdescのデプス・ステンシル情報を設定
        r_pipeline_desc.vertexDescriptor = vertexDesc
        r_pipeline_desc.sampleCount = _depth_state.sampleCount
        r_pipeline_desc.depthAttachmentPixelFormat = _depth_state.depthFormat
        r_pipeline_desc.stencilAttachmentPixelFormat = _depth_state.depthFormat
        
        let color_attachment:MTLRenderPipelineColorAttachmentDescriptor = r_pipeline_desc.colorAttachments[0]
        color_attachment.pixelFormat = .bgra8Unorm
        
        switch( self.blendType ) {
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
        
        return r_pipeline_desc
    }
    
    public func readyPipeline() {
        if state != nil { return }
        // パイプラインの生成
        do {
            // パイプラインディスクリプタの準備
            let r_pipeline_desc = makeRenderPipelineDesc()
            state = try CAIMMetal.device?.makeRenderPipelineState( descriptor: r_pipeline_desc )
        }
        catch {
            print( error.localizedDescription )
        }
    }
}

#endif
