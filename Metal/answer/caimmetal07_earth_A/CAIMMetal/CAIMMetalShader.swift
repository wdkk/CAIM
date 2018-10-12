//
// CAIMMetalView.swift
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

// シェーダクラス
public class CAIMMetalShader
{
    public var name:String? = nil { didSet { make() } }
    
    public private(set) var function:MTLFunction?

    public init( _ shader_name:String? = nil ) {
        name = shader_name
        make()
    }
    
    private func make() {
        guard let n:String = name else { return }
        guard let lib:MTLLibrary = CAIMMetal.device?.makeDefaultLibrary() else { return }
        function = lib.makeFunction( name: n )
    }
}

#endif
