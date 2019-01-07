varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 resolution;

// https://www.shadertoy.com/view/ltscDB
void main()
{
	vec2 fragCoord = vec2(var_texcoord0.x * resolution.x, var_texcoord0.y * resolution.y);
	vec2 uv = var_texcoord0.xy;

	// Map texture to 0-1 space
	vec4 texColor = texture2D(DIFFUSE_TEXTURE, uv);

	// Default lcd colour (affects brightness)
	float pb = 0.4;
	vec4 lcdColor = vec4(pb,pb,pb,1.0);

	// Change every 1st, 2nd, and 3rd vertical strip to RGB respectively
	int px = int(mod(fragCoord.x,3.0));
	if (px == 1) lcdColor.r = 1.0;
	else if (px == 2) lcdColor.g = 1.0;
	else lcdColor.b = 1.0;

	// Darken every 3rd horizontal strip for scanline
	float sclV = 0.25;
	if (int(mod(fragCoord.y,3.0)) == 0) lcdColor.rgb = vec3(sclV,sclV,sclV);

	gl_FragColor = texColor*lcdColor;
}
