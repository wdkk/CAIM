//
// DrawingViewController.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import simd

// 1頂点情報の構造体(VertexDescriptorを使うため、CAIMMetalVertexFormatterプロトコルを使用する)
struct Vertex : CAIMMetalVertexFormatter {
    var pos:Float2 = Float2()
    var uv:Float2 = Float2()
    var rgba:Float4 = Float4()

    // CAIMMetalVertexFormatterで作成を義務付けられる関数: 構造体の型と同じ型をformats: [...]のなかで指定していく
    static func vertexDescriptor(at idx: Int) -> MTLVertexDescriptor {
        return makeVertexDescriptor(at: idx, formats: [.float2, .float2, .float4])
    }
}

// パーティクル情報
struct Particle {
    var pos:Float2 = Float2()           // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

// モデル1つごとのユニフォーム
struct Uniform : CAIMMetalBufferAllocatable {
    var modelMatrix:Matrix4x4 = .identity
}

// 共有のユニフォーム
struct SharedUniform : CAIMMetalBufferAllocatable {
    var viewMatrix:Matrix4x4 = .identity
    var projectionMatrix:Matrix4x4 = .identity
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?       // Metalビュー

    private var uniform = Uniform()
    private var shared_uniform = SharedUniform()
    private var mesh = CAIMMetalMesh( with:"realship.obj", at:0 )
    private var texture:CAIMMetalTexture = CAIMMetalTexture( with:"shipDiffuse.png")
  
    private var pipeline_3d:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    private var pipeline_circle:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    private var pipeline_ring:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()
    
    private var mat:Matrix4x4 = .identity                                   // 変換行列
    private var circles = CAIMMetalQuadrangles<Vertex>(count: 100 )     // 円用４頂点メッシュ群
    private var rings = CAIMMetalQuadrangles<Vertex>(count: 100 )       // リング用４頂点メッシュ群
    
    private var circle_parts = [Particle]()     // 円用パーティクル情報
    private var ring_parts   = [Particle]()     // リング用パーティクル情報
    
    // 準備関数
    override func setup() {
        super.setup()
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat = Matrix4x4.pixelProjection( metal_view!.pixelBounds.size )
        // 3D描画の準備
        setup3D()
        // 円描画の準備
        setupCircles()
        // リング描画の準備
        setupRings()
    }
    
    
    private func setup3D() {
        // シェーダを指定してパイプライン作成
        pipeline_3d.vertexShader = CAIMMetalShader( "vert3d" )
        pipeline_3d.fragmentShader = CAIMMetalShader( "frag3d" )
        // 頂点をどのように使うのかを設定
        pipeline_3d.vertexDesc = CAIMMetalMesh.vertexDesc( at: 0 )
        // パイプラインのアルファ設定を無効にする
        pipeline_3d.blendType = .none
    }
    
    // 円描画の準備関数
    private func setupCircles() {
        // シェーダを指定してパイプラインレンダラの作成
        pipeline_circle.vertexShader = CAIMMetalShader( "vert2d" )
        pipeline_circle.fragmentShader = CAIMMetalShader( "fragCircleCosCurve" )
        
        // 円のパーティクル情報配列を作る
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        for _ in 0 ..< circles.count {
            var p = Particle()
            
            p.pos = Float2(CAIM.random(wid), CAIM.random(hgt))
            p.rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
            p.radius = CAIM.random(100.0)
            p.life = CAIM.random()
            
            circle_parts.append(p)
        }
    }
    
    // リング描画の準備関数
    private func setupRings() {
        // リング用のレンダラの作成
        pipeline_ring.vertexShader = CAIMMetalShader( "vert2d" )
        pipeline_ring.fragmentShader = CAIMMetalShader( "fragRing" )
        
        // リング用のパーティクル情報を作る
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        for _ in 0 ..< rings.count {
            var p = Particle()
            
            p.pos = Float2(CAIM.random(wid), CAIM.random(hgt))
            p.rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
            p.radius = CAIM.random(100.0)
            p.life = CAIM.random()
            
            ring_parts.append(p)
        }
    }
    
    // 円のパーティクル情報の更新
    private func updateCircles() {
        // パーティクル情報の更新
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        for i in 0 ..< circle_parts.count {
            // パーティクルのライフを減らす(3秒間)
            circle_parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if( circle_parts[i].life <= 0.0 ) {
                circle_parts[i].pos = Float2( CAIM.random(wid), CAIM.random(hgt) )
                circle_parts[i].rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
                circle_parts[i].radius = CAIM.random(100.0)
                circle_parts[i].life = 1.0
            }
        }
    }
    
    // 円のパーティクル情報から頂点メッシュ情報を更新
    private func genCirclesMesh() {
        for i in 0 ..< circles.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p = circle_parts[i]
            let x = p.pos.x                   // x座標
            let y = p.pos.y                   // y座標
            let r = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba = p.rgba                 // 色
            rgba.A *= p.life                  // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点1
            circles[i].p1 = Vertex( pos:Float2( x-r, y-r ), uv:Float2( -1.0, -1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点2
            circles[i].p2 = Vertex( pos:Float2( x+r, y-r ), uv:Float2( 1.0, -1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点3
            circles[i].p3 = Vertex( pos:Float2( x-r, y+r ), uv:Float2( -1.0, 1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点4
            circles[i].p4 = Vertex( pos:Float2( x+r, y+r ), uv:Float2( 1.0, 1.0 ), rgba:rgba.float4 )
        }
    }
    
    // リングのパーティクル情報の更新
    private func updateRings() {
        // パーティクル情報の更新
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        // リング用のパーティクル情報の更新
        for i in 0 ..< ring_parts.count {
            // パーティクルのライフを減らす(3秒間)
            ring_parts[i].life -= 1.0 / (3.0 * 60.0)
            // ライフが0以下になったら、新たなパーティクル情報を設定する
            if(ring_parts[i].life <= 0.0) {
                ring_parts[i].pos = Float2(CAIM.random(wid), CAIM.random(hgt))
                ring_parts[i].rgba = CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random())
                ring_parts[i].radius = CAIM.random(100.0)
                ring_parts[i].life = 1.0
            }
        }
    }
    
    // リングのパーティクル情報から頂点メッシュ情報を更新
    private func genRingsMesh() {
        // リングの全ての点の情報を更新
        for i in 0 ..< rings.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p = ring_parts[i]
            let x = p.pos.x                   // x座標
            let y = p.pos.y                   // y座標
            let r = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba = p.rgba                 // 色
            rgba.A *= p.life                  // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点1
            rings[i].p1 = Vertex( pos:Float2( x-r, y-r ), uv:Float2( -1.0, -1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点2
            rings[i].p2 = Vertex( pos:Float2( x+r, y-r ), uv:Float2( 1.0, -1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点3
            rings[i].p3 = Vertex( pos:Float2( x-r, y+r ), uv:Float2( -1.0, 1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点4
            rings[i].p4 = Vertex( pos:Float2( x+r, y+r ), uv:Float2( 1.0, 1.0 ), rgba:rgba.float4 )
        }
    }
    
    // 繰り返し処理関数
    var move:Float = 0.0
    override func update() {
        super.update()
        
        let aspect = Float( metal_view!.pixelBounds.width / metal_view!.pixelBounds.height )
        
        let trans:Matrix4x4  = .translate(0.0, 0.0, 0.0)
        let rotate_x:Matrix4x4 = .rotateX(byAngle: 30.toRadian)
        let rotate_y:Matrix4x4 = .rotateY(byAngle: move.toRadian)
        move += 0.5
        
        uniform.modelMatrix = trans * rotate_y * rotate_x
        
        shared_uniform.viewMatrix = Matrix4x4.translate(0.0, 0.0, -5.0)
        shared_uniform.projectionMatrix = Matrix4x4.perspective(aspect: aspect, fieldOfViewY: 60.0, near: 0.01, far: 1000.0)
        
        // 円情報の更新
        updateCircles()
        // 円情報で頂点メッシュ情報を更新
        genCirclesMesh()
        
        // リング情報の更新
        updateRings()
        // リング情報で頂点メッシュ情報を更新
        genRingsMesh()
        
        // MetalViewのレンダリングを実行
        metal_view?.execute( renderFunc: self.render )
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // エンコーダにカリングの設定
        encoder.setCullMode( .back )
        // エンコーダにデプスの設定
        let depth_desc = MTLDepthStencilDescriptor()
        // デプスを有効にする
        depth_desc.depthCompareFunction = .less
        depth_desc.isDepthWriteEnabled = true
        encoder.setDepthStencilDescriptor( depth_desc )
        
        // 準備したpipeline_3dを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_3d ) {
            // 頂点シェーダのバッファ1番に行列uniformをセット
            $0.setVertexBuffer( uniform, index: 1 )
            // 頂点シェーダのバッファ2番にユニフォーム行列shared_uniformをセット
            $0.setVertexBuffer( shared_uniform, index: 2 )
            // フラグメントシェーダのサンプラ0番にデフォルトのサンプラを設定
            $0.setFragmentSamplerState( CAIMMetalSampler.default, index: 0 )
            // フラグメントシェーダのテクスチャ0番にtextureを設定
            $0.setFragmentTexture( texture.metalTexture, index: 0 )
            
            // モデルのメッシュ群の頂点をバッファ0番にセットし描画を実行
            $0.drawShape( mesh, index:0 )
        }

        // エンコーダにカリングの設定
        encoder.setCullMode( .none )
        // エンコーダにデプスの設定
        let depth_desc2 = MTLDepthStencilDescriptor()
        // デプスを無効にしてすべて描画する
        depth_desc2.depthCompareFunction = .always
        depth_desc2.isDepthWriteEnabled = false
        encoder.setDepthStencilDescriptor( depth_desc2 )
        
        // 準備したpipeline_circleを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_circle ) {
            // 頂点シェーダのバッファ1番に行列matをセット
            $0.setVertexBuffer( mat, index:1 )
            // 円用の四角形データ群の頂点をバッファ0番にセットし描画を実行
            $0.drawShape( circles, index:0 )
        }
        
        // 準備したpipeline_ringを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_ring ) {
            // 頂点シェーダのバッファ1番に行列matをセット
            $0.setVertexBuffer( mat, index:1 )
            // リング用の四角形データ群の頂点をバッファ0番にセットし描画を実行
            $0.drawShape( rings, index:0 )
        }
    }
}

