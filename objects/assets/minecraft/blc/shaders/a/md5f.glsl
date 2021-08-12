#version 150

#define MINECRAFT_LIGHT_POWER   (0.2)
#define MINECRAFT_AMBIENT_LIGHT (0.8)

in vec3 outNormal;
in vec2 outTexCoord;
in float vertexDistance;

out vec4 fragColor;

uniform sampler2D textureSampler;
uniform sampler2D lightSampler;
uniform vec3 lightDirection0;
uniform vec3 lightDirection1;
uniform ivec2 lightMapCoords;
uniform bool enchantOverlay;
uniform vec2 enchantOffsets;
uniform vec4 enchantColor;
uniform bool previewMode;
uniform bool colorize;
uniform vec4 color;
uniform bool FogEnabled;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    if (vertexDistance <= fogStart || !FogEnabled) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, clamp(uv / 256.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0)));
}

vec4 minecraft_mix_light(vec3 lightDir0, vec3 lightDir1, vec3 normal, vec4 color) {
    lightDir0 = normalize(lightDir0);
    lightDir1 = normalize(lightDir1);
    float light0 = max(0.0, dot(lightDir0, normal));
    float light1 = max(0.0, dot(lightDir1, normal));
    float lightAccum = min(1.0, (light0 + light1) * MINECRAFT_LIGHT_POWER + MINECRAFT_AMBIENT_LIGHT);
    return vec4(color.rgb * lightAccum, color.a);
}

void main()
{
    vec4 c = enchantOverlay ? texture(textureSampler, (outTexCoord + enchantOffsets)) : texture(textureSampler, outTexCoord);

    if (c.a < 0.1) {
        discard;
    }

    if (enchantOverlay) {
        vec4 color = c * enchantColor;
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    } else {
        if (colorize) {
            c *= color;
        }

        if (!previewMode) {
            vec4 lightMapColor = minecraft_sample_lightmap(lightSampler, lightMapCoords);
            vec4 color = lightMapColor * minecraft_mix_light(lightDirection0, lightDirection1, outNormal, c);
            fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
        } else {
            fragColor = minecraft_mix_light(vec3(-1, -1, -1), vec3(1, -1, 1), outNormal, c);
        }
    }
}