#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {
	float px = 1.0/resolution.y;
	float aspect = resolution.y/resolution.x;
	
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 position = (uv * 2.0) - 1.0;

	if (aspect < 1.0) {
		aspect = 1.0 / aspect;
		position.x *= aspect;
	} else {
		position.y *= aspect;
	}
	vec2 apos = abs(position);

	vec3 color = vec3(0.0);

	float border = 5.0 * px;
	vec2 bpos = abs(vec2(1.0) - border);
	
	if (max(apos.x, apos.y) > 1.0) {
		vec2 pos = position * 15.0;
		if (mod(pos.x - pos.y, 2.0) < 1.0) {
			color.r += 0.5;
		}
		if (mod(pos.x + pos.y, 2.0) < 1.0) {
			color.b += 0.5;
		}
	} else {
		if ((bpos.x < border) &&
		    (bpos.y < border)) {
			color = vec3(1.0);
		}
	
		if (length(position) < 0.1) {
			color = vec3(0.3);
		}
	}

	gl_FragColor = vec4(color, 1.0);
}
