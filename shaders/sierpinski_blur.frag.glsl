#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 resolution;
uniform sampler2D backbuffer;

//#define MAX_ITER 5
#define MAX_ITER 7
#define BLUR_AMT 0.85

vec3 get_px(in int dx, in int dy) {
	vec2 pos = vec2(gl_FragCoord.x - float(dx), gl_FragCoord.y - float(dy));
	if (pos.x < 0.0) {pos.x = resolution.x-1.0;;}
	if (pos.y < 0.0) {pos.y = resolution.y-1.0;}
	if (pos.x >= resolution.x) {pos.x = 0.0;}
	if (pos.y >= resolution.y) {pos.y = 0.0;}
	return texture2D(backbuffer, pos / resolution).rgb;
}

#define bpx(x,y,w) blur = blur + (get_px(x,y) * (w));
#define row(y,wl2,wl1,wm,wr1,wr2) bpx(-2,y,wl2) bpx(-1,y,wl1) bpx( 0,y,wm) bpx( 1,y,wr1) bpx( 2,y,wr2)

vec3 get_blur_px() {
	vec2 frag_pos = gl_FragCoord.xy / resolution.xy;
	float px_size = 1.0 / resolution.x;

	vec3 blur = vec3(0.0);
	row(-2,  0.007004, 0.020338, 0.029004, 0.020338, 0.007004);
	row(-1,  0.020338, 0.05906,  0.084226, 0.05906,  0.020338);
	row( 0,  0.029004, 0.084226, 0.120116, 0.084226, 0.029004);
	row( 1,  0.020338, 0.05906,  0.084226, 0.05906,  0.020338);
	row( 2,  0.007004, 0.020338, 0.029004, 0.020338, 0.007004);
	return blur;
}

vec2 rotate(in vec2 point, in float rads) {
	float cs = cos(rads);
	float sn = sin(rads);
	return point * mat2(cs, -sn, sn, cs);
}

float side_sign(in vec2 p1, in vec2 p2, in vec2 p3) {
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool point_in_triangle(in vec2 p, in vec2 a, in vec2 b, in vec2 c) {
	bool s1 = side_sign(p, a, b) < 0.0;
	bool s2 = side_sign(p, b, c) < 0.0;
	bool s3 = side_sign(p, c, a) < 0.0;
	return ((s1 == s2) && (s2 == s3));
}

bool point_in_sierpinski(in vec2 p, inout vec2 a, inout vec2 b, inout vec2 c) {
	vec2 ab = (a + b) / 2.0;
	vec2 bc = (b + c) / 2.0;
	vec2 ca = (c + a) / 2.0;
	
	if (point_in_triangle(p, a, ab, ca)) {
		b = ab;
		c = ca;
		return true;
	}
	
	if (point_in_triangle(p, b, bc, ab)) {
		a = ab;
		c = bc;
		return true;
	}
	
	if (point_in_triangle(p, c, bc, ca)) {
		b = bc;
		a = ca;
		return true;
	}
	
	return false;
}

void main(void) {

	vec2 position = ((gl_FragCoord.xy / resolution.xy ) * 2.0) - 1.0;
	float theta = time / 3.0;
	
	vec2 pos = rotate(position, theta);

	vec3 color = vec3(0.0);

	vec2 tri0 = vec2( 0.0,                 1.0);
	vec2 tri1 = vec2(-0.8660254037844387, -0.5);
	vec2 tri2 = vec2( 0.8660254037844387, -0.5);
	
	vec2 t0 = tri0;
	vec2 t1 = tri1;
	vec2 t2 = tri2;

	bool in_shape = point_in_triangle(pos, t0, t1, t2);
	
	if (in_shape) {
		int iter=MAX_ITER;

		for (int i=0; i<MAX_ITER; i++) {
			if (!point_in_sierpinski(pos, t0, t1, t2)) {
				//color = vec3(0.0);
				iter = i;
				break;
			}			
		}

		float f_iter = float(iter);
		float f_max_iter = float(MAX_ITER);
		float iter_perc = f_iter / f_max_iter;
		if (iter < MAX_ITER) {
			float glow = 0.15 + (sin(time / (0.5 + (iter_perc/3.0))) * 0.15);
			vec3 glow_color = vec3((1.0 - iter_perc) * glow);
			vec3 prev_color = get_blur_px();
			color = mix(glow_color, prev_color, BLUR_AMT);
		} else {
			color = vec3(1.4) - vec3(distance(pos, tri0),
						 distance(pos, tri1),
						 distance(pos, tri2));

		}
	} else {
		vec3 prev_color = get_blur_px();
		color = mix(color, prev_color, BLUR_AMT);
	}
	gl_FragColor = vec4(color, 1.0);
}
