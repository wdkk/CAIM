//
// MTLRenderCommandEncoder+Lily.swift
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

#if os(macOS) || (os(iOS) && !arch(x86_64))

extension MTLRenderCommandEncoder
{
    // MARK: - vertex buffer functions
    public func setVertexBuffer( _ buffer:MTLBuffer,  offset:Int=0, at idx:Int ) {
        self.setVertexBuffer( buffer, offset: offset, index: idx )
    }
    public func setVertexBuffer( _ buffer_base:CAIMMetalBufferBase, offset:Int=0, at idx:Int ) {
        self.setVertexBuffer( buffer_base.metalBuffer, offset: offset, index: idx )
    }
    public func setVertexBuffer( _ mem:CAIMMetalBufferAllocatable, offset:Int=0, at idx:Int ) {
        self.setVertexBuffer( mem.metalBuffer, offset: offset, index: idx )
    }
    public func setVertexBuffer<T>( _ shape:CAIMMetalShape<T>, at idx:Int ) {
        self.setVertexBuffer( shape.metalBuffer, offset: 0, index: idx )
    }
    
    // MARK: - fragment buffer functions
    public func setFragmentBuffer( _ buffer:MTLBuffer, offset:Int=0, at idx:Int ) {
        self.setFragmentBuffer( buffer, offset: offset, index: idx )
    }
    public func setFragmentBuffer( _ buffer_base:CAIMMetalBufferBase, offset:Int=0, at idx:Int ) {
        self.setFragmentBuffer( buffer_base.metalBuffer, offset: offset, index: idx )
    }
    public func setFragmentBuffer( _ mem:CAIMMetalBufferAllocatable, offset:Int=0, at idx:Int ) {
        self.setFragmentBuffer( mem.metalBuffer, offset: offset, index: idx )
    }
    
    // MARK: - pipeline function
    public func use( _ pipeline:CAIMMetalRenderPipeline, _ drawFunc:( MTLRenderCommandEncoder )->() ) {
        // パイプラインを準備
        pipeline.readyPipeline()
        // エンコーダにパイプラインを指定
        self.setRenderPipelineState( pipeline.state! )
        // 描画関数を実行
        drawFunc( self )
    }
    
    public func drawShape( _ shape:CAIMMetalDrawable ) {
        shape.draw( with:self )
    }
}

#endif
