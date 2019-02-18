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

#include <metal_stdlib>                         // Metalの標準ライブラリ

using namespace metal;

#define lightDirection float3(1/1.73, 1/1.73, 1/1.73)

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
    float3      normal;
    float2      texcoord;
};

vertex VertexOut vert3d(VertexIn in [[ stage_in ]],
                        constant Uniform& uniform [[ buffer(1) ]],
                        constant SharedUniform& shared_uniform [[ buffer(2) ]],
                        uint idx [[ vertex_id ]] ) {
    VertexOut out;
    float4x4 model_view_matrix = shared_uniform.viewMatrix * uniform.modelMatrix;
    out.position = shared_uniform.projectionMatrix * model_view_matrix * float4(in.position, 1);
    out.texcoord = float2(in.texcoord.x, in.texcoord.y);
    out.normal = ( uniform.modelMatrix * float4(in.normal, 1.0) ).xyz;
    return out;
}

fragment half4 frag3d(VertexOut in [[ stage_in ]],
                      constant SharedUniform& shared_uniform [[ buffer(2) ]],
                      texture2d<half> diffuseTexture [[ texture(0) ]]) {
    constexpr sampler defaultSampler;
    float lt = saturate(dot(in.normal, lightDirection));
    if (lt < 0.1) lt = 0.1;
    half4 color =  diffuseTexture.sample(defaultSampler, float2(in.texcoord)) * lt;
    return color;
}

// 入力頂点情報
struct VertexIn2 {
    float2 pos  [[ attribute(0) ]];
    float2 uv   [[ attribute(1) ]];
    float4 rgba [[ attribute(2) ]];
};

// 出力頂点情報
struct VertexOut2 {
    float4 pos [[ position ]];
    float2 uv;
    float4 rgba;
};

// 頂点シェーダー(2Dピクセル座標系へ変換)
vertex VertexOut2 vert2d(device VertexIn2 *vin [[ buffer(0) ]],
                         constant float4x4 &proj_matrix [[ buffer(1) ]],
                         uint idx [[ vertex_id ]]) {
    VertexOut2 vout;
    vout.pos   = proj_matrix * float4(vin[idx].pos, 0, 1);
    vout.rgba  = vin[idx].rgba;
    vout.uv    = vin[idx].uv;
    return vout;
}

// フラグメントシェーダー(Cosカーブを使って滑らかな変化の円を描く)
fragment float4 fragCircleCosCurve(VertexOut2 vout [[ stage_in ]]) {
    // 中心からのuv距離の二乗
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離
    float dist = sqrt(dist2);
    // uv距離が1.0以上 = 円の外 (discard_fragment()を呼ぶとピクセルが破棄される)
    if(dist >= 1.0) { discard_fragment(); }
    // cosを用いて新しいアルファをもつ色情報をつくる(rgba[3]=アルファ)
    float4 rgba = vout.rgba;
    rgba[3] = vout.rgba[3] * (1.0 + cos(M_PI_F * dist)) / 2.0;
    return rgba;
}

// フラグメントシェーダー(リングを描く)
fragment float4 fragRing(VertexOut2 vout [[ stage_in ]]) {
    // 中心からのuv距離の二乗
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離
    float dist = sqrt(dist2);
    // uv距離が0.8以下か1.0以上ならピクセル破棄(リングの外)
    if(dist <= 0.8 || 1.0 <= dist) { discard_fragment(); }
    
    // リングの中心骨はdist=0.9とする。kは中心骨との距離。これを10倍するとk=0.0~1.0になる。
    // このkをcosに用いてリングを柔らかくする
    float k = fabs(0.9 - dist) * 10.0;
    // cosを用いて新しいアルファをもつ色情報をつくる(rgba[3]=アルファ)
    float4 rgba = vout.rgba;
    rgba[3] = vout.rgba[3] * (1.0 + cos(M_PI_F * k)) / 2.0;
    return rgba;
}
