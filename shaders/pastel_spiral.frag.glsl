#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define TAU 6.283185307179586

#define PI TAU/2.0
#define PI_2 (PI/2.0)
#define LINEWIDTH (PI/64.0)
#define NOTLINE (PI_2 - LINEWIDTH)
#define EDGEWIDTH ((LINEWIDTH) * 4.0)
#define NOTEDGE (NOTLINE - ((EDGEWIDTH) * 2.0))

#define COLOR_LINE   vec3(0.7803921568627451, 0.9568627450980393, 0.39215686274509803)
#define COLOR_A_EDGE vec3(1.0, 0.4196078431372549, 0.4196078431372549)
#define COLOR_A_MID  vec3(0.7686274509803922, 0.30196078431372547, 0.34509803921568627)
#define COLOR_B_EDGE vec3(0.3058823529411765, 0.803921568627451, 0.7686274509803922)
#define COLOR_B_MID  vec3(0.3333333333333333, 0.3843137254901961, 0.4392156862745098)

#define FADETIME 1.5

#define atan2(y,x) ((abs(x) > abs(y)) ? (3.14159265358979/2.0 - atan(x,y)) : atan(y,x))

vec3 colorize(in float t, in vec3 edge, in vec3 mid) {
	if (t > NOTLINE) {
		return COLOR_LINE;
	} else {
		if ((t < EDGEWIDTH) || (t > (EDGEWIDTH + NOTEDGE))) {
			return edge;
		} else {
			return mid;
		}
	}
}

void main() {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 position = (uv * 2.0) - 1.0;
	position.y *= resolution.y/resolution.x;
	vec3 color = vec3(0.0);

	float fade = sin(time * FADETIME);

	float theta = atan(position.y/ position.x);
	float r = length(position);
	float tt = mod(time + theta - pow(r, 0.8 + (1.2 * fade)), TAU/2.0);
	
	
	color = (tt > PI_2)
		? colorize(tt - PI_2, COLOR_A_EDGE, COLOR_A_MID)
		: colorize(tt,        COLOR_B_EDGE, COLOR_B_MID);


	gl_FragColor = vec4(color, 1.0);
}
