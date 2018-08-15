//
// CAIMMetalShader.swift
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

enum CAIMMetalShaderType
{
    case vertex
    case fragment
    case compute
}

// シェーダクラス
public class CAIMMetalShader
{
    // シェーダ名
    fileprivate var _shader_name:String?
    public var name:String? { return _shader_name }

    fileprivate var _function:MTLFunction?
    public var function:MTLFunction { return _function! }
    
    public init(_ sh:String) {
        _shader_name = sh
        let library:MTLLibrary? = CAIMMetal.device.makeDefaultLibrary()
        _function = library!.makeFunction(name: self.name!)
    }
}

