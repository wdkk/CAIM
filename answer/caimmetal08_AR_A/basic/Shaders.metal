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

struct InstanceUniforms {
    float4x4 modelMatrix;
};

struct VertexInput {
    float3   position    [[ attribute(0) ]];
    float3   normal      [[ attribute(1) ]];
    float2   texcoord    [[ attribute(2) ]];
};

struct ColorInOut {
    float4 position [[ position ]];
    float2 texcoord;
    float3 eyePosition;
    float3 normal;
};

vertex ColorInOut vert3dAR(VertexInput in [[ stage_in ]],
                           constant SharedUniforms &sharedUniforms [[ buffer(1) ]],
                           constant InstanceUniforms &instanceUniforms [[ buffer(2) ]]) {
    
    float4x4 modelMatrix = instanceUniforms.modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix * modelMatrix;
    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(in.position, 1.0);
    
    ColorInOut out;
    out.position = sharedUniforms.projectionMatrix * modelViewMatrix * position;
    out.texcoord = float2(in.texcoord.x, in.texcoord.y);
    out.eyePosition = (modelViewMatrix * position).xyz;
    // Rotate our normals to world coordinates
    float4 normal = modelMatrix * float4(in.normal.x, in.normal.y, in.normal.z, 0.0f);
    out.normal = normalize(normal.xyz);

    return out;
}

fragment float4 frag3dAR(ColorInOut in [[ stage_in ]],
                         constant SharedUniforms &sharedUniforms [[ buffer(1) ]]) {
    
    float3 normal = float3(in.normal);
    
    // Calculate the contribution of the directional light as a sum of diffuse and specular terms
    float3 directionalContribution = float3(0);
    {
        // Light falls off based on how closely aligned the surface normal is to the light direction
        float nDotL = saturate(dot(normal, -sharedUniforms.directionalLightDirection));
        
        // The diffuse term is then the product of the light color, the surface material
        // reflectance, and the falloff
        float3 diffuseTerm = sharedUniforms.directionalLightColor * nDotL;
        
        // Apply specular lighting...
        
        // 1) Calculate the halfway vector between the light direction and the direction they eye is looking
        float3 halfwayVector = normalize(-sharedUniforms.directionalLightDirection - float3(in.eyePosition));
        
        // 2) Calculate the reflection angle between our reflection vector and the eye's direction
        float reflectionAngle = saturate(dot(normal, halfwayVector));
        
        // 3) Calculate the specular intensity by multiplying our reflection angle with our object's shininess
        float specularIntensity = saturate(powr(reflectionAngle, sharedUniforms.materialShininess));
        
        // 4) Obtain the specular term by multiplying the intensity by our light's color
        float3 specularTerm = sharedUniforms.directionalLightColor * specularIntensity;
        
        // Calculate total contribution from this light is the sum of the diffuse and specular values
        directionalContribution = diffuseTerm + specularTerm;
    }
    
    // The ambient contribution, which is an approximation for global, indirect lighting, is
    // the product of the ambient light intensity multiplied by the material's reflectance
    float3 ambientContribution = sharedUniforms.ambientLightColor;
    
    // Now that we have the contributions our light sources in the scene, we sum them together
    // to get the fragment's lighting value
    float3 lightContributions = ambientContribution + directionalContribution;
    
    //constexpr sampler defaultSampler;
    //half4 color1 = diffuseTexture.sample(defaultSampler, float2(in.texcoord));
    half4 color1 = half4(1.0, 0.5, 0.5, 1.0);
    
    // We compute the final color by multiplying the sample from our color maps by the fragment's lighting value
    float3 rgb = float3(color1.xyz) * lightContributions;
    // We use the color we just computed and the alpha channel of our colorMap for this fragment's alpha value
    return float4(rgb, 1.0);
}

// 入力頂点情報
struct VertexIn2 {
    float3 pos  [[ attribute(0) ]];
    float2 uv   [[ attribute(1) ]];
    float4 rgba [[ attribute(2) ]];
};

// 出力頂点情報
struct VertexOut2 {
    float4 pos [[ position ]];
    float2 uv;
    float4 rgba;
};

struct PlaneUniforms {
    float4x4 modelMatrix;
};

vertex VertexOut2 vert3d(VertexIn2 in [[ stage_in ]],
                         constant SharedUniforms &sharedUniforms [[ buffer(1) ]],
                         constant PlaneUniforms &instanceUniforms [[ buffer(2) ]]) {
    
    float4x4 modelMatrix = instanceUniforms.modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix * modelMatrix;
    float4 position = float4(in.pos, 1.0);
    
    VertexOut2 out;
    out.pos = sharedUniforms.projectionMatrix * modelViewMatrix * position;
    out.uv = in.uv;
    out.rgba = in.rgba;
    
    return out;
}

// フラグメントシェーダー(Cosカーブを使って滑らかな変化の円を描く)
fragment float4 fragStandard(VertexOut2 vout [[ stage_in ]]) {
    return vout.rgba;
}
