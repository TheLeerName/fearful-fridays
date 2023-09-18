#pragma header

//thank you random shadertoy plugin, i love you so much
uniform float strength; // 0.999

void main() {
    vec2 uv = openfl_TextureCoordv;

    vec2 c = mix(openfl_TextureSize, vec2(4), strength);
    uv = floor(uv * c) / c;

    gl_FragColor = flixel_texture2D(bitmap, uv);
}