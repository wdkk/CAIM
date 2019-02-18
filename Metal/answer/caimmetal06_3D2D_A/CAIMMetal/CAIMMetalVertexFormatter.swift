//
// CAIMMetalVertexFormatter.swift
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

import MetalKit
import Metal

public protocol CAIMMetalVertexFormatter {
    static func makeVertexDescriptor(at index:Int, formats fmts:[MTLVertexFormat]) -> MTLVertexDescriptor
    static func vertexDescriptor(at idx:Int) -> MTLVertexDescriptor
}

public extension CAIMMetalVertexFormatter {
    static func makeVertexDescriptor(at index:Int, formats fmts:[MTLVertexFormat]) -> MTLVertexDescriptor {
        let desc = MTLVertexDescriptor()
        if(fmts.count == 0) { return desc }
        
        let stride = MemoryLayout<Self>.stride
        
        var ptr:Int = 0
        desc.attributes[0].format = fmts[0]
        desc.attributes[0].offset = ptr
        desc.attributes[0].bufferIndex = 0
        ptr += Int(fmts[0].rawValue)
        
        for i:Int in 1 ..< fmts.count {
            let fmt = fmts[i]
            let alignment = Int(fmt.rawValue)
            
            let mod = ptr % alignment
            if(mod > 0) { ptr += (alignment - mod) }
            
            desc.attributes[i].format = fmt
            desc.attributes[i].offset = ptr
            desc.attributes[i].bufferIndex = 0
            
            ptr += alignment
        }
        
        desc.layouts[index].stride = stride
        desc.layouts[index].stepRate = 1
        
        return desc
    }
}

#endif
