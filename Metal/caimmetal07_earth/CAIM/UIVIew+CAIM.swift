//
// UIView+CAIM.swift
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

public extension UIView
{
    public var pixelX:CGFloat {
        get { return self.frame.origin.x * UIScreen.main.scale }
        set { self.frame.origin.x = newValue / UIScreen.main.scale }
    }
    public var pixelY:CGFloat {
        get { return self.frame.origin.y * UIScreen.main.scale }
        set { self.frame.origin.y = newValue / UIScreen.main.scale }
    }
    public var pixelWidth:CGFloat {
        get { return self.frame.size.width * UIScreen.main.scale }
        set { self.frame.size.width = newValue / UIScreen.main.scale }
    }
    public var pixelHeight:CGFloat {
        get { return self.frame.size.height * UIScreen.main.scale }
        set { self.frame.size.height = newValue / UIScreen.main.scale }
    }
    public var pixelFrame:CGRect {
        get { return CGRect(x: pixelX, y: pixelY, width: pixelWidth, height: pixelHeight) }
        set {
            self.frame = CGRect( x: newValue.origin.x / UIScreen.main.scale,
                                 y: newValue.origin.y / UIScreen.main.scale,
                                 width: newValue.size.width / UIScreen.main.scale,
                                 height: newValue.size.height / UIScreen.main.scale )
        }
    }
    public var pixelBounds:CGRect {
        get { return CGRect(x: bounds.origin.x * UIScreen.main.scale,
                            y: bounds.origin.y * UIScreen.main.scale,
                            width: bounds.size.width * UIScreen.main.scale,
                            height: bounds.size.height * UIScreen.main.scale)
        }
        set {
            self.bounds = CGRect( x: newValue.origin.x / UIScreen.main.scale,
                                  y: newValue.origin.y / UIScreen.main.scale,
                                  width: newValue.size.width / UIScreen.main.scale,
                                  height: newValue.size.height / UIScreen.main.scale )
        }
    }
}
