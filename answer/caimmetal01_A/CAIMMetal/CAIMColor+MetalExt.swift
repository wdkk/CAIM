//
// CAIMColor+MetalEx.swift
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

extension CAIMColor {
    var float4:Float4 { return Float4(self.R, self.G, self.B, self.A) }
    var metalColor:MTLClearColor { return MTLClearColor(red:Double(self.R), green:Double(self.G), blue:Double(self.B), alpha:Double(self.A)) }
}
