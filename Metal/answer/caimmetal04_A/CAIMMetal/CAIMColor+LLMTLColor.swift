//
// CAIMColor+CAIMMetalColor.swift
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

import Foundation
import Metal

extension CAIMColor {
    public var float4:Float4 { return Float4(self.R, self.G, self.B, self.A) }
    public var metalColor:MTLClearColor {
        return MTLClearColor(red:Double(self.R), green:Double(self.G), blue:Double(self.B), alpha:Double(self.A))
    }
}

#endif
