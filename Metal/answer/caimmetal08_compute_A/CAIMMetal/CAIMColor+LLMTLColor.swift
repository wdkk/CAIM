//
// CAIMColor+CAIMMetalColor.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Foundation

#if os(macOS) || (os(iOS) && !arch(x86_64))
extension CAIMColor {
    public var float4:Float4 { return Float4(self.R, self.G, self.B, self.A) }
    public var metalColor:MTLClearColor {
        return MTLClearColor(red:Double(self.R), green:Double(self.G), blue:Double(self.B), alpha:Double(self.A))
    }
}
#endif
