//
// UnsafeRawPointer+CAIM.swift
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

public func << <T>(ptr:UnsafeMutableRawPointer, obj:T) {
    let p = ptr.assumingMemoryBound(to: T.self)
    p.pointee = obj
}
