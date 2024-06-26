#version 150

in vec4 Position;

uniform sampler2D DiffuseSampler;
uniform sampler2D VoxelCacheSampler;

uniform mat4 ProjMat;
uniform vec2 InSize;

out vec2 texCoord;
flat out mat4 viewProjMat;
flat out mat4 mvpInverse;
flat out vec3 offset;
flat out vec3 position;
flat out vec3 prevPosition;

int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int s = ivec.b >= 128.0 ? -1 : 1;
    return s * (int(ivec.r) + int(ivec.g) * 256 + (int(ivec.b) - 64 + s * 64) * 256 * 256);
}

float decodeFloat(vec3 ivec) {
    int v = decodeInt(ivec);
    return float(v) / 40000.0;
}

float decodeFloat1024(vec3 ivec) {
    int v = decodeInt(ivec);
    return float(v) / 1024.0;
}

const vec4[] corners = vec4[](
    vec4(-1, -1, 0, 1),
    vec4(1, -1, 0, 1),
    vec4(1, 1, 0, 1),
    vec4(-1, 1, 0, 1)
);

void main() {
    mat4 mvp;

    for (int i = 0; i < 16; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(i, 0), 0);
        mvp[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    viewProjMat = mvp;
    mvpInverse = inverse(mvp);

    for (int i = 0; i < 3; i++) {
        vec4 color = texelFetch(DiffuseSampler, ivec2(32 + i, 0), 0);
        position[i] = decodeFloat1024(color.rgb);
    }

    for (int i = 0; i < 3; i++) {
        vec4 color = texelFetch(VoxelCacheSampler, ivec2(i, 0), 0);
        prevPosition[i] = decodeFloat1024(color.rgb);
    }

    offset = fract(position);

    vec4 outPos = corners[gl_VertexID];
    gl_Position = outPos;

    texCoord = outPos.xy * 0.5 + 0.5;
}