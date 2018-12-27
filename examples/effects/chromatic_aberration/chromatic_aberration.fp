varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 tint;
uniform lowp vec4 time;

// https://www.shadertoy.com/view/Mds3zn
void main()
{
	vec2 uv = var_texcoord0.xy;

	float amount = 0.0;

	amount = (1.0 + sin(time.x*6.0)) * 0.5;
	amount *= 1.0 + sin(time.x*16.0) * 0.5;
	amount *= 1.0 + sin(time.x*19.0) * 0.5;
	amount *= 1.0 + sin(time.x*27.0) * 0.5;
	amount = pow(amount, 3.0);

	amount *= 0.05;

	vec3 col;
	col.r = texture2D(DIFFUSE_TEXTURE, vec2(uv.x+amount,uv.y) ).r;
	col.g = texture2D(DIFFUSE_TEXTURE, uv ).g;
	col.b = texture2D(DIFFUSE_TEXTURE, vec2(uv.x-amount,uv.y) ).b;

	col *= (1.0 - amount * 0.5);

	gl_FragColor = vec4(col,1.0);
}
