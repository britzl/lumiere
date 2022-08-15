varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D input_tex;
uniform lowp sampler2D lights_tex;
uniform lowp vec4 tint0;
uniform lowp vec4 tint1;
uniform lowp vec4 ambient_light;

void main()
{
	// Pre-multiply alpha since all runtime textures already are
	lowp vec4 tint0_pm = vec4(tint0.xyz * tint0.w, tint0.w);
	lowp vec4 tint1_pm = vec4(tint1.xyz * tint1.w, tint1.w);
	
	lowp vec4 input_col = texture2D(input_tex, var_texcoord0.xy) * tint0_pm;
	lowp vec4 lights_col = texture2D(lights_tex, var_texcoord0.xy) * tint1_pm;

	gl_FragColor = input_col*(ambient_light+lights_col);
}
