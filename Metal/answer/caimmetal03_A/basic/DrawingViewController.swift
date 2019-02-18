//
// DrawingViewController.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Metal

// 1頂点情報の構造体
struct Vertex {
    var pos:Float2 = Float2()
    var uv:Float2 = Float2()
    var rgba:Float4 = Float4()
}

// パーティクル情報
struct Particle {
    var pos:Float2 = Float2()           // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?       // Metalビュー

    private var pipeline_circle = CAIMMetalRenderPipeline()
    private var pipeline_ring = CAIMMetalRenderPipeline()
    
    private var mat:Matrix4x4 = .identity                         // 変換行列
    private var circles = CAIMMetalQuadrangles<Vertex>( count: 100 )   // 円用４頂点メッシュ群
    private var rings = CAIMMetalQuadrangles<Vertex>( count: 100 )     // リング用４頂点メッシュ群
    
    // パーティクル情報配列
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
        
        // 円描画の準備
        setupCircles()
        // リング描画の準備
        setupRings()
    }
    
    // 円描画の準備関数
    private func setupCircles() {
        // パイプラインの作成($0 = パイプライン設定オブジェクト)
        pipeline_circle.make {
            // シェーダの指定
            $0.vertexShader = CAIMMetalShader( "vert2d" )
            $0.fragmentShader = CAIMMetalShader( "fragCircleCosCurve" )
        }
        
        // 円のパーティクル情報配列を作る
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        for _ in 0 ..< circles.count {
            var p:Particle = Particle()
            
            p.pos = Float2( CAIM.random(wid), CAIM.random(hgt) )
            p.rgba = CAIMColor( CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random() )
            p.radius = CAIM.random( 100.0 )
            p.life = CAIM.random()
            
            circle_parts.append( p )
        }
    }
    
    // リング描画の準備関数
    private func setupRings() {
        // リング用パイプラインの作成($0 = パイプライン設定オブジェクト)
        pipeline_ring.make {
            // シェーダの指定
            $0.vertexShader = CAIMMetalShader( "vert2d" )
            $0.fragmentShader = CAIMMetalShader( "fragRing" )
        }
        
        // リング用のパーティクル情報を作る
        let wid = Float( metal_view!.pixelBounds.width )
        let hgt = Float( metal_view!.pixelBounds.height )
        for _ in 0 ..< rings.count {
            var p = Particle()
            
            p.pos = Float2( CAIM.random( wid ), CAIM.random( hgt ) )
            p.rgba = CAIMColor( CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random() )
            p.radius = CAIM.random( 100.0 )
            p.life = CAIM.random()
            
            ring_parts.append( p )
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
    override func update() {
        super.update()

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


