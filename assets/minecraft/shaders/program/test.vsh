#version 150

in vec4 Position;

uniform sampler2D DataSampler;

uniform mat4 ProjMat;
uniform vec2 InSize;

out vec2 texCoord;
flat out mat4 mvpInverse;
flat out mat4 viewProjMat;
flat out mat4 projection;

int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int s = ivec.b >= 128.0 ? -1 : 1;
    return s * (int(ivec.r) + int(ivec.g) * 256 + (int(ivec.b) - 64 + s * 64) * 256 * 256);
}

float decodeFloat(vec3 ivec) {
    int v = decodeInt(ivec);
    return float(v) / 40000.0;
}

void main() {
    mat4 mvp;
    for (int i = 0; i < 16; i++) {
        vec4 color = texelFetch(DataSampler, ivec2(i, 0), 0);
        mvp[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    viewProjMat = mvp;
    mvpInverse = inverse(mvp);

    for (int i = 0; i < 16; i++) {
        vec4 color = texelFetch(DataSampler, ivec2(i + 16, 0), 0);
        projection[i / 4][i % 4] = decodeFloat(color.rgb);
    }

    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    texCoord = outPos.xy * 0.5 + 0.5;
}