varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 resolution;

// https://www.shadertoy.com/view/XdXXD4
void main()
{
	vec2 uv = var_texcoord0.xy;
	vec4 col = texture2D(DIFFUSE_TEXTURE, uv );

	// scanline
	float scanline = sin(uv.y*resolution.y)*0.04;
	col -= scanline;

	gl_FragColor = col;
}
