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

#include <metal_stdlib>

using namespace metal;

// 入力頂点情報
struct VertexIn {
    float2 pos;
    float2 uv;
    float4 rgba;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[position]];
    float2 uv;
    float4 rgba;
};

// 必要なシェーダを作成する...
