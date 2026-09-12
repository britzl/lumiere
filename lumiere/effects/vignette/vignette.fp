varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;

// https://www.shadertoy.com/view/XdXXD4
void main()
{
	vec2 uv = var_texcoord0.xy;
	vec4 col = texture2D(DIFFUSE_TEXTURE, uv );
	
	uv *=  1.0 - uv.yx;
	float vig = uv.x*uv.y * 15.0;
	vig = pow(vig, 0.25);
	col.rgb *= vig;

	gl_FragColor = vec4(col);
}
