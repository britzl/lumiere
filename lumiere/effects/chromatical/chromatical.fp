varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 tint;
uniform lowp vec4 time;
uniform lowp vec4 resolution;

// https://www.shadertoy.com/view/XdXXD4
void main()
{
	// distance from center of image, used to adjust blur
	vec2 uv = var_texcoord0.xy;
	float d = length(uv - vec2(0.5,0.5));

	// blur amount
	float blur = 0.0;	
	blur = (1.0 + sin(time.x*6.0)) * 0.5;
	blur *= 1.0 + sin(time.x*16.0) * 0.5;
	blur = pow(blur, 3.0);
	blur *= 0.05;
	// reduce blur towards center
	blur *= d;

	// final color
	vec3 col;
	col.r = texture2D(DIFFUSE_TEXTURE, vec2(uv.x+blur,uv.y) ).r;
	col.g = texture2D(DIFFUSE_TEXTURE, uv ).g;
	col.b = texture2D(DIFFUSE_TEXTURE, vec2(uv.x-blur,uv.y) ).b;

	// scanline
	float scanline = sin(uv.y*resolution.y)*0.04;
	col -= scanline;

	// vignette
	col *= 1.0 - d * 0.5;

	gl_FragColor = vec4(col,1.0);
}
