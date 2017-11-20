//
// CAIMShape.swift
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

// Metal向け形状メモリクラス
class CAIMShape<T> : CAIMAlignedMemory
{
    fileprivate var _metal_buffer:CAIMMetalBufferBase?
    fileprivate var _buffer_type:CAIMMetalBufferType = .alloc
    
    init(span:Int, count:Int, type:CAIMMetalBufferType = .alloc) {
        super.init(span: span, count: count)
        _buffer_type = type
        if(_buffer_type == .alloc) {    // default
            _metal_buffer = CAIMMetalBuffer(vertice: self)
        }
        else {  // shared
            _metal_buffer = CAIMMetalSharedBuffer(vertice: self)
        }
    }
    
    var metalBuffer:CAIMMetalBufferBase {
        if(_buffer_type == .alloc) {
            _metal_buffer!.update(vertice: self)
        }
        return _metal_buffer!
    }
    
    var typePointer:UnsafeMutablePointer<T> {
        return UnsafeMutablePointer<T>(OpaquePointer(self.pointer!))
    }
    
    func render(by renderer:CAIMMetalRenderer) {}
}

// 点メモリクラス
class CAIMPoints<T> : CAIMShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.size * 1, count: count, type:type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.size * 1))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    override func render(by renderer:CAIMMetalRenderer) {
        let enc = renderer.encoder
        enc?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: count)
    }
}

// ライン形状メモリクラス
class CAIMLines<T> : CAIMShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.size * 2, count: count, type: type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.size * 2))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    override func render(by renderer:CAIMMetalRenderer) {
        let enc = renderer.encoder
        enc?.drawPrimitives(type: .line, vertexStart: 0, vertexCount: count * 2)
    }
}


// 三角形メッシュ形状メモリクラス
class CAIMTriangles<T> : CAIMShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.size * 3, count: count, type: type)
    }

    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.size * 3))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    override func render(by renderer:CAIMMetalRenderer) {
        let enc = renderer.encoder
        enc?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count * 3)
    }
}

// 四角形メッシュ形状メモリクラス
class CAIMQuadrangles<T> : CAIMShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.size * 4, count: count, type: type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.size * 4))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    override func render(by renderer:CAIMMetalRenderer) {
        let count:Int = self.count
        let enc = renderer.encoder
        for i:Int in 0 ..< count {
            enc?.drawPrimitives(type: .triangleStrip, vertexStart: i*4, vertexCount: 4)
        }
    }
}

// キューブメモリクラス
class CAIMCubes<T> : CAIMShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.size * 36, count: count, type:type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.size * 36))
        return UnsafeMutablePointer<T>(opaqueptr)
    }

    override func render(by renderer:CAIMMetalRenderer) {
        let count:Int = self.count
        let enc = renderer.encoder
        enc?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 36 * count)
    }
}

