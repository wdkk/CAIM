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

#if os(macOS) || (os(iOS) && !arch(x86_64))

import MetalKit

public class CAIMMetalTexture {
    public private(set) var metalTexture:MTLTexture?
    
    public init( with path:String ) {
        // テクスチャの読み込み
        let tex_loader:MTKTextureLoader = MTKTextureLoader(device: CAIMMetal.device! )
        #if LILY
        let img:LLImage = LLImage( LLPath.bundle(path) )
        guard let cgimg:CGImage = LCImage2CGImage( img.imagec )?.takeUnretainedValue() else {
            print( "cannot read texture file." )
            return
        }
        #else
        let img:UIImage? = UIImage(contentsOfFile: CAIM.bundle( path ) )
        guard let cgimg:CGImage = img?.cgImage else {
            print( "cannot read texture file." )
            return
        }
        #endif
        
        self.metalTexture = try! tex_loader.newTexture( cgImage: cgimg, options: nil )
    }
}

#endif
