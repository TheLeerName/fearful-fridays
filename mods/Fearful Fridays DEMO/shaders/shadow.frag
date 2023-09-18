#pragma header

uniform vec3 bgColor; // vec3 of colors from 0.0 to 1.0
uniform vec3 shadowColor; // vec3 of colors from 0.0 to 1.0
uniform float offsetY; // from 0.0 to 1.0
uniform float sizeY;

void main() {
	vec2 uv = openfl_TextureCoordv;
	gl_FragColor = flixel_texture2D(bitmap, uv);

	uv.y *= sizeY;
	uv.y = 1.0 - uv.y; // flipY
	uv.y += offsetY;
	vec4 shadow = flixel_texture2D(bitmap, uv);
	if (shadow.a >= 0.5)
		shadow.rgb = shadowColor;
	else
		shadow = vec4(bgColor, 1.0);

	gl_FragColor = mix(shadow, gl_FragColor, gl_FragColor.a);
}