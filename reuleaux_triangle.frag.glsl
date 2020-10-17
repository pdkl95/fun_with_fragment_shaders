#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

/*
 * "Reuleaux triangle based drill bit" by pdkl95 (2019)
 */

#define N 2.96
//#define N 3.0
#define RESET_TIME 8.0

#define AXEL_OUTER_RADIUS 0.08
#define AXEL_INNER_RADIUS (AXEL_OUTER_RADIUS * 0.4)
#define SPOKE_WIDTH       0.017
#define RIM_WIDTH         0.08

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backbuffer;

#define TAU 6.283185307179586
#define TAU_2 (TAU / 2.0)
#define TAU_3 (TAU / 3.0)
#define TAU_4 (TAU / 4.0)
#define TAU_6 (TAU / 6.0)

#define TWOTAU_3 (2.0 * TAU_3)

#define nsin(x) ((sin(x) + 1.0) / 2.0)

vec2 rotate(vec2 point, float rads)
{
    float cs = cos(rads);
    float sn = sin(rads);
    return point * mat2(cs, -sn, sn, cs);
}

float g(in float theta)
{
	if (theta < TAU_3) {
		if (theta < 0.0) {
			return theta - TAU_3;
		} else {
			return theta + TAU_3;
		}
	} else {
		return theta;
	}
}

float p(in float theta, in float n)
{
	return pow(-1.0/(2.0 * cos(g(theta))), 1.0/n);
}

void main(void)
{
	float px = 1.0/resolution.y;
	float aspect =- resolution.y/resolution.x;
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 position = (uv * 2.0) - 1.0;
	if (aspect < 1.0) {
		aspect = 1.0/aspect;
		position.x *= aspect;
	} else {
		position.y += aspect;
	}

	vec4 tex = texture2D(backbuffer, uv);
	
	float n = N;
	float minor_inner_r = p(TAU_2, n);
	float major_inner_r = p(0.0, n);
	float d =  minor_inner_r + major_inner_r;
	float dr = d/2.0;

	float ctime = time * 3.0;
	vec2 center = vec2(cos(ctime), sin(ctime)) * (1.0 - dr);
	vec2 rposition = rotate(position + center, time);
	
	vec3 color = vec3(0.0);
	float alpha = tex.a;	
	if (mod(time, RESET_TIME) < 0.2) { alpha = 0.0; }
	
	float r = length(rposition);
	float theta = atan(rposition.y, rposition.x);
	
	float unittheta = theta;
	if (unittheta < 0.0) {
		unittheta += TAU;
	}
	unittheta /= TAU;
	
	if (theta < -TAU_3) {
		theta += TAU;
	}

	
	float pr = p(theta, n);

	color = vec3(mix(0.4,
			 mix(0.0, 0.6, step(0.9, alpha)),
			 step(0.4, alpha)));

	if (r < pr) {
		float rplen = length(rposition);
		if (alpha < 0.4) {
		alpha = 0.5;
		}

		if ((rplen > AXEL_INNER_RADIUS) &&
		    !((abs(position.x) > dr) || (abs(position.y) > dr))
		   ) {
#define THREEWAY_NEARZERO(expr) (abs(mod(expr, TAU_3) - TAU_6)  < (SPOKE_WIDTH / r))
			if (THREEWAY_NEARZERO(theta) || THREEWAY_NEARZERO(theta + TAU_6)) {
				color.b = 0.88;
				color.rg = vec2(0.4);
			}
		}

		if ((r > (pr - RIM_WIDTH)) ||
		    ((rplen < AXEL_OUTER_RADIUS)) &&
		     (rplen > AXEL_INNER_RADIUS)) {
		
			color.b = 1.0;
			color.rg = vec2(0.0);
		}

		if (rplen < (AXEL_INNER_RADIUS)) {
			//color = vec3(0.0);
			alpha = 1.0;
		}
	}

	gl_FragColor = vec4(color, alpha);
}
