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

#include <metal_stdlib>                        // Metalの標準ライブラリ

using namespace metal;

// 入力頂点情報
struct VertexIn {
    float2 pos;
    float4 rgba;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[ position ]];
    float4 rgba;
};

// 頂点シェーダー(2Dピクセル座標系)
vertex VertexOut vert2d(device VertexIn *vin [[ buffer(0) ]],
                        constant float4x4 &proj_matrix [[ buffer(1) ]],
                        uint idx [[ vertex_id ]]) {
    VertexOut vout;
    // float2に、z=0,w=1を追加 → float4を作成し、行列を使って座標変換
    vout.pos = proj_matrix * float4(vin[idx].pos, 0, 1);
    vout.rgba = vin[idx].rgba;
    return vout;
}

// フラグメントシェーダー(無加工)
fragment float4 fragStandard(VertexOut vout [[ stage_in ]]) {
    // voutで受け取った色をそのまま結果とする(returnで返した色が画面に反映される)
    return vout.rgba;
}

kernel void kernelTest( const device VertexIn *in [[ buffer(0) ]],
                        device VertexIn *out [[ buffer(1) ]],
                        uint group_pos [[ threadgroup_position_in_grid ]],
                        uint thread_pos [[ thread_position_in_threadgroup ]],
                        uint threads_per_threadgroup [[ threads_per_threadgroup ]]
                       )
{
    uint idx = (group_pos * threads_per_threadgroup + thread_pos);
    out[idx].pos = in[idx].pos * 2.0;
    out[idx].rgba = in[idx].rgba;
}
