//
// MTLVertexDescriptor+Ex.swift
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

extension MTLVertexDescriptor {
    convenience init(at index:Int, format attr:[(format:MTLVertexFormat, byte:Int)], stride:Int) {
        self.init()
        
        var ptr:Int = 0
        for i:Int in 0 ..< attr.count {
            self.attributes[i].format = attr[i].format
            self.attributes[i].offset = ptr
            self.attributes[i].bufferIndex = 0
            ptr += attr[i].byte
        }
        
        self.layouts[index].stride = stride
        self.layouts[index].stepRate = 1
    }
}
