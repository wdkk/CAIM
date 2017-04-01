// Shaders.metal
#include <metal_stdlib>

using namespace metal;

// バッファID番号
constant int ID_VERTEX = 0;
constant int ID_PROJECTION = 1;

// 入力頂点情報
struct VertexIn {
    packed_float4 pos;
    packed_float2 uv;
    packed_float4 rgba;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[position]];
    float2 uv;
    float4 rgba;
};

// 頂点シェーダー(2Dピクセル座標系へ変換)
// vertex VertexOut vert2d ...



// フラグメントシェーダー(Cosカーブを使って滑らかな変化の円を描く)
// fragment float4 fragCircleCosCurve ...

