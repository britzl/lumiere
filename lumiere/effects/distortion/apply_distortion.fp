varying mediump vec2 var_texcoord0;

uniform lowp sampler2D input_tex;
uniform lowp sampler2D distort_tex;
uniform lowp vec4 input_tint;
uniform lowp vec4 distort_tint;
uniform lowp vec4 time;

void main()
{
	// Pre-multiply alpha since all runtime textures already are
	vec4 input_tint_pm = vec4(input_tint.xyz * input_tint.w, input_tint.w);
	vec4 distort_tint_pm = vec4(distort_tint.xyz * distort_tint.w, distort_tint.w);

	float frequency=100.0;
	float amplitude=0.002;
	float speed=10.0;
	float distortion=sin((var_texcoord0.y * frequency) + (time.x * speed)) * amplitude;

	vec2 distortion_offset = vec2(distortion, 0.0);
	vec4 distort_color = texture2D(distort_tex, var_texcoord0) * distort_tint_pm;

	vec2 input_pos = var_texcoord0 + distortion_offset * distort_color.a;
	vec4 input_color = texture2D(input_tex, input_pos) * input_tint_pm;
	gl_FragColor = distort_color + input_color;
}

