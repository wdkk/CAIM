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
    float4 color;
};

vertex ColorInOut vert3DObject(VertexInput in [[ stage_in ]],
                           constant SharedUniforms &shared_uniforms [[ buffer(1) ]],
                           constant InstanceUniforms &instance_uniforms [[ buffer(2) ]]) {
    
    float4x4 model_matrix = instance_uniforms.modelMatrix;
    float4x4 model_view_matrix = shared_uniforms.viewMatrix * model_matrix;
    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(in.position, 1.0);
    
    ColorInOut out;
    out.position = shared_uniforms.projectionMatrix * model_view_matrix * position;
    out.texcoord = float2(in.texcoord.x, in.texcoord.y);
    out.eyePosition = (model_view_matrix * position).xyz;
    out.color = float4(0.75, 0.75, 0.75, 1.0);
    // Rotate our normals to world coordinates
    float4 normal = model_matrix * float4(in.normal.x, in.normal.y, in.normal.z, 0.0f);
    out.normal = normalize(normal.xyz);
    
    return out;
}

fragment float4 frag3DObject(ColorInOut in [[ stage_in ]],
                         constant SharedUniforms &shared_uniforms [[ buffer(1) ]]) {
    
    float3 normal = float3(in.normal);
    
    // Calculate the contribution of the directional light as a sum of diffuse and specular terms
    float3 directional_contribution = float3(0);
    {
        // Light falls off based on how closely aligned the surface normal is to the light direction
        float nDotL = saturate(dot(normal, -shared_uniforms.directionalLightDirection));
        
        // The diffuse term is then the product of the light color, the surface material
        // reflectance, and the falloff
        float3 diffuse_term = shared_uniforms.directionalLightColor * nDotL;
        
        // Apply specular lighting...
        
        // 1) Calculate the halfway vector between the light direction and the direction they eye is looking
        float3 halfway_vector = normalize(-shared_uniforms.directionalLightDirection - float3(in.eyePosition));
        
        // 2) Calculate the reflection angle between our reflection vector and the eye's direction
        float reflection_angle = saturate(dot(normal, halfway_vector));
        
        // 3) Calculate the specular intensity by multiplying our reflection angle with our object's shininess
        float specular_intensity = saturate(powr(reflection_angle, shared_uniforms.materialShininess));
        
        // 4) Obtain the specular term by multiplying the intensity by our light's color
        float3 specular_term = shared_uniforms.directionalLightColor * specular_intensity;
        
        // Calculate total contribution from this light is the sum of the diffuse and specular values
        directional_contribution = diffuse_term + specular_term;
    }
    
    // The ambient contribution, which is an approximation for global, indirect lighting, is
    // the product of the ambient light intensity multiplied by the material's reflectance
    float3 ambient_contribution = shared_uniforms.ambientLightColor;
    
    // Now that we have the contributions our light sources in the scene, we sum them together
    // to get the fragment's lighting value
    float3 light_contributions = ambient_contribution + directional_contribution;
    
    //constexpr sampler defaultSampler;
    //half4 color = diffuseTexture.sample(defaultSampler, float2(in.texcoord));
    
    // We compute the final color by multiplying the sample from our color maps by the fragment's lighting value
    //float4 rgba = float4(float3(color.xyz) * light_contributions, 1.0);
    float4 rgba = float4(in.color.xyz * light_contributions, in.color[3]);
    
    // We use the color we just computed and the alpha channel of our colorMap for this fragment's alpha value
    return rgba;
}
