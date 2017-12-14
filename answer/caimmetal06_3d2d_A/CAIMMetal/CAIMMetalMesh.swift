//
// CAIMMetalTexture.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit
import Metal
import MetalKit

public class CAIMMetalMesh : CAIMMetalDrawable {
    var metalMesh: MTKMesh?
    var metalVertexBuffer:MTLBuffer { return metalMesh!.vertexBuffers[0].buffer }
    
    static func vertexDesc(at index:Int) -> MTLVertexDescriptor {
        let mtl_vertex = MTLVertexDescriptor()
        mtl_vertex.attributes[0].format = .float3
        mtl_vertex.attributes[0].offset = 0
        mtl_vertex.attributes[0].bufferIndex = 0
        mtl_vertex.attributes[1].format = .float3
        mtl_vertex.attributes[1].offset = 12
        mtl_vertex.attributes[1].bufferIndex = 0
        mtl_vertex.attributes[2].format = .float2
        mtl_vertex.attributes[2].offset = 24
        mtl_vertex.attributes[2].bufferIndex = 0
        mtl_vertex.layouts[index].stride = 32
        mtl_vertex.layouts[index].stepRate = 1
        return mtl_vertex
    }
    
    public init(with path:String, at index:Int) {
        metalMesh = self.load(with:path, at:index)
    }
    
    private func load(with path: String, at index:Int) -> MTKMesh {
        let modelDescriptor3D = MTKModelIOVertexDescriptorFromMetal(CAIMMetalMesh.vertexDesc(at:index))
        (modelDescriptor3D.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (modelDescriptor3D.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (modelDescriptor3D.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        
        let allocator = MTKMeshBufferAllocator(device: CAIMMetal.device)
        let asset = MDLAsset(url: URL(fileURLWithPath:CAIM.bundle(path)),
                             vertexDescriptor: modelDescriptor3D,
                             bufferAllocator: allocator)
        let newMesh = try! MTKMesh.newMeshes(asset: asset, device: CAIMMetal.device)
        return newMesh.metalKitMeshes.first!
    }
    
    public func draw(with renderer:CAIMMetalRenderer) {
        let enc = renderer.currentEncoder
        
        let submesh = metalMesh!.submeshes[0]
 
        enc?.drawIndexedPrimitives(type: submesh.primitiveType,
                                   indexCount: submesh.indexCount,
                                   indexType: submesh.indexType,
                                   indexBuffer: submesh.indexBuffer.buffer,
                                   indexBufferOffset: submesh.indexBuffer.offset)
    }
}


