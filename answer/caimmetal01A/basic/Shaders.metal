// Shaders.metal
#include <metal_stdlib>

using namespace metal;

// バッファID番号
constant int ID_VERTEX = 0;
constant int ID_PROJECTION = 1;

// 入力頂点情報
struct VertexIn {
    packed_float4 pos;
    packed_float4 rgba;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[position]];
    float4 rgba;
};

// 頂点シェーダー(2Dピクセル座標系へ変換)
vertex VertexOut vert2d(device VertexIn *vin [[ buffer(ID_VERTEX) ]],
                        constant float4x4 &proj_matrix [[ buffer(ID_PROJECTION) ]],
                        uint vid [[vertex_id]])
{
    VertexOut vout;
    vout.pos = proj_matrix * float4(vin[vid].pos);
    vout.rgba = vin[vid].rgba;
    return vout;
}

// フラグメントシェーダー(素通り)
fragment float4 fragStandard(VertexOut vout [[ stage_in ]]) {
    return vout.rgba;
}
