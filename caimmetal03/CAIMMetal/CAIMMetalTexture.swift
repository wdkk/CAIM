//
// CAIMMetalTexture.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit
import Metal
import MetalKit

public class CAIMMetalTexture {
    internal(set) var metalTexture:MTLTexture?

    public init(named path:String) {
        // テクスチャの読み込み
        let tex_loader:MTKTextureLoader = MTKTextureLoader(device: CAIMMetal.device)
        let img:UIImage? = UIImage(named: path)
        self.metalTexture = try! tex_loader.newTexture(cgImage: img!.cgImage!, options: nil)
    }
}

