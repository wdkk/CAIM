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
#include "../CAIMMetal/CAIMShaderUtil.h"       // CAIMの補助機能

using namespace metal;

// バッファID番号
constant int ID_VERTEX = 0;
constant int ID_PROJECTION = 1;

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
vertex VertexOut vert2d(device VertexIn *vin [[ buffer(ID_VERTEX) ]],
                        constant float4x4 &proj_matrix [[ buffer(ID_PROJECTION) ]],
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
