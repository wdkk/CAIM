//
// ShaderARPlane.metal
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

struct SharedUniforms {
    // Camera Uniforms
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
    // Lighting Properties
    float3 ambientLightColor;
    float3 directionalLightDirection;
    float3 directionalLightColor;
    float  materialShininess;
};

struct PlaneUniforms {
    float4x4 modelMatrix;
};

// 入力頂点情報
struct VertexIn {
    float3 pos  [[ attribute(0) ]];
    float2 uv   [[ attribute(1) ]];
    float4 rgba [[ attribute(2) ]];
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[ position ]];
    float2 uv;
    float4 rgba;
};

vertex VertexOut vertPlane(VertexIn in [[ stage_in ]],
                        constant SharedUniforms &shared_uniforms [[ buffer(1) ]],
                        constant PlaneUniforms &plane_uniforms [[ buffer(2) ]]) {
    // モデル行列
    float4x4 model_matrix = plane_uniforms.modelMatrix;
    // モデルビュー行列
    float4x4 model_view_matrix = shared_uniforms.viewMatrix * model_matrix;
    float4 position = float4(in.pos, 1.0);
    
    VertexOut out;
    out.pos = shared_uniforms.projectionMatrix * model_view_matrix * position;
    out.uv = in.uv;
    out.rgba = in.rgba;
    
    return out;
}

// フラグメントシェーダー
fragment float4 fragPlane(VertexOut vout [[ stage_in ]]) {
    return vout.rgba;
}
