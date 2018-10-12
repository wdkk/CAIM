//
// CAIMMetalGeometrics.swift
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

// Metalバッファを出力できるようにするプロトコル
public protocol CAIMMetalBufferAllocatable {
    #if os(macOS) || (os(iOS) && !arch(x86_64))
    var metalBuffer:MTLBuffer { get }
    #endif
}
public extension CAIMMetalBufferAllocatable {
    #if os(macOS) || (os(iOS) && !arch(x86_64))
    public var metalBuffer:MTLBuffer { return CAIMMetalAllocatedBuffer( self ).metalBuffer }
    #endif
}

// Int2(8バイト)
public typealias Int2 = vector_int2
extension Int2 : CAIMMetalBufferAllocatable {
    public init( x:Int32=0, y:Int32=0 ) { self.init(); self.x = x; self.y = y }
    public static var zero:Int2 { return Int2() }
}
// Int3(16バイト)
public typealias Int3 = vector_int3
extension Int3 : CAIMMetalBufferAllocatable {
    public init( x:Int32=0, y:Int32=0, z:Int32=0 ) { self.init(); self.x = x; self.y = y; self.z = z }
    public static var zero:Int3 { return Int3() }
}
// Int4(16バイト)
public typealias Int4 = vector_int4
extension Int4 : CAIMMetalBufferAllocatable {
    public init( x:Int32=0, y:Int32=0, z:Int32=0, w:Int32=0 ) { self.init(); self.x = x; self.y = y; self.z = z; self.w = w }
    public static var zero:Int4 { return Int4() }
}

// Size2(8バイト)
public typealias Size2 = Int2
extension Size2 {
    public var w:Int32 { get { return self.x } set { self.x = newValue } }
    public var h:Int32 { get { return self.y } set { self.y = newValue } }
}
// Size3(16バイト)
public typealias Size3 = Int3
extension Size3 {
    public var w:Int32 { get { return self.x } set { self.x = newValue } }
    public var h:Int32 { get { return self.y } set { self.y = newValue } }
    public var d:Int32 { get { return self.z } set { self.z = newValue } }
}

// Float2(8バイト)
public typealias Float2 = vector_float2
extension Float2 : CAIMMetalBufferAllocatable {
    public init( x:Float=0.0, y:Float=0.0 ) { self.init(); self.x = x; self.y = y }
    public static var zero:Float2 { return Float2() }
}
// Float3(16バイト)
public typealias Float3 = vector_float3
extension Float3 : CAIMMetalBufferAllocatable {
    public init( x:Float=0.0, y:Float=0.0, z:Float=0.0 ) { self.init(); self.x = x; self.y = y; self.z = z }
    public static var zero:Float3 { return Float3() }
}
// Float4(16バイト)
public typealias Float4 = vector_float4
extension Float4 : CAIMMetalBufferAllocatable {
    public init( x:Float=0.0, y:Float=0.0, z:Float=0.0, w:Float=1.0 ) { self.init(); self.x = x; self.y = y; self.z = z; self.w = w }
    public static var zero:Float4 { return Float4() }
}

// 3x3行列(48バイト)
public typealias Matrix3x3 = matrix_float3x3
extension Matrix3x3 : CAIMMetalBufferAllocatable {
    // 単位行列
    public static var identity:Matrix3x3 {
        var mat = Matrix3x3()
        mat.columns.0 = Float3(1, 0, 0)
        mat.columns.1 = Float3(0, 1, 0)
        mat.columns.2 = Float3(0, 0, 1)
        return mat
    }
}

// 4x4行列(64バイト)
public typealias Matrix4x4 = matrix_float4x4
extension Matrix4x4 : CAIMMetalBufferAllocatable {
    // 単位行列
    public static var identity:Matrix4x4 {
        var mat = Matrix4x4()
        mat.columns.0 = Float4(1, 0, 0, 0)
        mat.columns.1 = Float4(0, 1, 0, 0)
        mat.columns.2 = Float4(0, 0, 1, 0)
        mat.columns.3 = Float4(0, 0, 0, 1)
        return mat
    }
    
    public var X:Float4 { get { return columns.0 } set { columns.0 = newValue } }
    public var Y:Float4 { get { return columns.1 } set { columns.1 = newValue } }
    public var Z:Float4 { get { return columns.2 } set { columns.2 = newValue } }
    public var W:Float4 { get { return columns.3 } set { columns.3 = newValue } }
    
    // 平行移動
    public static func translate(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.W.x = x
        mat.W.y = y
        mat.W.z = z
        return mat
    }
    
    // 拡大縮小
    public static func scale(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.X.x = x
        mat.Y.y = y
        mat.Z.z = z
        return mat
    }
    
    // 回転(三軸同時)
    public static func rotate(axis: Float4, byAngle angle: Float) -> Matrix4x4 {
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
    
    public static func rotateX(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.Y.y = cosv
        mat.Z.y = -sinv
        mat.Y.z = sinv
        mat.Z.z = cosv
        
        return mat
    }
    
    public static func rotateY(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.X.x = cosv
        mat.Z.x = sinv
        mat.X.z = -sinv
        mat.Z.z = cosv
        
        return mat
    }
    
    public static func rotateZ(byAngle angle: Float) -> Matrix4x4 {
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
    public static func pixelProjection(wid:Int, hgt:Int) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = .identity
        vp_mat.X.x =  2.0 / Float(wid)
        vp_mat.Y.y = -2.0 / Float(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    public static func pixelProjection(wid:CGFloat, hgt:CGFloat) -> Matrix4x4 {
        return pixelProjection(wid: Int(wid), hgt: Int(hgt))
    }
    public static func pixelProjection(wid:Float, hgt:Float) -> Matrix4x4 {
        return pixelProjection(wid: Int(wid), hgt: Int(hgt))
    }
    public static func pixelProjection(_ size:CGSize) -> Matrix4x4 {
        return pixelProjection(wid: Int(size.width), hgt: Int(size.height))
    }
    
    public static func ortho(left l: Float, right r: Float, bottom b: Float, top t: Float, near n: Float, far f: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        mat.X.x = 2.0 / (r-l)
        mat.W.x = (r+l) / (r-l)
        mat.Y.y = 2.0 / (t-b)
        mat.W.y = (t+b) / (t-b)
        mat.Z.z = -2.0 / (f-n)
        mat.W.z = (f+n) / (f-n)
        
        return mat
    }
    
    public static func ortho2d(wid:Float, hgt:Float) -> Matrix4x4 {
        return ortho(left: 0, right: wid, bottom: hgt, top: 0, near: -1, far: 1)
    }
    
    // 透視投影変換行列(手前:Z軸正方向)
    public static func perspective(aspect: Float, fieldOfViewY: Float, near: Float, far: Float) -> Matrix4x4 {
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

public func + ( left:Matrix4x4, right:Matrix4x4 ) -> Matrix4x4 {
    return simd_add(left, right)
}

public func - ( left:Matrix4x4, right:Matrix4x4 ) -> Matrix4x4 {
    return simd_sub(left, right)
}

public func * ( left:Matrix4x4, right:Matrix4x4 ) -> Matrix4x4 {
    return simd_mul(left, right)
}

public func += ( left:Matrix4x4, right:Matrix4x4 ) -> Matrix4x4 {
    return simd_add(left, right)
}

public func -= ( left:Matrix4x4, right:Matrix4x4 ) -> Matrix4x4 {
    return simd_sub(left, right)
}

public func *= ( left:Matrix4x4, right:Matrix4x4 ) -> Matrix4x4 {
    return simd_mul(left, right)
}
