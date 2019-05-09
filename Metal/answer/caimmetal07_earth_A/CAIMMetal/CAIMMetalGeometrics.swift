//
// CAIMMetalGeometrics.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Foundation
import CoreGraphics
import Metal
import simd

// Int2(8バイト)
public struct Int2 : CAIMMetalBufferAllocatable {
    public private(set) var simdv:vector_int2
    public var x:Int32 { get { return simdv.x } set { simdv.x = newValue } }
    public var y:Int32 { get { return simdv.y } set { simdv.y = newValue } }
    public init( _ x:Int32 = 0, _ y:Int32 = 0 ) { simdv = [x, y] }
    public init( _ vec:vector_int2 ) { simdv = vec }
    public static var zero:Int2 { return Int2() }
}
// vector_int2拡張
public extension vector_int2 {
    var int2:Int2 { return Int2( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.simdv &+ right.simdv )
}
public func - ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.simdv &- right.simdv )
}
public func * ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.simdv &* right.simdv )
}
public func / ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.simdv / right.simdv )
}

// Int3(16バイト)
public struct Int3 : CAIMMetalBufferAllocatable {
    public private(set) var simdv:vector_int3
    public var x:Int32 { get { return simdv.x } set { simdv.x = newValue } }
    public var y:Int32 { get { return simdv.y } set { simdv.y = newValue } }
    public var z:Int32 { get { return simdv.z } set { simdv.z = newValue } }
    public init( _ x:Int32 = 0, _ y:Int32 = 0, _ z:Int32 = 0 ) { simdv = [x, y, z] }
    public init( _ vec:vector_int3 ) { simdv = vec }
    public static var zero:Int3 { return Int3() }
}
// vector_int3拡張
public extension vector_int3 {
    var int3:Int3 { return Int3( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.simdv &+ right.simdv )
}
public func - ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.simdv &- right.simdv )
}
public func * ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.simdv &* right.simdv )
}
public func / ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.simdv / right.simdv )
}


// Int4(16バイト)
public struct Int4 : CAIMMetalBufferAllocatable {
    public private(set) var simdv:vector_int4
    public var x:Int32 { get { return simdv.x } set { simdv.x = newValue } }
    public var y:Int32 { get { return simdv.y } set { simdv.y = newValue } }
    public var z:Int32 { get { return simdv.z } set { simdv.z = newValue } }
    public var w:Int32 { get { return simdv.w } set { simdv.w = newValue } }
    public init( _ x:Int32 = 0, _ y:Int32 = 0, _ z:Int32 = 0, _ w:Int32 = 0 ) { simdv = [x, y, z, w] }
    public init( _ vec:vector_int4 ) { simdv = vec }
    public static var zero:Int4 { return Int4() }
}
// vector_int3拡張
public extension vector_int4 {
    var int4:Int4 { return Int4( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.simdv &+ right.simdv )
}
public func - ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.simdv &- right.simdv )
}
public func * ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.simdv &* right.simdv )
}
public func / ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.simdv / right.simdv )
}

// Size2(8バイト)
public typealias Size2 = Int2
extension Size2 {
    public var width:Int32  { get { return self.x } set { self.x = newValue } }
    public var height:Int32 { get { return self.y } set { self.y = newValue } }
}
// Size3(16バイト)
public typealias Size3 = Int3
extension Size3 {
    public var width:Int32  { get { return self.x } set { self.x = newValue } }
    public var height:Int32 { get { return self.y } set { self.y = newValue } }
    public var depth:Int32  { get { return self.z } set { self.z = newValue } }
}

// Float2(8バイト)
public struct Float2 : CAIMMetalBufferAllocatable {
    public private(set) var simdv:vector_float2
    public var x:Float { get { return simdv.x } set { simdv.x = newValue } }
    public var y:Float { get { return simdv.y } set { simdv.y = newValue } }
    public init( _ x:Float=0.0, _ y:Float=0.0 ) { simdv = [x, y] }
    public init( _ vec:vector_float2 ) { simdv = vec }
    public static var zero:Float2 { return Float2() }
}
// vector_float2拡張
public extension vector_float2 {
    var float2:Float2 { return Float2( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.simdv + right.simdv )
}
public func - ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.simdv - right.simdv )
}
public func * ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.simdv * right.simdv )
}
public func / ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.simdv / right.simdv )
}

// Float3(16バイト)
public struct Float3 : CAIMMetalBufferAllocatable {
    public private(set) var simdv:vector_float3
    public var x:Float { get { return simdv.x } set { simdv.x = newValue } }
    public var y:Float { get { return simdv.y } set { simdv.y = newValue } }
    public var z:Float { get { return simdv.z } set { simdv.z = newValue } }
    public init( _ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0 ) { simdv = [x, y, z] }
    public init( _ vec:vector_float3 ) { simdv = vec }
    public static var zero:Float3 { return Float3() }
}
// vector_float3拡張
public extension vector_float3 {
    var float3:Float3 { return Float3( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.simdv + right.simdv )
}
public func - ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.simdv - right.simdv )
}
public func * ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.simdv * right.simdv )
}
public func / ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.simdv / right.simdv )
}

// Float4(16バイト)
public struct Float4 : CAIMMetalBufferAllocatable {
    public private(set) var simdv:vector_float4
    public var x:Float { get { return simdv.x } set { simdv.x = newValue } }
    public var y:Float { get { return simdv.y } set { simdv.y = newValue } }
    public var z:Float { get { return simdv.z } set { simdv.z = newValue } }
    public var w:Float { get { return simdv.w } set { simdv.w = newValue } }
    public init( _ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0, _ w:Float=0.0 ) { simdv = [x, y, z, w] }
    public init( _ vec:vector_float4 ) { simdv = vec }
    public static var zero:Float4 { return Float4() }
}
// vector_float4拡張
public extension vector_float4 {
    var float4:Float4 { return Float4( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.simdv + right.simdv )
}
public func - ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.simdv - right.simdv )
}
public func * ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.simdv * right.simdv )
}
public func / ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.simdv / right.simdv )
}

// 3x3行列(48バイト)
public struct Matrix3x3 : CAIMMetalBufferAllocatable {
    public private(set) var matv:matrix_float3x3
    
    public var X:Float3 { get { return matv.columns.0.float3 } set { matv.columns.0 = newValue.simdv } }
    public var Y:Float3 { get { return matv.columns.1.float3 } set { matv.columns.1 = newValue.simdv } }
    public var Z:Float3 { get { return matv.columns.2.float3 } set { matv.columns.2 = newValue.simdv } }
   
    public init() {
        matv = matrix_float3x3( 0.0 )
    }
    public init( _ columns:[float3] ) {
        matv = matrix_float3x3( columns )
    }
    public init( _ simdv:matrix_float3x3 ) {
        matv = simdv
    }
    
    // 単位行列
    public static var identity:Matrix3x3 {
         return Matrix3x3([
            [ 1.0, 0.0, 0.0 ],
            [ 0.0, 1.0, 0.0 ],
            [ 0.0, 0.0, 1.0 ]
        ])
    }
}
// 演算子オーバーロード
public func + ( _ left:Matrix3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matv + right.matv )
}

public func - ( _ left:Matrix3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matv - right.matv )
}

public func * ( _ left:Matrix3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matv * right.matv )
}

// 4x4行列(64バイト)
public struct Matrix4x4 : CAIMMetalBufferAllocatable {
    public private(set) var matv:matrix_float4x4
    
    public var X:Float4 { get { return matv.columns.0.float4 } set { matv.columns.0 = newValue.simdv } }
    public var Y:Float4 { get { return matv.columns.1.float4 } set { matv.columns.1 = newValue.simdv } }
    public var Z:Float4 { get { return matv.columns.2.float4 } set { matv.columns.2 = newValue.simdv } }
    public var W:Float4 { get { return matv.columns.3.float4 } set { matv.columns.3 = newValue.simdv } }

    public init() {
        matv = matrix_float4x4( 0.0 )
    }
    public init( _ columns:[float4] ) {
        matv = matrix_float4x4( columns )
    }
    public init( _ simdv:matrix_float4x4 ) {
        matv = simdv
    }
    
    // 単位行列
    public static var identity:Matrix4x4 {
        return Matrix4x4( [
            [ 1.0, 0.0, 0.0, 0.0 ],
            [ 0.0, 1.0, 0.0, 0.0 ],
            [ 0.0, 0.0, 1.0, 0.0 ],
            [ 0.0, 0.0, 0.0, 1.0 ]
        ])
    }

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
// 演算子オーバーロード
public func + ( _ left:Matrix4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matv + right.matv )
}

public func - ( _ left:Matrix4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matv - right.matv )
}

public func * ( _ left:Matrix4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matv * right.matv )
}
