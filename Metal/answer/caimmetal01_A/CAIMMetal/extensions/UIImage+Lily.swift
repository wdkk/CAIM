//
// UIImage+Lily.swift
// Lily Library
//   https://wdkk.co.jp/
//
// Copyright (c) 2017- Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//

#if os(iOS)

import UIKit

public extension UIImage
{
    public var llImage:LLImage? {
        let lcimg:LCImagePtr? = UIImage2LCImage( self )
        if( lcimg == nil ) { return nil }
        let llimg:LLImage = LLImage( lcimg! )
        LCImageDelete( lcimg )
        return llimg
    }
}

#endif
