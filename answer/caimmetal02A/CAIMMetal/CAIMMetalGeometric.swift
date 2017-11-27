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

protocol Buffer {
    var metalBuffer:CAIMMetalBuffer { get }
}
extension Buffer {
    var metalBuffer:CAIMMetalBuffer { return CAIMMetalBuffer(self) }
}

struct Vec2 : Buffer {
    var x: Float, y: Float
    
    init(_ x:Float=0.0, _ y:Float=0.0) { self.x = x; self.y = y }
    static var zero:Vec2 { return Vec2() }
}

struct Vec3 : Buffer {
    var x: Float, y: Float, z: Float
    
    init(_ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0) { self.x = x; self.y = y; self.z = z }
    static var zero:Vec3 { return Vec3() }
}

struct Vec4 : Buffer {
    var x: Float, y: Float, z: Float, w: Float
    
    init(_ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0, _ w:Float=1.0) { self.x = x; self.y = y; self.z = z; self.w = w }
    static var zero:Vec4 { return Vec4() }
}

struct Size2 : Buffer {
    var w: Int32, h: Int32
    init(_ wid:Int32=0, _ hgt:Int32=0) { self.w = wid; self.h = hgt }
    static var zero:Size2 { return Size2() }
}

struct Matrix4x4 : Buffer {
    var X: Vec4, Y: Vec4, Z: Vec4, W: Vec4
    
    // 単位行列
    init() {
        X = Vec4(1, 0, 0, 0)
        Y = Vec4(0, 1, 0, 0)
        Z = Vec4(0, 0, 1, 0)
        W = Vec4(0, 0, 0, 1)
    }
    
    // 単位行列
    static var identity:Matrix4x4 { return Matrix4x4() }
    
    // ピクセル座標系変換行列
    static func pixelProjection(wid:Int, hgt:Int) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = Matrix4x4()
        vp_mat.X.x =  2.0 / Float(wid)
        vp_mat.Y.y = -2.0 / Float(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    
    // ピクセル座標系変換行列
    static func pixelProjection(wid:CGFloat, hgt:CGFloat) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = Matrix4x4()
        vp_mat.X.x =  2.0 / Float(wid)
        vp_mat.Y.y = -2.0 / Float(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    
    // ピクセル座標系変換行列
    static func pixelProjection(_ size:CGSize) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = Matrix4x4()
        vp_mat.X.x =  2.0 / Float(size.width)
        vp_mat.Y.y = -2.0 / Float(size.height)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    
    static func rotate(axis: Vec4, byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = Matrix4x4()
        
        let c:Float = cos(angle)
        let s:Float = sin(angle)
        
        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.X.y = axis.x * axis.y * (1 - c) - axis.z * s
        mat.X.z = axis.x * axis.z * (1 - c) + axis.y * s
        
        mat.Y.x = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Y.z = axis.y * axis.z * (1 - c) - axis.x * s
        
        mat.Z.x = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Z.y = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c
        
        return mat
    }
    
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
    
    static func translate(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.W.x = x
        mat.W.y = y
        mat.W.z = z
        return mat
    }
}

func * (left: Matrix4x4, right:Matrix4x4) -> Matrix4x4 {
    var mat:Matrix4x4 = Matrix4x4()
    
    mat.X.x = (left.X.x * right.X.x) + (left.X.y * right.Y.x) + (left.X.z * right.Z.x) + (left.X.w * right.W.x)
    mat.X.y = (left.X.x * right.X.y) + (left.X.y * right.Y.y) + (left.X.z * right.Z.y) + (left.X.w * right.W.y)
    mat.X.z = (left.X.x * right.X.z) + (left.X.y * right.Y.z) + (left.X.z * right.Z.z) + (left.X.w * right.W.z)
    mat.X.w = (left.X.x * right.X.w) + (left.X.y * right.Y.w) + (left.X.z * right.Z.w) + (left.X.w * right.W.w)
    
    mat.Y.x = (left.Y.x * right.X.x) + (left.Y.y * right.Y.x) + (left.Y.z * right.Z.x) + (left.Y.w * right.W.x)
    mat.Y.y = (left.Y.x * right.X.y) + (left.Y.y * right.Y.y) + (left.Y.z * right.Z.y) + (left.Y.w * right.W.y)
    mat.Y.z = (left.Y.x * right.X.z) + (left.Y.y * right.Y.z) + (left.Y.z * right.Z.z) + (left.Y.w * right.W.z)
    mat.Y.w = (left.Y.x * right.X.w) + (left.Y.y * right.Y.w) + (left.Y.z * right.Z.w) + (left.Y.w * right.W.w)
    
    mat.Z.x = (left.Z.x * right.X.x) + (left.Z.y * right.Y.x) + (left.Z.z * right.Z.x) + (left.Z.w * right.W.x)
    mat.Z.y = (left.Z.x * right.X.y) + (left.Z.y * right.Y.y) + (left.Z.z * right.Z.y) + (left.Z.w * right.W.y)
    mat.Z.z = (left.Z.x * right.X.z) + (left.Z.y * right.Y.z) + (left.Z.z * right.Z.z) + (left.Z.w * right.W.z)
    mat.Z.w = (left.Z.x * right.X.w) + (left.Z.y * right.Y.w) + (left.Z.z * right.Z.w) + (left.Z.w * right.W.w)
    
    mat.W.x = (left.W.x * right.X.x) + (left.W.y * right.Y.x) + (left.W.z * right.Z.x) + (left.W.w * right.W.x)
    mat.W.y = (left.W.x * right.X.y) + (left.W.y * right.Y.y) + (left.W.z * right.Z.y) + (left.W.w * right.W.y)
    mat.W.z = (left.W.x * right.X.z) + (left.W.y * right.Y.z) + (left.W.z * right.Z.z) + (left.W.w * right.W.z)
    mat.W.w = (left.W.x * right.X.w) + (left.W.y * right.Y.w) + (left.W.z * right.Z.w) + (left.W.w * right.W.w)
    
    return mat
}
