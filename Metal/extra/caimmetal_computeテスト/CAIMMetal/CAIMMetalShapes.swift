//
//  CAIMMetalShapes.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Foundation
import Metal

public protocol CAIMMetalDrawable
{
    func draw( with encoder:MTLRenderCommandEncoder )
}
// Metal向け形状メモリクラス
public class CAIMMetalShape<T> : CAIMMemory4K, CAIMMetalDrawable
{
    public var encoder:MTLRenderCommandEncoder?
    
    fileprivate var _buffer:CAIMMetalBufferBase?
    fileprivate var _type:CAIMMetalBufferType
    fileprivate var _buffer_index:Int
    
    public init( span:Int, count:Int, at index:Int, type:CAIMMetalBufferType = .alloc ) {
        _type = type
        _buffer_index = index
        super.init( span: span, count: count )
        _buffer = _type == .alloc ? CAIMMetalAllocatedBuffer( vertice: self ) : CAIMMetalSharedBuffer( vertice: self )
    }
    
    public var metalBuffer:MTLBuffer {
        if( _type == .alloc ) { ( _buffer as! CAIMMetalAllocatedBuffer).update( self.pointer!, length: self.length ) }
        return _buffer!.metalBuffer
    }
    
    public var memory:UnsafeMutablePointer<T> {
        return UnsafeMutablePointer<T>( OpaquePointer( self.pointer! ) )
    }
    
    public func draw( with encoder:MTLRenderCommandEncoder ) {
        encoder.setVertexBuffer( self.metalBuffer, at: _buffer_index )
    }
}

// 点メモリクラス
public class CAIMMetalPoints<T> : CAIMMetalShape<T>
{
    public init( count:Int = 0, at index:Int = 0, type:CAIMMetalBufferType = .alloc ) {
        super.init(span: MemoryLayout<T>.stride * 1, count: count, at:index, type:type)
    }
    
    public subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 1))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder ) {
        super.draw( with:encoder )
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: count )
    }
}

// ライン形状メモリクラス
public class CAIMMetalLines<T> : CAIMMetalShape<T>
{
    public init(count:Int = 0, at index:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 2, count: count, at:index, type: type)
    }
    
    public subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 2))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder ) {
        super.draw( with:encoder )
        encoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: count * 2)
    }
}


public struct CAIMMetalTriangleVertice<T> {
    public var p1:T, p2:T, p3:T
    public init( _ p1:T, _ p2:T, _ p3:T ) {
        self.p1 = p1; self.p2 = p2; self.p3 = p3
    }
}

// 三角形メッシュ形状メモリクラス
public class CAIMMetalTriangles<T> : CAIMMetalShape<T>
{
    public init( count:Int = 0, at index:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init( span: MemoryLayout<T>.stride * 3, count: count, at:index, type: type )
    }
    
    public subscript(idx:Int) -> CAIMMetalTriangleVertice<T> {
        get {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * 3) )
            let t_ptr = UnsafeMutablePointer<T>( opaqueptr )
            return CAIMMetalTriangleVertice<T>( t_ptr[0], t_ptr[1], t_ptr[2] )
        }
        set {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * 3) )
            let t_ptr = UnsafeMutablePointer<T>( opaqueptr )
            t_ptr[0] = newValue.p1
            t_ptr[1] = newValue.p2
            t_ptr[2] = newValue.p3
        }
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder ) {
        super.draw( with:encoder )
        encoder.drawPrimitives( type: .triangle, vertexStart: 0, vertexCount: count * 3 )
    }
}

public struct CAIMMetalQuadrangleVertice<T> {
    public var p1:T, p2:T, p3:T, p4:T
    public init( _ p1:T, _ p2:T, _ p3:T, _ p4:T ) {
        self.p1 = p1; self.p2 = p2; self.p3 = p3; self.p4 = p4
    }
}

// 四角形メッシュ形状メモリクラス
public class CAIMMetalQuadrangles<T> : CAIMMetalShape<T>
{
    public init(count:Int = 0, at index:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 4, count: count, at:index, type: type)
    }
    
    public subscript(idx:Int) -> CAIMMetalQuadrangleVertice<T> {
        get {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * 4) )
            let t_ptr = UnsafeMutablePointer<T>( opaqueptr )
            return CAIMMetalQuadrangleVertice<T>( t_ptr[0], t_ptr[1], t_ptr[2], t_ptr[3] )
        }
        set {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * 4) )
            let t_ptr = UnsafeMutablePointer<T>( opaqueptr )
            t_ptr[0] = newValue.p1
            t_ptr[1] = newValue.p2
            t_ptr[2] = newValue.p3
            t_ptr[3] = newValue.p4
        }
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder ) {
        super.draw( with:encoder )
        for i:Int in 0 ..< self.count {
            encoder.drawPrimitives( type: .triangleStrip, vertexStart: i*4, vertexCount: 4 )
        }
    }
}

#endif
