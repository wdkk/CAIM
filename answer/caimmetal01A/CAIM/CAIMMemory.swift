//
// CAIMMemory.swift
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

class CAIMMemory {
    fileprivate var _mem:CAIMMemoryCPtr?
    
    init() { _mem = CAIMMemoryCNew() }
    
    deinit { CAIMMemoryCDelete(_mem) }
    
    var pointer:UnsafeMutableRawPointer { return CAIMMemoryCPointer(_mem) }

    var capacity:Int { return CAIMMemoryCCapacity(_mem) }
    
    var length:Int { return CAIMMemoryCLength(_mem) }
    
    func clear() {
        CAIMMemoryCResize(_mem, 0)
        CAIMMemoryCReserve(_mem, 0)
    }

    func resizeBytes(_ length:Int) {
        CAIMMemoryCResize(_mem, length)
    }
    
    func reserveBytes(_ length:Int) {
        CAIMMemoryCReserve(_mem, length)
    }
    
    func append(_ src:CAIMMemory) { CAIMMemoryCAppend(_mem, src._mem) }
    
    func append(_ bin:UnsafeMutableRawPointer, length:Int) { CAIMMemoryCAppendC(_mem, bin, length) }
}

class CAIMAlignMemory<T> {
    fileprivate var _mem:CAIMMemoryCPtr?
    fileprivate var _available_length:Int = 0
    fileprivate var _available_count:Int = 0
    
    init() { _mem = CAIMMemoryCNew() }
    
    init(count:Int = 0) {
        _mem = CAIMMemoryCNew()
        self.resize(count: count)
    }
    
    deinit { CAIMMemoryCDelete(_mem) }
    
    var memoryc:CAIMMemoryCPtr? { return _mem }
    
    fileprivate var _pointer:UnsafeMutablePointer<T>?
    var pointer:UnsafeMutablePointer<T> {
        return _pointer!
    }
    
    private func updatePointer() {
        let cptr = CAIMMemoryCPointer(_mem)
        let opaqueptr = OpaquePointer(cptr)
        _pointer = UnsafeMutablePointer<T>(opaqueptr!)
    }
    
    var count:Int { return _available_count }
    
    var length:Int { return _available_length }
    
    var capacity:Int { return CAIMMemoryCCapacity(_mem) }
    
    var allocated_length:Int { return CAIMMemoryCLength(_mem) }
  
    func clear() {
        self.resize(count: 0)
    }
    
    func resize(count:Int) {
        _available_count  = count
        _available_length = count * MemoryLayout<T>.size
        CAIMMemoryCResize(_mem, _available_length)
        CAIMMemoryCReserve(_mem, _available_length)
        self.updatePointer()
    }
    
    func append(_ src:CAIMAlignMemory<T>) {
        _available_count  += src.count
        _available_length += src.length
        CAIMMemoryCAppend(_mem, src._mem)
        self.updatePointer()
    }
    
    func append(_ element:T) {
        _available_count  += 1
        _available_length += MemoryLayout<T>.size
        CAIMMemoryCAppendC(_mem, UnsafeMutablePointer<T>(mutating:[element]), MemoryLayout<T>.size)
        self.updatePointer()
    }
    
    func append(_ elements:[T]) {
        _available_count  += 1
        _available_length += MemoryLayout<T>.size * elements.count
        CAIMMemoryCAppendC(_mem, UnsafeMutablePointer<T>(mutating:elements), MemoryLayout<T>.size * elements.count)
        self.updatePointer()
    }
}
