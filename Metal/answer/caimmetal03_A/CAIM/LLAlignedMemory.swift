//
// LLAlignedMemory.h
// Lily Library
//
// Copyright (c) 2017- Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//

import Foundation

// アラインメントを考慮したメモリクラス
public class LLAlignedMemory4K {
    fileprivate var _mem:LCAlignedMemory4KPtr?
    public fileprivate(set) var span:Int = 1
    public fileprivate(set) var length:Int = 0
    public fileprivate(set) var count:Int = 0
    
    public init(span:Int, count:Int = 0) {
        _mem = LCAlignedMemory4KNew()
        self.span = span
        self.resize(count: count)
    }
    
    deinit { LCAlignedMemory4KDelete(_mem) }
    
    // C実装オブジェクトの取得
    public var memoryc:LCAlignedMemory4KPtr? { return _mem }
    
    // ポインタ(オブジェクト型)の取得
    public fileprivate(set) var pointer:UnsafeMutableRawPointer?
    
    // ポインタの更新
    private func updatePointer() {
        let cptr = LCAlignedMemory4KPointer(_mem)
        let opaqueptr = OpaquePointer(cptr)
        self.pointer = UnsafeMutableRawPointer(opaqueptr)
    }
    
    // アラインメント含め確保したメモリ容量
    public var allocatedCapacity:Int { return LCAlignedMemory4KCapacity(_mem) }
    // アラインメント含め確保したメモリサイズ
    public var allocatedLength:Int { return LCAlignedMemory4KLength(_mem) }
  
    // メモリのクリア
    public func clear() { self.resize(count: 0) }
    
    // メモリのリサイズ
    public func resize(count:Int) {
        self.count  = count
        self.length = count * self.span
        LCAlignedMemory4KResize(_mem, self.length)
        LCAlignedMemory4KReserve(_mem, self.length)
        self.updatePointer()
    }
    
    // メモリの追加
    public func append(_ src:LLAlignedMemory4K) {
        self.count  += src.count
        self.length += src.length
        LCAlignedMemory4KAppend(_mem, src._mem)
        self.updatePointer()
    }
    // メモリの追加
    public func append<T>(_ element:T) {
        self.count  += 1
        self.length += MemoryLayout<T>.size
        LCAlignedMemory4KAppendC(_mem, UnsafeMutablePointer<T>(mutating:[element]), MemoryLayout<T>.size)
        self.updatePointer()
    }
    // メモリの追加
    public func append<T>(_ elements:[T]) {
        self.count  += 1
        self.length += MemoryLayout<T>.size * elements.count
        LCAlignedMemory4KAppendC(_mem, UnsafeMutablePointer<T>(mutating:elements), MemoryLayout<T>.size * elements.count)
        self.updatePointer()
    }
}

// アラインメントを考慮したメモリクラス
public class LLAlignedMemory16 {
    fileprivate var _mem:LCAlignedMemory16Ptr?
    public fileprivate(set) var span:Int = 1
    public fileprivate(set) var length:Int = 0
    public fileprivate(set) var count:Int = 0
    
    public init(span:Int, count:Int = 0) {
        _mem = LCAlignedMemory16New()
        self.span = span
        self.resize(count: count)
    }
    
    deinit { LCAlignedMemory16Delete(_mem) }
    
    // C実装オブジェクトの取得
    public var memoryc:LCAlignedMemory16Ptr? { return _mem }
    
    // ポインタ(オブジェクト型)の取得
    public fileprivate(set) var pointer:UnsafeMutableRawPointer?
    
    // ポインタの更新
    private func updatePointer() {
        let cptr = LCAlignedMemory16Pointer(_mem)
        let opaqueptr = OpaquePointer(cptr)
        self.pointer = UnsafeMutableRawPointer(opaqueptr)
    }
    
    // アラインメント含め確保したメモリ容量
    public var allocatedCapacity:Int { return LCAlignedMemory16Capacity(_mem) }
    // アラインメント含め確保したメモリサイズ
    public var allocatedLength:Int { return LCAlignedMemory16Length(_mem) }
    
    // メモリのクリア
    public func clear() { self.resize(count: 0) }
    
    // メモリのリサイズ
    public func resize(count:Int) {
        self.count  = count
        self.length = count * self.span
        LCAlignedMemory16Resize(_mem, self.length)
        LCAlignedMemory16Reserve(_mem, self.length)
        self.updatePointer()
    }
    
    // メモリの追加
    public func append(_ src:LLAlignedMemory16) {
        self.count  += src.count
        self.length += src.length
        LCAlignedMemory16Append(_mem, src._mem)
        self.updatePointer()
    }
    // メモリの追加
    public func append<T>(_ element:T) {
        self.count  += 1
        self.length += MemoryLayout<T>.size
        LCAlignedMemory16AppendC(_mem, UnsafeMutablePointer<T>(mutating:[element]), MemoryLayout<T>.size)
        self.updatePointer()
    }
    // メモリの追加
    public func append<T>(_ elements:[T]) {
        self.count  += 1
        self.length += MemoryLayout<T>.size * elements.count
        LCAlignedMemory16AppendC(_mem, UnsafeMutablePointer<T>(mutating:elements), MemoryLayout<T>.size * elements.count)
        self.updatePointer()
    }
}
