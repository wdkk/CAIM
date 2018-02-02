//
// CAIMMetalShape.swift
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

public protocol CAIMMetalDrawable {
    func draw(with renderer:CAIMMetalRenderer)
}

// Metal向け形状メモリクラス
public class CAIMMetalShape<T> : CAIMMemory4K, CAIMMetalDrawable
{
    fileprivate var _metal_buffer:CAIMMetalBufferBase?
    fileprivate var _buffer_type:CAIMMetalBufferType = .alloc
    
    init(span:Int, count:Int, type:CAIMMetalBufferType = .alloc) {
        super.init(span: span, count: count)
        _buffer_type = type
        if(_buffer_type == .alloc) {
            _metal_buffer = CAIMMetalAllocatedBuffer(vertice: self) // メモリ確保型
        }
        else {
            _metal_buffer = CAIMMetalSharedBuffer(vertice: self)    // メモリ共有型
        }
    }
    
    public var metalBuffer:MTLBuffer {
        if(_buffer_type == .alloc) {
            _metal_buffer!.update(self.pointer!, length: self.length)
        }
        return _metal_buffer!.metalBuffer!
    }
    
    public var typePointer:UnsafeMutablePointer<T> {
        return UnsafeMutablePointer<T>(OpaquePointer(self.pointer!))
    }
    
    public func draw(with renderer:CAIMMetalRenderer) {}
}

// 点メモリクラス
class CAIMPoints<T> : CAIMMetalShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 1, count: count, type:type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 1))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw(with renderer:CAIMMetalRenderer) {
        let enc = renderer.currentEncoder
        enc?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: count)
    }
}

// ライン形状メモリクラス
class CAIMLines<T> : CAIMMetalShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 2, count: count, type: type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 2))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw(with renderer:CAIMMetalRenderer) {
        let enc = renderer.currentEncoder
        enc?.drawPrimitives(type: .line, vertexStart: 0, vertexCount: count * 2)
    }
}


// 三角形メッシュ形状メモリクラス
public class CAIMTriangles<T> : CAIMMetalShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 3, count: count, type: type)
    }

    public subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 3))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw(with renderer:CAIMMetalRenderer) {
        let enc = renderer.currentEncoder
        enc?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count * 3)
    }
}

// 四角形メッシュ形状メモリクラス
public class CAIMQuadrangles<T> : CAIMMetalShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 4, count: count, type: type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 4))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw(with renderer:CAIMMetalRenderer) {
        let count:Int = self.count
        let enc = renderer.currentEncoder
        for i:Int in 0 ..< count {
            enc?.drawPrimitives(type: .triangleStrip, vertexStart: i*4, vertexCount: 4)
        }
    }
}

// パネル型キューブメモリクラス
public struct CAIMPanelCubeParam
{
    // パネルの向き
    public enum PanelSide {
        case front
        case back
        case left
        case right
        case top
        case bottom
    }
    public var side:PanelSide = .front
    var pos:Float4 = Float4()
    var uv:Float2 = Float2()
}

public class CAIMPanelCubes<T> : CAIMMetalShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.stride * 24, count: count, type:type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * 24))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw(with renderer:CAIMMetalRenderer) {
        let count:Int = self.count
        let enc = renderer.currentEncoder
        // パネル1枚ずつ6枚で1キューブを描く
        for j:Int in 0 ..< count {
            for i:Int in 0 ..< 6 {
                enc?.drawPrimitives(type: .triangleStrip, vertexStart: (i * 4) + (j * 24), vertexCount: 4)
            }
        }
    }
    
    func set(idx:Int, pos:Float3, size:Float, iterator f: (Int,CAIMPanelCubeParam)->T) {
        let cube = self[idx]
        let sz = size / 2.0
        let x = pos.x
        let y = pos.y
        let z = pos.z
        
        let v = [
            // Front
            CAIMPanelCubeParam(side: .front, pos: Float4(-sz+x, sz+y, sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .front, pos: Float4( sz+x, sz+y, sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .front, pos: Float4(-sz+x,-sz+y, sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .front, pos: Float4( sz+x,-sz+y, sz+z, 1.0), uv:Float2(1, 0)),
            // Back
            CAIMPanelCubeParam(side: .back, pos: Float4( sz+x, sz+y,-sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .back, pos: Float4(-sz+x, sz+y,-sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .back, pos: Float4( sz+x,-sz+y,-sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .back, pos: Float4(-sz+x,-sz+y,-sz+z, 1.0), uv:Float2(1, 0)),
            // Left
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x, sz+y,-sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x, sz+y, sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x,-sz+y,-sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x,-sz+y, sz+z, 1.0), uv:Float2(1, 0)),
            // Right
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x, sz+y, sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x, sz+y,-sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x,-sz+y, sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x,-sz+y,-sz+z, 1.0), uv:Float2(1, 0)),
            // Top
            CAIMPanelCubeParam(side: .top, pos: Float4(-sz+x, sz+y,-sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .top, pos: Float4( sz+x, sz+y,-sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .top, pos: Float4(-sz+x, sz+y, sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .top, pos: Float4( sz+x, sz+y, sz+z, 1.0), uv:Float2(1, 0)),
            // Bottom
            CAIMPanelCubeParam(side: .bottom, pos: Float4(-sz+x,-sz+y, sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .bottom, pos: Float4( sz+x,-sz+y, sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .bottom, pos: Float4(-sz+x,-sz+y,-sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .bottom, pos: Float4( sz+x,-sz+y,-sz+z, 1.0), uv:Float2(1, 0)),
            ]
        
        for i:Int in 0 ..< 24 {
            cube[i] = f(i, v[i])
        }
    }
}

