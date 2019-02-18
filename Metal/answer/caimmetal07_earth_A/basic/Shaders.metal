//
// Shaders.metal
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

#include <metal_stdlib>    // Metalの標準ライブラリ

using namespace metal;

#define lightDirection float3(1/1.73, -1/1.73, 1/1.73)

struct Uniform {
    float4x4    modelMatrix;
};

struct SharedUniform {
    float4x4    viewMatrix;
    float4x4    projectionMatrix;
};

struct VertexIn {
    float3      position    [[ attribute(0) ]];
    float3      normal      [[ attribute(1) ]];
    float2      texcoord    [[ attribute(2) ]];
};

struct VertexOut {
    float4      position    [[ position ]];
    float3      point;
    float3      normal;
    float2      texcoord;
};

vertex VertexOut vert3d(VertexIn in [[ stage_in ]],
                        constant Uniform& uniform [[ buffer(1) ]],
                        constant SharedUniform& shared_uniform [[ buffer(2) ]]) {
    VertexOut out;
    float4x4 model_view_matrix = shared_uniform.viewMatrix * uniform.modelMatrix;
    out.position = shared_uniform.projectionMatrix * model_view_matrix * float4(in.position, 1);
    out.point = (shared_uniform.projectionMatrix * model_view_matrix * float4(in.position, 1)).xyz;
    out.normal = (uniform.modelMatrix * float4(in.normal, 1.0)).xyz;
    out.texcoord = in.texcoord;
    return out;
}

fragment float4 frag3d(VertexOut in [[ stage_in ]],
                      constant SharedUniform& shared_uniform [[ buffer(2) ]],
                      sampler tex_sampler [[ sampler(0) ]],
                      texture2d<half> diffuseTexture [[ texture(0) ]]) {
    
    float lt = saturate(dot(in.normal, lightDirection));
    if (lt < 0.1) lt = 0.1;
    half4 color = diffuseTexture.sample(tex_sampler, float2(in.texcoord)) * lt;
    return float4(float4(color).xyz, 1.0);
}


