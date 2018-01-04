//
// CAIMMetalBuffer.swift
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


public enum CAIMMetalBufferType : Int
{
    case alloc
    case shared
}

public class CAIMMetalBufferBase
{
    fileprivate var _length:Int = 0
    
    fileprivate var _mtlbuf:MTLBuffer?
    public var metalBuffer:MTLBuffer? { return _mtlbuf }

    public func update<T>(_ obj:T) {}
    
    public func update<T>(elements:[T]) {}
    
    public func update(_ buf:UnsafeRawPointer, length:Int) {}
}

public class CAIMMetalAllocatedBuffer : CAIMMetalBufferBase
{
    //// 初期化
    // 指定したオブジェクトのサイズで確保＆初期化
    public init<T>(_ obj:T) {
        super.init()
        _length = MemoryLayout<T>.stride
        _mtlbuf = self.allocate([obj], length:_length)
    }
    // 指定したオブジェクト配列で確保＆初期化
    public init<T>(elements:[T]) {
        super.init()
        _length = MemoryLayout<T>.stride * elements.count
        if(_length == 0) {
            _mtlbuf = nil
            return
        }
        _mtlbuf = self.allocate(UnsafeMutablePointer(mutating: elements), length:_length)
    }
    // 指定したバイト数を確保（初期化はなし）
    public init(length:Int) {
        super.init()
        _length = length
        if(_length == 0) {
            _mtlbuf = nil
            return
        }
        _mtlbuf = self.allocate(_length)
    }
    // 指定したバイト数で確保＆ポインタ先からコピーして初期化
    public init(_ buf:UnsafeRawPointer, length:Int) {
        super.init()
        _length = length
        if(_length == 0) {
            _mtlbuf = nil
            return
        }
        _mtlbuf = self.allocate(buf, length: _length)
    }
    // 指定した頂点プールの内容とサイズで確保＆初期化
    public init(vertice:CAIMMemory16) {
        super.init()
        _length = vertice.allocatedLength
        if(_length == 0) {
            _mtlbuf = nil
            return
        }
        _mtlbuf = self.allocate(vertice.pointer!, length:_length)
    }
    // 指定した頂点プールの内容とサイズで確保＆初期化(4Kアラインメントデータも受け取る)
    public init(vertice:CAIMMemory4K) {
        super.init()
        _length = vertice.allocatedLength
        if(_length == 0) {
            _mtlbuf = nil
            return
        }
        _mtlbuf = self.allocate(vertice.pointer!, length:_length)
    }
    
    //// 更新
    public override func update<T>(_ obj:T) {
        let sz:Int = MemoryLayout<T>.stride
        if(_length != sz) { _mtlbuf = self.allocate(sz) }
        memcpy( _mtlbuf!.contents(), [obj], sz )
    }
    
    public override func update<T>(elements:[T]) {
        let sz:Int = MemoryLayout<T>.stride * elements.count
        if(_length != sz) { _mtlbuf = self.allocate(sz) }
        memcpy( _mtlbuf!.contents(), UnsafeMutablePointer(mutating: elements), sz)
    }
    
    public override func update(_ buf:UnsafeRawPointer, length:Int) {
        let sz:Int = length
        if(_length != sz) { _mtlbuf = self.allocate(sz) }
        memcpy( _mtlbuf!.contents(), buf, sz )
    }
    
    public func update(vertice:CAIMMemory16) {
        let sz:Int = vertice.allocatedLength
        if(_length != sz) { _mtlbuf = self.allocate(sz) }
        memcpy( _mtlbuf!.contents(), vertice.pointer, sz )
    }
    
    //// メモリ確保
    private func allocate(_ buf:UnsafeRawPointer, length:Int) -> MTLBuffer {
        return CAIMMetal.device.makeBuffer(bytes: buf, length: length, options: .storageModeShared )!
    }
    
    private func allocate(_ length:Int) -> MTLBuffer {
        return CAIMMetal.device.makeBuffer(length: length, options: .storageModeShared )!
    }
}

public class CAIMMetalSharedBuffer : CAIMMetalBufferBase
{
    // 指定したオブジェクト全体を共有して確保・初期化
    public init(vertice:CAIMMemory4K) {
        super.init()
        _length = vertice.allocatedLength
        if(_length == 0) {
            _mtlbuf = nil
            return
        }
        _mtlbuf = self.nocopy(vertice.pointer!, length:_length)
    }
    
    // 更新関数は何もしない
    public override func update<T>(_ obj:T) {
    }
    
    public override func update<T>(elements:[T]) {
    }
    
    public override func update(_ buf:UnsafeRawPointer, length:Int) {
    }
    
    public func update(vertice:CAIMMemory4K) {
        _mtlbuf = self.nocopy(vertice.pointer!, length: vertice.allocatedLength)
    }
    
    private func nocopy(_ buf:UnsafeMutableRawPointer, length:Int) -> MTLBuffer {
        return CAIMMetal.device.makeBuffer(bytesNoCopy: buf, length: length, options: .storageModeShared, deallocator: nil)!
    }
}

