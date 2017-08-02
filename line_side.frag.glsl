#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

/*
 *            /
 *          (B)
 *    0.0   /
 *         /
 *        /   1.0
 *      (A)
 *      /
 */
float line_side(vec2 a, vec2 b, vec2 p)
{
	return step(((b.x - a.x) * (p.y - a.y)) - 
		    ((b.y - a.y) * (p.x - a.x)), 0.0);	
}

void main(void)
{
	vec2 uv = ((gl_FragCoord.xy / resolution.xy) * 2.0) - 1.0;
	uv.x *= resolution.x / resolution.y;

	vec3 color = vec3(0.0);

	color.r = line_side(vec2(0.0, 0.0), vec2(1.0, 0.5), uv);

	gl_FragColor = vec4(color, 1.0);
}
