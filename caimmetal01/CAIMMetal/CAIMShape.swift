//
// CAIMShape.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Foundation
import Metal

// Metal向け形状メモリクラス
class CAIMShape<T> : CAIMAlignMemory<T>
{
    func draw(_ renderer:CAIMMetalRenderer) {}
}

// 三角形メッシュ形状メモリクラス
class CAIMTriangles<T:Initializable> : CAIMShape<CAIMTriangle<T>>
{
    func update(_ triangles:[CAIMTriangle<T>]) {
        self.resize(count:triangles.count)
        let pointer = UnsafeMutableRawPointer(mutating: triangles)
        memcpy(self.pointer, pointer, triangles.count * MemoryLayout<CAIMTriangle<T>>.size)
    }
    
    override func draw(_ renderer:CAIMMetalRenderer) {
        let enc = renderer.encoder
        enc?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: length)
    }
}

// 四角形メッシュ形状メモリクラス
class CAIMQuadrangles<T:Initializable> : CAIMShape<CAIMQuadrangle<T>>
{
    func update(_ quadrangles:[CAIMQuadrangle<T>]) {
        self.resize(count:quadrangles.count)
        let pointer = UnsafeMutableRawPointer(mutating: quadrangles)
        memcpy(self.pointer, pointer, quadrangles.count * MemoryLayout<CAIMQuadrangle<T>>.size)
    }
    
    override func draw(_ renderer:CAIMMetalRenderer) {
        let count:Int = self.count
        let enc = renderer.encoder
        for i:Int in 0 ..< count {
            enc?.drawPrimitives(type: .triangleStrip, vertexStart: i*4, vertexCount: 4)
        }
    }
}
