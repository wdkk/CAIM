//
// CAIMMemory.swift
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

/*
// C実装でメモリを確保するメモリクラス
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
*/

// アラインメントを考慮したメモリクラス
public class CAIMMemory4K {
    fileprivate var _mem:CAIMMemory4KCPtr?
    public fileprivate(set) var span:Int = 1
    public fileprivate(set) var length:Int = 0
    public fileprivate(set) var count:Int = 0
    
    init(span:Int, count:Int = 0) {
        _mem = CAIMMemory4KCNew()
        self.span = span
        self.resize(count: count)
    }
    
    deinit { CAIMMemory4KCDelete(_mem) }
    
    // C実装オブジェクトの取得
    var memoryc:CAIMMemory4KCPtr? { return _mem }
    
    // ポインタ(オブジェクト型)の取得
    public fileprivate(set) var pointer:UnsafeMutableRawPointer?
    
    // ポインタの更新
    private func updatePointer() {
        let cptr = CAIMMemory4KCPointer(_mem)
        let opaqueptr = OpaquePointer(cptr)
        self.pointer = UnsafeMutableRawPointer(opaqueptr)
    }
    
    // アラインメント含め確保したメモリ容量
    var allocatedCapacity:Int { return CAIMMemory4KCCapacity(_mem) }
    // アラインメント含め確保したメモリサイズ
    var allocatedLength:Int { return CAIMMemory4KCLength(_mem) }
  
    // メモリのクリア
    func clear() { self.resize(count: 0) }
    
    // メモリのリサイズ
    func resize(count:Int) {
        self.count  = count
        self.length = count * self.span
        CAIMMemory4KCResize(_mem, self.length)
        CAIMMemory4KCReserve(_mem, self.length)
        self.updatePointer()
    }
    
    // メモリの追加
    func append(_ src:CAIMMemory4K) {
        self.count  += src.count
        self.length += src.length
        CAIMMemory4KCAppend(_mem, src._mem)
        self.updatePointer()
    }
    // メモリの追加
    func append<T>(_ element:T) {
        self.count  += 1
        self.length += MemoryLayout<T>.size
        CAIMMemory4KCAppendC(_mem, UnsafeMutablePointer<T>(mutating:[element]), MemoryLayout<T>.size)
        self.updatePointer()
    }
    // メモリの追加
    func append<T>(_ elements:[T]) {
        self.count  += 1
        self.length += MemoryLayout<T>.size * elements.count
        CAIMMemory4KCAppendC(_mem, UnsafeMutablePointer<T>(mutating:elements), MemoryLayout<T>.size * elements.count)
        self.updatePointer()
    }
}

// アラインメントを考慮したメモリクラス
public class CAIMMemory16 {
    fileprivate var _mem:CAIMMemory16CPtr?
    public fileprivate(set) var span:Int = 1
    public fileprivate(set) var length:Int = 0
    public fileprivate(set) var count:Int = 0
    
    init(span:Int, count:Int = 0) {
        _mem = CAIMMemory16CNew()
        self.span = span
        self.resize(count: count)
    }
    
    deinit { CAIMMemory16CDelete(_mem) }
    
    // C実装オブジェクトの取得
    var memoryc:CAIMMemory16CPtr? { return _mem }
    
    // ポインタ(オブジェクト型)の取得
    public fileprivate(set) var pointer:UnsafeMutableRawPointer?
    
    // ポインタの更新
    private func updatePointer() {
        let cptr = CAIMMemory16CPointer(_mem)
        let opaqueptr = OpaquePointer(cptr)
        self.pointer = UnsafeMutableRawPointer(opaqueptr)
    }
    
    // アラインメント含め確保したメモリ容量
    var allocatedCapacity:Int { return CAIMMemory16CCapacity(_mem) }
    // アラインメント含め確保したメモリサイズ
    var allocatedLength:Int { return CAIMMemory16CLength(_mem) }
    
    // メモリのクリア
    func clear() { self.resize(count: 0) }
    
    // メモリのリサイズ
    func resize(count:Int) {
        self.count  = count
        self.length = count * self.span
        CAIMMemory16CResize(_mem, self.length)
        CAIMMemory16CReserve(_mem, self.length)
        self.updatePointer()
    }
    
    // メモリの追加
    func append(_ src:CAIMMemory16) {
        self.count  += src.count
        self.length += src.length
        CAIMMemory16CAppend(_mem, src._mem)
        self.updatePointer()
    }
    // メモリの追加
    func append<T>(_ element:T) {
        self.count  += 1
        self.length += MemoryLayout<T>.size
        CAIMMemory16CAppendC(_mem, UnsafeMutablePointer<T>(mutating:[element]), MemoryLayout<T>.size)
        self.updatePointer()
    }
    // メモリの追加
    func append<T>(_ elements:[T]) {
        self.count  += 1
        self.length += MemoryLayout<T>.size * elements.count
        CAIMMemory16CAppendC(_mem, UnsafeMutablePointer<T>(mutating:elements), MemoryLayout<T>.size * elements.count)
        self.updatePointer()
    }
}
