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
    private init() {}

    // Metalコマンドの開始(CAIMMetalComputerから呼び出せる簡易版。本体はCAIMMetal.execute)
    public static func execute(
                         preCompute:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                         compute:( _ renderEncoder:MTLComputeCommandEncoder )->(),
                         postCompute:( _ commandBuffer:MTLCommandBuffer )->() = { _ in } )
    {
        CAIMMetal.execute(
        prev: preCompute,
        main: { ( commandBuffer:MTLCommandBuffer ) in
            CAIMMetalComputer.beginCompute( commandBuffer: commandBuffer, compute: compute )
        },
        post: postCompute )
    }
    
    @discardableResult
    public static func beginCompute( commandBuffer command_buffer:MTLCommandBuffer,
                              compute:( _ computeEncoder:MTLComputeCommandEncoder )->() ) -> Bool {        
        guard let encoder:MTLComputeCommandEncoder = command_buffer.makeComputeCommandEncoder() else {
            print("failed to create command encoder.")
            return false
        }
                
        compute( encoder )
        
        encoder.endEncoding()
        
        return false
    }
}
