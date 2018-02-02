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

#include <metal_stdlib>    // Metalの標準ライブラリ

using namespace metal;

constant int ID_UNIFORM = 1;
constant int ID_SHARED_UNIFORM = 2;

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
                        constant Uniform& uniform [[ buffer(ID_UNIFORM) ]],
                        constant SharedUniform& shared_uniform [[ buffer(ID_SHARED_UNIFORM) ]]) {
    VertexOut out;
    float4x4 model_view_matrix = shared_uniform.viewMatrix * uniform.modelMatrix;
    out.position = shared_uniform.projectionMatrix * model_view_matrix * float4(in.position, 1);
    out.point = (shared_uniform.projectionMatrix * model_view_matrix * float4(in.position, 1)).xyz;
    out.normal = (uniform.modelMatrix * float4(in.normal, 1.0)).xyz;
    out.texcoord = in.texcoord;
    return out;
}

fragment float4 frag3d(VertexOut in [[ stage_in ]],
                      constant SharedUniform& shared_uniform [[ buffer(ID_SHARED_UNIFORM) ]],
                      sampler tex_sampler [[ sampler(0) ]],
                      texture2d<half> diffuseTexture [[ texture(0) ]]) {
    float lt = saturate(dot(in.normal, lightDirection));
    if (lt < 0.1) lt = 0.1;
    half4 color = diffuseTexture.sample(tex_sampler, float2(in.texcoord)) * lt;
    return float4(float4(color).xyz, 1.0);
    
    /*
    // 視点座標
    float3 eye_position = (shared_uniform.viewMatrix * float4(0, 0, 0, 1)).xyz;
    // 視線ベクトル
    float3 eye_vector = normalize(in.point - eye_position);
    // 視線ベクトルと法線ベクトルの内積
    float va = dot(in.normal, eye_vector);
    */
    
    /*
    // 光線ベクトルと法線ベクトルの内積
    float vlt = dot(in.normal, lightDirection);
    float sat_vlt = saturate(vlt);

    float alpha = cos(va * M_PI_2_F);
    
    float hue = sat_vlt * 360.0;
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;
    float a = 0.0;

    if(0 <= hue && hue <= 60) {
        r = 1.0;
        g = hue / 60.0;
        b = 0.0;
        a = (hue - 30.0) / 30.0;
    }
    else if(hue <= 120.0) {
        r = (120.0 - hue) / 60.0;
        g = 1.0;
        b = 0.0;
        a = (hue - 90.0) / 30.0;
    }
    else if(hue <= 180.0) {
        r = 0.0;
        g = 1.0;
        b = (hue - 120.0) / 60.0;
        a = (hue - 150.0) / 30.0;
    }
    else if(hue <= 240.0) {
        r = 0.0;
        g = (240.0 - hue) / 60.0;
        b = 1.0;
        a = (hue - 210.0) / 30.0;
    }
    else if(hue <= 300.0) {
        r = (hue - 240.0) / 60.0;
        g = 0.0;
        b = 1.0;
        a = (hue - 270.0) / 30.0;
    }
    else {
        r = 1.0;
        g = 0.0;
        b = (360.0 - hue) / 60.0;
        a = (hue - 330.0) / 30.0;
    }

    return float4(r, g, b, a);
    */
}


