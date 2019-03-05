//
//  CAIMARCapture.swift
//  caimmetal16_AR
//
//  Created by Kengo on 2017/12/13.
//  Copyright © 2017年 TUT Creative Application. All rights reserved.
//

import UIKit
import ARKit

// The max number of command buffers in flight
let kMaxBuffersInFlight: Int = 3

// Vertex data for an image plane
let kImagePlaneVertexData: [Float] = [
    -1.0, -1.0,  0.0, 1.0,
    1.0, -1.0,  1.0, 1.0,
    -1.0,  1.0,  0.0, 0.0,
    1.0,  1.0,  1.0, 0.0,
]

class CAIMARCapture {
    weak var ar_session:ARSession?
    private var ar_capture_pipeline = CAIMMetalRenderPipeline()
    var imagePlaneVertexBuffer: MTLBuffer!
    var capturedImageTextureCache: CVMetalTextureCache!
    var capturedImageTextureY: CVMetalTexture?
    var capturedImageTextureCbCr: CVMetalTexture?
    private var viewport_size:CGSize = .zero
    
    init( session:ARSession ) {
        self.ar_session = session
        
        let imagePlaneVertexDataCount = kImagePlaneVertexData.count * MemoryLayout<Float>.size
        imagePlaneVertexBuffer = CAIMMetal.device!.makeBuffer(bytes: kImagePlaneVertexData, length: imagePlaneVertexDataCount, options: [])
        
        ar_capture_pipeline.make {
            $0.vertexShader = CAIMMetalShader( "capturedImageVertexTransform" )
            $0.fragmentShader = CAIMMetalShader( "capturedImageFragmentShader" )

            // 頂点ディスクリプタ
            let vert_desc = MTLVertexDescriptor()
            vert_desc.attributes[0].format = .float2
            vert_desc.attributes[0].offset = 0
            vert_desc.attributes[0].bufferIndex = 0
            vert_desc.attributes[1].format = .float2
            vert_desc.attributes[1].offset = 8
            vert_desc.attributes[1].bufferIndex = 0
            vert_desc.layouts[0].stride = 16
            vert_desc.layouts[0].stepRate = 1
            $0.vertexDesc = vert_desc
        }
        // テクスチャキャッシュ
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, CAIMMetal.device!, nil, &textureCache)
        capturedImageTextureCache = textureCache
    }
    
    func clearTextures() {
        capturedImageTextureY = nil
        capturedImageTextureCbCr = nil
    }
    
    func updateCapturedImageTextures(frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        // YとCbCrの2つのテクスチャが取得できなければ処理をスキップ
        if (CVPixelBufferGetPlaneCount(pixelBuffer) < 2) { return }
        
        // テクスチャ作成関数
        func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
            let width  = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
            let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
            var texture:CVMetalTexture? = nil
            let status = CVMetalTextureCacheCreateTextureFromImage(nil, capturedImageTextureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
            if(status != kCVReturnSuccess) { texture = nil }
            return texture
        }
        // 新しいテクスチャの生成
        capturedImageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.r8Unorm, planeIndex:0)
        capturedImageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.rg8Unorm, planeIndex:1)
    }
    
    func updateImagePlane(frame: ARFrame) {
        let viewsize:CGSize = UIScreen.main.bounds.size
        if(viewport_size.width == viewsize.width || viewport_size.height == viewsize.height) { return }
        viewport_size = viewsize
        
        let displayToCameraTransform = frame.displayTransform(for: .portrait, viewportSize: viewport_size).inverted()
        
        let vertexData = imagePlaneVertexBuffer.contents().assumingMemoryBound(to: Float.self)
        for index in 0 ... 3 {
            let textureCoordIndex = 4 * index + 2
            let textureCoord = CGPoint(x: CGFloat(kImagePlaneVertexData[textureCoordIndex]), y: CGFloat(kImagePlaneVertexData[textureCoordIndex + 1]))
            // アフィン変換を適用
            let transformedCoord = textureCoord.applying(displayToCameraTransform)
            vertexData[textureCoordIndex] = Float(transformedCoord.x)
            vertexData[textureCoordIndex + 1] = Float(transformedCoord.y)
        }
    }
    
    func drawCapturedImage( encoder:MTLRenderCommandEncoder ) {
        guard let textureY = capturedImageTextureY, let textureCbCr = capturedImageTextureCbCr else { return }
      
        // カリングなし
        encoder.setCullMode( .none )
        // エンコーダにデプスの設定
        let depth_desc = MTLDepthStencilDescriptor()
        // デプスを無効にする
        depth_desc.depthCompareFunction = .always
        depth_desc.isDepthWriteEnabled = false
        encoder.setDepthStencilDescriptor( depth_desc )
        
        encoder.use( ar_capture_pipeline ) {
            $0.setVertexBuffer( imagePlaneVertexBuffer, offset:0, index: 0)
            $0.setFragmentTexture(CVMetalTextureGetTexture(textureY)!, index: 1)
            $0.setFragmentTexture(CVMetalTextureGetTexture(textureCbCr)!, index: 2)
        
            $0.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
    }
}

