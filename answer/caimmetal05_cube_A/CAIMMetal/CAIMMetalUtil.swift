//
// CAIMMetal.swift
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
import QuartzCore

// CAIMMetalで共有利用するdeviceとcommand queueを管理する
// MTLBufferのバッファ確保もこの関数を経由する
class CAIMMetal
{
    private static var _device: MTLDevice?                   // [Reuse] Device
    private static var _commandQueue: MTLCommandQueue?      // [Reuse] Command Queue
    
    static var device:MTLDevice {
        get {
            if(_device == nil) { _device = MTLCreateSystemDefaultDevice() }
            return _device!
        }
    }
    
    static var commandQueue:MTLCommandQueue {
        get {
            if(_commandQueue == nil) { _commandQueue = device.makeCommandQueue() }
            return _commandQueue!
        }
    }
}
