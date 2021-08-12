#version 150

in vec2 outTexCoord;
in float vertexDistance;

out vec4 fragColor;

uniform sampler2D textureSampler;
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


void main()
{
    vec4 c = texture(textureSampler, outTexCoord).rgba;
    if (c.a == 0.0) {
        discard;
    }

    fragColor = linear_fog(c * color, vertexDistance, FogStart, FogEnd, FogColor);
}