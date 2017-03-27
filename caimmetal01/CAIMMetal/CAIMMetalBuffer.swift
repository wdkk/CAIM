//
// CAIMMetalBuffer.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//


import Foundation
import Metal


enum CAIMMetalBufferType : Int
{
    case normal
    case shared
}

class CAIMMetalBufferBase
{
    fileprivate var _mtlbuf:MTLBuffer?
    var mtlbuf:MTLBuffer? { return _mtlbuf }
    
    fileprivate var _length:Int = 0
    
    func update<T>(_ obj:T) {}
    
    func update<T>(elements:[T]) {}
    
    func update(_ buf:UnsafeRawPointer, length:Int) {}
    
    func update<T>(vertice:CAIMAlignMemory<T>) {}
}

class CAIMMetalBuffer : CAIMMetalBufferBase
{
    //// 初期化
    // 指定したオブジェクトのサイズで確保＆初期化
    init<T>(_ obj:T) {
        super.init()
        _length = MemoryLayout<T>.size
        _mtlbuf = self.allocate([obj], length:_length)
    }
    // 指定したオブジェクト配列で確保＆初期化
    init<T>(elements:[T]) {
        super.init()
        _length = MemoryLayout<T>.size * elements.count
        _mtlbuf = self.allocate(UnsafeMutablePointer(mutating: elements), length:_length)
    }
    // 指定したバイト数を確保（初期化はなし）
    init(length:Int) {
        super.init()
        _length = length
        _mtlbuf = self.allocate(_length)
    }
    // 指定したバイト数で確保＆ポインタ先からコピーして初期化
    init(_ buf:UnsafeRawPointer, length:Int) {
        super.init()
        _length = length
        _mtlbuf = self.allocate(buf, length: _length)
    }
    // 指定した頂点プールの内容とサイズで確保＆初期化
    init<T>(vertice:CAIMAlignMemory<T>) {
        super.init()
        _length = vertice.allocated_length
        _mtlbuf = self.allocate(vertice.pointer, length:_length)
    }
    
    //// 更新
    override func update<T>(_ obj:T) {
        memcpy( _mtlbuf!.contents(), [obj], MemoryLayout<T>.size )
    }
    
    override func update<T>(elements:[T]) {
        memcpy( _mtlbuf!.contents(), UnsafeMutablePointer(mutating: elements), MemoryLayout<T>.size * elements.count )
    }
    
    override func update(_ buf:UnsafeRawPointer, length:Int) {
        memcpy( _mtlbuf!.contents(), buf, length )
    }
    
    override func update<T>(vertice:CAIMAlignMemory<T>) {
        memcpy( _mtlbuf!.contents(), vertice.pointer, vertice.allocated_length )
    }
    
    //// メモリ確保
    private func allocate(_ buf:UnsafeRawPointer, length:Int) -> MTLBuffer {
        return CAIMMetal.device.makeBuffer(bytes: buf, length: length, options: .storageModeShared )
    }
    
    private func allocate(_ length:Int) -> MTLBuffer {
        return CAIMMetal.device.makeBuffer(length: length, options: .storageModeShared )
    }
}

class CAIMMetalSharedBuffer : CAIMMetalBufferBase
{
    // 指定したオブジェクト全体を共有して確保・初期化
    init<T>(vertice:CAIMAlignMemory<T>) {
        super.init()
        _length = vertice.allocated_length
        _mtlbuf = self.nocopy(vertice.pointer, length:_length)
    }
    
    // 更新関数は何もしない
    override func update<T>(_ obj:T) {}
    
    override func update<T>(elements:[T]) {}
    
    override func update(_ buf:UnsafeRawPointer, length:Int) {}
    
    override func update<T>(vertice:CAIMAlignMemory<T>) {}
    
    private func nocopy(_ buf:UnsafeMutableRawPointer, length:Int) -> MTLBuffer {
        return CAIMMetal.device.makeBuffer(bytesNoCopy: buf, length: length, options: .storageModeShared, deallocator: nil)
    }
}

