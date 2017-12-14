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


import Foundation
import Metal

class CAIMMetalComputer
{
    var pipeline: MTLComputePipelineState?    // パイプライン
    fileprivate weak var _csh:CAIMMetalShader?
    var csh:CAIMMetalShader? { return _csh }
    
    init(compute csh:CAIMMetalShader?) {
        self._csh = csh
        
        let device:MTLDevice = CAIMMetal.device
        let library:MTLLibrary? = device.makeDefaultLibrary()
        let compute_func:MTLFunction? = library!.makeFunction(name: csh!.name!)
        
        do {
            self.pipeline = try device.makeComputePipelineState(function: compute_func!)
        }
        catch {
            print("Failed to create compute pipeline state, error")
            return
        }
    }
    
    /*
    func attachBuffer(_ cmd:MTLComputeCommandEncoder) {
        // シェーダバッファのアタッチ
        csh?.attach(cmd)
    }
    */
}
