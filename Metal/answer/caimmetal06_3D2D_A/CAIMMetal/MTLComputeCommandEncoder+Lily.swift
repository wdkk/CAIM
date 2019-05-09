//
// MTLRenderCommandEncoder+Lily.swift
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

extension MTLComputeCommandEncoder
{
    // MARK: - vertex buffer functions
    public func setBuffer( _ buffer:MTLBuffer, index idx:Int ) {
        self.setBuffer( buffer, offset: 0, index: idx )
    }
    public func setBuffer<T:CAIMMetalBufferAllocatable>( _ obj:T, offset:Int=0, index idx:Int ) {
        self.setBuffer( obj.metalBuffer, offset: offset, index: idx )
    }

    // MARK: - pipeline function
    public func use( _ pipeline:CAIMMetalComputePipeline, _ computeFunc:( MTLComputeCommandEncoder )->() ) {
        // エンコーダにパイプラインを指定
        self.setComputePipelineState( pipeline.state! )
        // 関数を実行
        computeFunc( self )
    }
    
    // 1次元実行
    public func dispatch( dataCount:Int, threadCount:Int = 32 ) {
        // スレッド数
        let thread_num:MTLSize = MTLSize(width: (dataCount + threadCount-1) / threadCount, height: 1, depth:1 )
        // スレッドグループ数
        let thread_groups:MTLSize = MTLSize(width: threadCount, height: 1, depth:1 )
        
        self.dispatchThreadgroups( thread_groups, threadsPerThreadgroup: thread_num )
    }

    // 2次元実行
    public func dispatch2d( threadSize:Size2 = Size2( 16, 16 ) ) {
        let th_size = calcThreadCount( threadSize:threadSize )
        // スレッド数
        let thread_num:MTLSize = MTLSize(width: Int(th_size.width), height: Int(th_size.height), depth:1 )
        // スレッドグループ数
        let thread_groups:MTLSize = MTLSize(width: Int(threadSize.width / th_size.width),
                                            height: Int(threadSize.height / th_size.height), depth:1 )
        
        self.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: thread_num)
    }
    
    private func calcThreadCount( threadSize:Size2 ) -> Size2 {
        // 適用可能のスレッド数の計算
        let wid:Int32 = threadSize.width
        let hgt:Int32 = threadSize.height
        var th_wid:Int32 = 1
        var th_hgt:Int32 = 1
        for w:Int32 in 0 ..< 16 {
            if wid % (16-w) == 0 { th_wid = 16 - w; break }
        }
        for h:Int32 in 0 ..< 16 {
            if hgt % (16-h) == 0 { th_hgt = 16 - h; break }
        }
        
        return Size2( th_wid, th_hgt )
    }
}

#endif
