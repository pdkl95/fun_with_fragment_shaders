#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

#define MAXSTEPS 12.0

#define CELLSIZE 48.0
#define EDGESIZE 0.24
#define SHRINK 0.986

#define DRIFTSPEED (vec2(0.2, 0.08) * 330.0)

#define TAU 6.283185307179586

#define ENABLE_ROTATE  

#ifdef ENABLE_ROTATE
# define WAVEMAG (0.6/360.0)
# define WAVESPEED 1.8
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

vec2 halfres;
vec2 drift;

vec2 rotate(in vec2 point, in float rads)
{
    float cs = cos(rads);
    float sn = sin(rads);
    return point * mat2(cs, -sn, sn, cs);
}

bool hit_edge(in float pos)
{
	if (pos < (EDGESIZE / 3.0)) {
		return true;
	}
	if ((pos > ((2.0 * EDGESIZE) / 3.0)) &&
	    (pos < EDGESIZE)) {
		    return true;
	}
	return false;
}

bool hit_cell(in vec2 position)
{
	vec2 driftpos = position + drift;
	vec2 cell = mod(driftpos, CELLSIZE) / CELLSIZE;

	//return min(cell.x, cell.y) < EDGESIZE;
	return (hit_edge(cell.x) || hit_edge(cell.y));
}

void main(void)
{
	halfres = resolution/2.0;
	drift = time * DRIFTSPEED;

	vec2 position = gl_FragCoord.xy;
	vec3 color = vec3(1.0);
	
	for (float i = 0.0; i < MAXSTEPS; i += 1.0) {
		float ifrac = i/MAXSTEPS;

		if (hit_cell(position)) {
			color = vec3(ifrac);
			break;
		}
		
		position -= halfres;
		position /= SHRINK;
#ifdef ENABLE_ROTATE
		position = rotate(position, TAU * WAVEMAG * sin(time * WAVESPEED));
#endif
		position += halfres;
	}

	gl_FragColor =  vec4(color, 1.0);
}
