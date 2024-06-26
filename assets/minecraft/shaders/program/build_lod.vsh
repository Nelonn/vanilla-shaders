#version 150

in vec4 Position;

uniform sampler2D DiffuseSampler;
uniform sampler2D VoxelCacheSampler;

uniform mat4 ProjMat;
uniform vec2 InSize;

const vec4[] corners = vec4[](
    vec4(-1, -1, 0, 1),
    vec4(1, -1, 0, 1),
    vec4(1, 1, 0, 1),
    vec4(-1, 1, 0, 1)
);

void main() {
    vec4 outPos = corners[gl_VertexID];
    gl_Position = outPos;
}