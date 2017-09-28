#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 resolution;


vec3 bump3y(in vec3 x, in vec3 yoffset)
{
	vec3 y = vec3(1.0) - x * x;
	y = clamp(y - yoffset, 0.0, 1.9);
	return y;
}

vec3 spectral_zucconi(float x)
{
	const vec3 cs = vec3(3.54541723, 2.86670055, 2.29421995);
	const vec3 xs = vec3(0.69548916, 0.49416934, 0.28269708);
	const vec3 ys = vec3(0.02320775, 0.15936245, 0.53520021);

	return bump3y(cs * (x - xs), ys);
}

vec3 spectral_zucconi6(in float x)
{
	const vec3 c1 = vec3(3.54585104, 2.93225262, 2.41593945);
	const vec3 x1 = vec3(0.69549072, 0.49228336, 0.27699880);
	const vec3 y1 = vec3(0.02312639, 0.15225084, 0.52607955);

	const vec3 c2 = vec3(3.90307140, 3.21182957, 3.96587128);
	const vec3 x2 = vec3(0.11748627, 0.86755042, 0.66077860);
	const vec3 y2 = vec3(0.84897130, 0.88445281, 0.73949448);

	return
        bump3y(c1 * (x - x1), y1) +
        bump3y(c2 * (x - x2), y2);
}


void main( void ) {
	vec2 position = gl_FragCoord.xy / resolution.xy;

	float w = position.x;
	
	float period = mod(time, 4.0);

	vec3 color = (period > 2.0) ? spectral_zucconi(w) : spectral_zucconi6(w);
	gl_FragColor = vec4(color, 1.0);
}
