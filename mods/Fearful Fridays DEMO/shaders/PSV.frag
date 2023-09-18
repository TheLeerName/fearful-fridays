// its like PincushionStaticVignette :)
// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define texture flixel_texture2D
#define iResolution openfl_TextureSize
uniform float iTime;
#define iChannel0 bitmap

#define PINCUSHION_STRENGTH 0.34

#define STATIC_ALPHA 0.15
#define STATIC_STRENGTH 1.5

#define VIGNETTE_OUTER 1.0
#define VIGNETTE_INNER 0.01
#define VIGNETTE_BREATH_SPEED 5.
#define VIGNETTE_BREATH_STRENGTH 0.06

float rand(vec2 co){
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 vignette(vec4 fragColor, vec2 uv, float outer, float inner) {
	float dist  = distance(vec2(.5), uv) * 1.414213;
	float vig = clamp((outer - dist) / (outer - inner), 0.0, 1.0);
	fragColor.rgb *= vig;
	return fragColor;
}

// https://www.shadertoy.com/view/lttXD4
vec2 pincushionDistortion(vec2 uv, float strength) {
	uv = uv - vec2(0.5);
	float uva = atan(uv.x, uv.y);
	float uvd = sqrt(dot(uv, uv));
	//strength = negative for pincushion, positive for barrel
	uvd = uvd*(1.0 + strength*uvd*uvd);
	return vec2(0.5) + vec2(sin(uva), cos(uva))*uvd;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy;
	uv = pincushionDistortion(uv, PINCUSHION_STRENGTH);
	if (uv.x < 0. || uv.y < 0.)
		discard;

	fragColor = texture(iChannel0, uv);

	// static code by me <3
	vec2 staticCoord = floor(fragCoord / STATIC_STRENGTH);
	vec3 staticColor = vec3(rand(vec2(staticCoord.x * staticCoord.y, iTime)));
	fragColor.rgb = mix(fragColor.rgb, staticColor, STATIC_ALPHA) * fragColor.a;

	// vignette code from https://www.shadertoy.com/view/4sB3Rc
	float outer = VIGNETTE_OUTER;
	outer *= abs(sin(iTime * VIGNETTE_BREATH_SPEED)) * VIGNETTE_BREATH_STRENGTH + 1.;
	fragColor = vignette(fragColor, uv, outer, VIGNETTE_INNER);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}