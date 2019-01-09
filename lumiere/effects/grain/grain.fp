varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 tint;
uniform lowp vec4 time;
uniform lowp vec4 strength;

// https://www.shadertoy.com/view/4sXSWs
void main()
{

	vec2 uv = var_texcoord0.xy;

	lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
	vec4 color = texture2D(DIFFUSE_TEXTURE, uv);
	
	float x = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (time.x * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01) - 0.005) * strength.x;

	gl_FragColor = vec4(color + grain * tint_pm);
}
