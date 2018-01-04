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
    internal(set) var metalTexture:MTLTexture

    public init(with path:String) {
        // テクスチャの読み込み
        let tex_loader:MTKTextureLoader = MTKTextureLoader(device: CAIMMetal.device)
        let img:UIImage = UIImage(contentsOfFile: CAIM.bundle(path))!
        let cgimg:CGImage = img.cgImage!
        // テクスチャのY軸反転
        UIGraphicsBeginImageContext(img.size)
        let context = UIGraphicsGetCurrentContext()
        context?.draw(cgimg, in: CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height))
        context?.translateBy(x: 0, y: img.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        let result_cgimg2:CGImage = context!.makeImage()!
        UIGraphicsEndImageContext()
        
        self.metalTexture = try! tex_loader.newTexture(cgImage: result_cgimg2, options: nil)
    }
}

