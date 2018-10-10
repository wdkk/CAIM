//
// CAIMMetalComputer.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Metal

open class CAIMMetalComputer
{
    public var pipeline: MTLComputePipelineState?
    public var computeShader:CAIMMetalShader?
    
    public init() {}
    
    private func calcThreadCount( threadSize:Size2 ) -> Size2 {
        // 適用可能のスレッド数の計算
        let wid:Int32 = threadSize.w
        let hgt:Int32 = threadSize.h
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
    
    // Metalコマンドの開始(CAIMMetalComputerから呼び出せる簡易版。本体はCAIMMetal.execute)
    public func execute( threadSize:Size2 = Size2(x:16,y:16),
                              preCompute:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                              compute:( _ renderEncoder:MTLComputeCommandEncoder )->(),
                              postCompute:( _ commandBuffer:MTLCommandBuffer )->() = { _ in } )
    {
        CAIMMetal.execute(
            prev: preCompute,
            main: { ( commandBuffer:MTLCommandBuffer ) in
                self.beginCompute( commandBuffer: commandBuffer, threadSize:threadSize, compute: compute )
            },
            post: postCompute )
    }

    @discardableResult
    public func beginCompute( commandBuffer command_buffer:MTLCommandBuffer,
                              threadSize:Size2 = Size2(x:16,y:16),
                              compute:( _ computeEncoder:MTLComputeCommandEncoder )->() ) -> Bool {
        if pipeline == nil {
            do {
                self.pipeline = try CAIMMetal.device?.makeComputePipelineState( function: computeShader!.function! )
            }
            catch {
                print("Failed to create compute pipeline state, error")
                return false
            }
        }
        
        if pipeline == nil { return false }
        
        let th_size = calcThreadCount( threadSize:threadSize )
        // スレッド数
        let thread_num:MTLSize = MTLSize(width: Int(th_size.w), height: Int(th_size.h), depth:1 )
        // スレッドグループ数
        let thread_groups:MTLSize = MTLSize(width: Int(threadSize.w / th_size.w), height: Int(threadSize.h / th_size.h), depth:1 )
        
        guard let encoder:MTLComputeCommandEncoder = command_buffer.makeComputeCommandEncoder() else {
            print("failed to create command encoder.")
            return false
        }
        
        encoder.setComputePipelineState( pipeline! )
        
        compute( encoder )
        
        encoder.dispatchThreadgroups( thread_groups, threadsPerThreadgroup: thread_num )
        encoder.endEncoding()
        
        return false
    }
}
