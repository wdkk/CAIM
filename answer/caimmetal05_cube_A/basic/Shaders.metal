//
// Shaders.metal
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

#include <metal_stdlib>

using namespace metal;

// バッファID番号
constant int ID_VERTEX = 0;
constant int ID_UNIFORMS = 1;

// 入力頂点情報
struct VertexIn {
    float4 pos;
    float4 rgba;
    float2 tex_coord;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[position]];
    float4 rgba;
    float2 tex_coord;
};

struct Uniforms {
    float4x4 view_matrix;
    float4x4 model_matrix;
    float4x4 projection_matrix;
};

// 頂点シェーダー(透視投影変換)
vertex VertexOut vertPers(device VertexIn *vin [[ buffer(ID_VERTEX) ]],
                        constant Uniforms &uniforms [[ buffer(ID_UNIFORMS) ]],
                        uint vid [[vertex_id]])
{
    VertexOut vout;
    float4x4 matrix = uniforms.projection_matrix * uniforms.view_matrix * uniforms.model_matrix;
    vout.pos = matrix * float4(vin[vid].pos);
    vout.rgba = vin[vid].rgba;
    vout.tex_coord = vin[vid].tex_coord;
    
    return vout;
}

// フラグメントシェーダー(テクスチャ)
fragment float4 fragStandard(VertexOut vout [[ stage_in ]],
                             texture2d<float>  tex2D [[ texture(0) ]],
                             sampler           sampler2D [[ sampler(0) ]]) {
    float4 color = tex2D.sample(sampler2D, vout.tex_coord);
    return color;
}
