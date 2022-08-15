varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D original;
uniform lowp sampler2D lut;

#define MAXCOLOR 15.0
#define COLORS 16.0
#define WIDTH 256.0
#define HEIGHT 16.0

void main()
{
	vec4 px = texture2D(original, var_texcoord0.xy);

	float cell = px.b * MAXCOLOR;

	float cell_l = floor(cell); 
	float cell_h = ceil(cell);

	float half_px_x = 0.5 / WIDTH;
	float half_px_y = 0.5 / HEIGHT;
	float r_offset = half_px_x + px.r / COLORS * (MAXCOLOR / COLORS);
	float g_offset = half_px_y + px.g * (MAXCOLOR / COLORS);

	vec2 lut_pos_l = vec2(cell_l / COLORS + r_offset, g_offset); 
	vec2 lut_pos_h = vec2(cell_h / COLORS + r_offset, g_offset);

	vec4 graded_color_l = texture2D(lut, lut_pos_l); 
	vec4 graded_color_h = texture2D(lut, lut_pos_h);

	vec4 graded_color = mix(graded_color_l, graded_color_h, fract(cell));

	gl_FragColor = graded_color;
}