//
// CAIMImage.swift
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

// C言語実装のCAIMImageをSwiftで使いやすくしたクラス
class CAIMImage
{
    fileprivate var img:CAIMImageCPtr? = nil
 
    var width:Int { return CAIMImageWidth(img) }
    var height:Int { return CAIMImageHeight(img) }
    var pointer:CAIMCharPtr { return CAIMImageMemory(img) }
    var length:Int { return CAIMImageMemorySize(img) }
    var matrix:CAIMColorMatrix { return CAIMImageMatrix(img) }
    var matrix8:CAIMColor8Matrix { return CAIMImageMatrix8(img) }
    var depth:CAIMDepth { return CAIMImageDepth(img) }
    var scale:Float { return Float(CAIMImageRetinaScale(img)) }
    
    init(width:Int, height:Int, depth:CAIMDepth = .float) { img = CAIMImageCreate(width, height, depth) }
    
    init(size:CGSize, depth:CAIMDepth = .float) { img = CAIMImageCreate(Int(size.width), Int(size.height), depth) }
    
    init(path:String, depth:CAIMDepth = .float) { img = CAIMImageCreateWithFile(path, depth) }
    
    fileprivate init(img_clone:CAIMImageCPtr) { img = CAIMImageClone(img_clone) }
    
    deinit { CAIMImageRelease(img) }
    
    func clone(_ img_src:CAIMImage) -> CAIMImage { return CAIMImage(img_clone: img_src.img!) }
    
    func copy(_ img_src:CAIMImage) { CAIMImageCopy(img_src.img, self.img) }
    
    func resize(_ wid:Int, hgt:Int) { CAIMImageResize(img, wid, hgt) }
    
    func loadFile(_ path:String) -> Bool { return (CAIMImageLoadFile(img, path) == 1) }
    
    func fillColor(_ c:CAIMColor) { CAIMImagefillColor(img, c) }
    
    func paste(_ img_src:CAIMImage, x:Int, y:Int) { CAIMImagePaste(img_src.img, self.img, Int32(x), Int32(y)) }
}
