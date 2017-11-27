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

// パネル型キューブメモリクラス
public struct CAIMPanelCubeInfo
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
    var side:PanelSide = .front
    var pos:Vec4 = Vec4()
    var uv:Vec2  = Vec2()
}

class CAIMPanelCubes<T> : CAIMShape<T>
{
    init(count:Int = 0, type:CAIMMetalBufferType = .alloc) {
        super.init(span: MemoryLayout<T>.size * 24, count: count, type:type)
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.size * 24))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    override func render(by renderer:CAIMMetalRenderer) {
        let count:Int = self.count
        let enc = renderer.encoder
        // パネル1枚ずつ6枚で1キューブを描く
        for j:Int in 0 ..< count {
            for i:Int in 0 ..< 6 {
                enc?.drawPrimitives(type: .triangleStrip, vertexStart: (i * 4) + (j * 24), vertexCount: 4)
            }
        }
    }
    
    func set(idx:Int, pos:Vec3, size:Float, iterator f: (Int,CAIMPanelCubeInfo)->T) {
        let cube = self[idx]
        let sz = size / 2.0
        let x = pos.x
        let y = pos.y
        let z = pos.z
        
        let v = [
            // Front
            CAIMPanelCubeInfo(side: .front, pos: Vec4(-sz+x, sz+y, sz+z, 1.0), uv:Vec2(0, 0)),
            CAIMPanelCubeInfo(side: .front, pos: Vec4( sz+x, sz+y, sz+z, 1.0), uv:Vec2(1, 0)),
            CAIMPanelCubeInfo(side: .front, pos: Vec4(-sz+x,-sz+y, sz+z, 1.0), uv:Vec2(0, 1)),
            CAIMPanelCubeInfo(side: .front, pos: Vec4( sz+x,-sz+y, sz+z, 1.0), uv:Vec2(1, 1)),
            // Back
            CAIMPanelCubeInfo(side: .back, pos: Vec4( sz+x, sz+y,-sz+z, 1.0), uv:Vec2(0, 0)),
            CAIMPanelCubeInfo(side: .back, pos: Vec4(-sz+x, sz+y,-sz+z, 1.0), uv:Vec2(1, 0)),
            CAIMPanelCubeInfo(side: .back, pos: Vec4( sz+x,-sz+y,-sz+z, 1.0), uv:Vec2(0, 1)),
            CAIMPanelCubeInfo(side: .back, pos: Vec4(-sz+x,-sz+y,-sz+z, 1.0), uv:Vec2(1, 1)),
            // Left
            CAIMPanelCubeInfo(side: .left, pos: Vec4(-sz+x, sz+y,-sz+z, 1.0), uv:Vec2(0, 0)),
            CAIMPanelCubeInfo(side: .left, pos: Vec4(-sz+x, sz+y, sz+z, 1.0), uv:Vec2(1, 0)),
            CAIMPanelCubeInfo(side: .left, pos: Vec4(-sz+x,-sz+y,-sz+z, 1.0), uv:Vec2(0, 1)),
            CAIMPanelCubeInfo(side: .left, pos: Vec4(-sz+x,-sz+y, sz+z, 1.0), uv:Vec2(1, 1)),
            // Right
            CAIMPanelCubeInfo(side: .right, pos: Vec4( sz+x, sz+y, sz+z, 1.0), uv:Vec2(0, 0)),
            CAIMPanelCubeInfo(side: .right, pos: Vec4( sz+x, sz+y,-sz+z, 1.0), uv:Vec2(1, 0)),
            CAIMPanelCubeInfo(side: .right, pos: Vec4( sz+x,-sz+y, sz+z, 1.0), uv:Vec2(0, 1)),
            CAIMPanelCubeInfo(side: .right, pos: Vec4( sz+x,-sz+y,-sz+z, 1.0), uv:Vec2(1, 1)),
            // Top
            CAIMPanelCubeInfo(side: .top, pos: Vec4(-sz+x, sz+y,-sz+z, 1.0), uv:Vec2(0, 0)),
            CAIMPanelCubeInfo(side: .top, pos: Vec4( sz+x, sz+y,-sz+z, 1.0), uv:Vec2(1, 0)),
            CAIMPanelCubeInfo(side: .top, pos: Vec4(-sz+x, sz+y, sz+z, 1.0), uv:Vec2(0, 1)),
            CAIMPanelCubeInfo(side: .top, pos: Vec4( sz+x, sz+y, sz+z, 1.0), uv:Vec2(1, 1)),
            // Bottom
            CAIMPanelCubeInfo(side: .bottom, pos: Vec4(-sz+x,-sz+y, sz+z, 1.0), uv:Vec2(0, 0)),
            CAIMPanelCubeInfo(side: .bottom, pos: Vec4( sz+x,-sz+y, sz+z, 1.0), uv:Vec2(1, 0)),
            CAIMPanelCubeInfo(side: .bottom, pos: Vec4(-sz+x,-sz+y,-sz+z, 1.0), uv:Vec2(0, 1)),
            CAIMPanelCubeInfo(side: .bottom, pos: Vec4( sz+x,-sz+y,-sz+z, 1.0), uv:Vec2(1, 1)),
            ]
        
        for i:Int in 0 ..< 24 {
            cube[i] = f(i, v[i])
        }
        
    }
}

