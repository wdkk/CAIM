//
// CAIMGeometric.swift
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
import simd
import Accelerate

// Metalバッファを出力できるようにするプロトコル
protocol CAIMBufferAllocatable {
    var metalBuffer:MTLBuffer { get }
    static var format:(MTLVertexFormat, Int) { get }
}
extension CAIMBufferAllocatable {
    var metalBuffer:MTLBuffer { return CAIMMetalAllocatedBuffer(self).metalBuffer! }
    static var format:(MTLVertexFormat, Int) { return (.invalid, 0) }
}

// Int2(8バイト)
typealias Int2 = vector_int2
extension Int2 : CAIMBufferAllocatable {
    init(_ x:Int32=0, _ y:Int32=0) { self.init(); self.x = x; self.y = y }
    static var zero:Int2 { return Int2() }
    static var format:(MTLVertexFormat, Int) { return (.int2, 8) }
}
// Int3(16バイト)
typealias Int3 = vector_int3
extension Int3 : CAIMBufferAllocatable {
    init(_ x:Int32=0, _ y:Int32=0, _ z:Int32=0) { self.init(); self.x = x; self.y = y; self.z = z }
    static var zero:Int3 { return Int3() }
    static var format:(MTLVertexFormat, Int) { return (.int3, 12) }
}
// Int4(16バイト)
typealias Int4 = vector_int4
extension Int4 : CAIMBufferAllocatable {
    init(_ x:Int32=0, _ y:Int32=0, _ z:Int32=0, _ w:Int32=0) { self.init(); self.x = x; self.y = y; self.z = z; self.w = w }
    static var zero:Int4 { return Int4() }
    static var format:(MTLVertexFormat, Int) { return (.int4, 16) }
}

// Size2(8バイト)
typealias Size2 = Int2
extension Size2 {
    var w:Int32 { get { return self.x } set { self.x = newValue } }
    var h:Int32 { get { return self.y } set { self.y = newValue } }
}
// Size3(16バイト)
typealias Size3 = Int3
extension Size3 {
    var w:Int32 { get { return self.x } set { self.x = newValue } }
    var h:Int32 { get { return self.y } set { self.y = newValue } }
    var d:Int32 { get { return self.z } set { self.z = newValue } }
}

// Float2(8バイト)
typealias Float2 = vector_float2
extension Float2 : CAIMBufferAllocatable {
    init(_ x:Float=0.0, _ y:Float=0.0) { self.init(); self.x = x; self.y = y }
    static var zero:Float2 { return Float2() }
    static var format:(MTLVertexFormat, Int) { return (.float2, 8) }
}
// Float3(16バイト)
typealias Float3 = vector_float3
extension Float3 : CAIMBufferAllocatable {
    init(_ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0) { self.init(); self.x = x; self.y = y; self.z = z }
    static var zero:Float3 { return Float3() }
    static var format:(MTLVertexFormat, Int) { return (.float3, 16) }
}
// Float4(16バイト)
typealias Float4 = vector_float4
extension Float4 : CAIMBufferAllocatable {
    init(_ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0, _ w:Float=1.0) { self.init(); self.x = x; self.y = y; self.z = z; self.w = w }
    static var zero:Float4 { return Float4() }
    static var format:(MTLVertexFormat, Int) { return (.float4, 16) }
}

// 3x3行列(48バイト)
typealias Matrix3x3 = matrix_float3x3
extension Matrix3x3 : CAIMBufferAllocatable {
    // 単位行列
    public init() {
        self.columns.0 = Float3(1, 0, 0)
        self.columns.1 = Float3(0, 1, 0)
        self.columns.2 = Float3(0, 0, 1)
    }
    // 単位行列
    static var identity:Matrix3x3 { return Matrix3x3() }
}

// 4x4行列(64バイト)
typealias Matrix4x4 = matrix_float4x4
extension Matrix4x4 : CAIMBufferAllocatable {
    // 単位行列
    public init() {
        self.columns.0 = Float4(1, 0, 0, 0)
        self.columns.1 = Float4(0, 1, 0, 0)
        self.columns.2 = Float4(0, 0, 1, 0)
        self.columns.3 = Float4(0, 0, 0, 1)
    }
    // 単位行列
    static var identity:Matrix4x4 { return Matrix4x4() }
    
    var X:Float4 { get { return columns.0 } set { columns.0 = newValue } }
    var Y:Float4 { get { return columns.1 } set { columns.1 = newValue } }
    var Z:Float4 { get { return columns.2 } set { columns.2 = newValue } }
    var W:Float4 { get { return columns.3 } set { columns.3 = newValue } }
    
    // 平行移動
    static func translate(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.W.x = x
        mat.W.y = y
        mat.W.z = z
        return mat
    }
    
    // 拡大縮小
    static func scale(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.X.x = x
        mat.Y.y = y
        mat.Z.z = z
        return mat
    }
    
    // 回転(三軸同時)
    static func rotate(axis: Float4, byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let c:Float = cos(angle)
        let s:Float = sin(angle)
        
        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.Y.x = axis.x * axis.y * (1 - c) - axis.z * s
        mat.Z.x = axis.x * axis.z * (1 - c) + axis.y * s
        
        mat.X.y = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Z.y = axis.y * axis.z * (1 - c) - axis.x * s
        
        mat.X.z = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Y.z = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c
        
        return mat
    }
    
    static func rotateX(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.Y.y = cosv
        mat.Z.y = -sinv
        mat.Y.z = sinv
        mat.Z.z = cosv
        
        return mat
    }
    
    static func rotateY(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.X.x = cosv
        mat.Z.x = sinv
        mat.X.z = -sinv
        mat.Z.z = cosv
        
        return mat
    }
    
    static func rotateZ(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.X.x = cosv
        mat.Y.x = -sinv
        mat.X.y = sinv
        mat.Y.y = cosv
        
        return mat
    }
    
    // ピクセル座標系変換行列
    static func pixelProjection(wid:Int, hgt:Int) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = .identity
        vp_mat.X.x =  2.0 / Float(wid)
        vp_mat.Y.y = -2.0 / Float(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    // ピクセル座標系変換行列
    static func pixelProjection(wid:CGFloat, hgt:CGFloat) -> Matrix4x4 {
        return pixelProjection(wid: Int(wid), hgt: Int(hgt))
    }
    // ピクセル座標系変換行列
    static func pixelProjection(_ size:CGSize) -> Matrix4x4 {
        return pixelProjection(wid: Int(size.width), hgt: Int(size.height))
    }
    
    static func ortho(left l: Float, right r: Float, bottom b: Float, top t: Float, near n: Float, far f: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        mat.X.x = 2.0 / (r-l)
        mat.W.x = (r+l) / (r-l)
        mat.Y.y = 2.0 / (t-b)
        mat.W.y = (t+b) / (t-b)
        mat.Z.z = -2.0 / (f-n)
        mat.W.z = (f+n) / (f-n)
        
        return mat
    }
    
    static func ortho2d(wid:Float, hgt:Float) -> Matrix4x4 {
        return ortho(left: 0, right: wid, bottom: hgt, top: 0, near: -1, far: 1)
    }
    
    // 透視投影変換行列(手前:Z軸正方向)
    static func perspective(aspect: Float, fieldOfViewY: Float, near: Float, far: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = Matrix4x4()
        
        let fov_radians:Float = fieldOfViewY * Float(Double.pi / 180.0)
        
        let y_scale:Float = 1 / tan(fov_radians * 0.5)
        let x_scale:Float = y_scale / aspect
        let z_range:Float = far - near
        let z_scale:Float = -(far + near) / z_range
        let wz_scale:Float = -2 * far * near / z_range
        
        mat.X.x = x_scale
        mat.Y.y = y_scale
        mat.Z.z = z_scale
        mat.Z.w = -1.0
        mat.W.z = wz_scale
        mat.W.w = 0.0
        
        return mat
    }
}
