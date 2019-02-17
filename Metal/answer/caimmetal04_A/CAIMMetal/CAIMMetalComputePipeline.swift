//
// CAIMMetalComputePipeline.swift
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

open class CAIMMetalComputePipeline
{
    public private(set) var state:MTLComputePipelineState?
    public var computeShader:CAIMMetalShader?
    
    public init() {}

    public func readyPipeline() {
        if state != nil { return }

        do {
            self.state = try CAIMMetal.device?.makeComputePipelineState( function: computeShader!.function! )
        }
        catch {
            print("Failed to create compute pipeline state, error")
        }
    }
}

#endif
