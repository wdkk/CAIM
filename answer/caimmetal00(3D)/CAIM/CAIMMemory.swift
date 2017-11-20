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

extension CAIMColor {
    init(_ R:Float, _ G:Float, _ B:Float, _ A:Float) {
        self.R = R
        self.G = G
        self.B = B
        self.A = A
    }
}

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

// アラインメントを考慮したメモリクラス
public class CAIMAlignedMemory {
    fileprivate var _mem:CAIMMemoryCPtr?
    public fileprivate(set) var span:Int = 1
    public fileprivate(set) var length:Int = 0
    public fileprivate(set) var count:Int = 0
    
    init(span:Int, count:Int = 0) {
        _mem = CAIMMemoryCNew()
        self.span = span
        self.resize(count: count)
    }
    
    deinit { CAIMMemoryCDelete(_mem) }
    
    // C実装オブジェクトの取得
    var memoryc:CAIMMemoryCPtr? { return _mem }
    
    // ポインタ(オブジェクト型)の取得
    public fileprivate(set) var pointer:UnsafeMutableRawPointer?
    
    // ポインタの更新
    private func updatePointer() {
        let cptr = CAIMMemoryCPointer(_mem)
        let opaqueptr = OpaquePointer(cptr)
        self.pointer = UnsafeMutableRawPointer(opaqueptr)
    }
    
    // アラインメント含め確保したメモリ容量
    var allocatedCapacity:Int { return CAIMMemoryCCapacity(_mem) }
    // アラインメント含め確保したメモリサイズ
    var allocatedLength:Int { return CAIMMemoryCLength(_mem) }
  
    // メモリのクリア
    func clear() { self.resize(count: 0) }
    
    // メモリのリサイズ
    func resize(count:Int) {
        self.count  = count
        self.length = count * self.span
        CAIMMemoryCResize(_mem, self.length)
        CAIMMemoryCReserve(_mem, self.length)
        self.updatePointer()
    }
    
    // メモリの追加
    func append(_ src:CAIMAlignedMemory) {
        self.count  += src.count
        self.length += src.length
        CAIMMemoryCAppend(_mem, src._mem)
        self.updatePointer()
    }
    // メモリの追加
    func append<T>(_ element:T) {
        self.count  += 1
        self.length += MemoryLayout<T>.size
        CAIMMemoryCAppendC(_mem, UnsafeMutablePointer<T>(mutating:[element]), MemoryLayout<T>.size)
        self.updatePointer()
    }
    // メモリの追加
    func append<T>(_ elements:[T]) {
        self.count  += 1
        self.length += MemoryLayout<T>.size * elements.count
        CAIMMemoryCAppendC(_mem, UnsafeMutablePointer<T>(mutating:elements), MemoryLayout<T>.size * elements.count)
        self.updatePointer()
    }
}

