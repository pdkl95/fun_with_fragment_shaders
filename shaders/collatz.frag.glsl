#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define SPEED 0.2
#define ORIGIN vec2(0.5, 0.0)
#define MACCEL 1.5
#define ZOOM 1.5
#define MAX_ITER 8.0

/***/


#define PI 3.1415926535897932384626433832795028841971693993751058209
#define cPI vec2(PI, 0.0)
#define cONE vec2(1.0, 0.0)
#define cTWO vec2(2.0, 0.0)
#define RED   vec3(1.0, 0.0, 0.0)
#define GREEN vec3(0.0, 1.0, 0.0)
#define BLUE  vec3(0.0, 0.0, 1.0)
#define WHITE vec3(1.0, 1.0, 1.0)

#define nsin(x) ((sin(x) + 1.0) / 2.0)

vec2 cmul(vec2 a, vec2 b) {
	return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x);
}

vec2 csin(vec2 z) {
	return vec2( 0.5 * sin(z.x) * (exp(z.y) + exp(-z.y)),
		     0.5 * cos(z.x) * (exp(z.y) - exp(-z.y)));
}

vec2 ccos(vec2 z) {
	return vec2( 0.5 * cos(z.x) * (exp(z.y) + exp(-z.y)),
		    -0.5 * sin(z.x) * (exp(z.y) - exp(-z.y)));
}

vec2 collatz(vec2 z) {
	return 0.25 * (
		cONE +
		cmul(vec2(4.0, 0.0), z) - 
		cmul(cONE + cmul(cTWO, z),
		     ccos(cmul(cPI, z))
		    )
	);
}

vec2 collatz_iter(vec2 z, float imax) {
	for (float i = 0.0; i < MAX_ITER; i += 1.0) {
		if (i >= imax) {
			return z;
		}

		z = collatz(z);
	}
	
	return z;
}

void main( void ) {
	float aspect = resolution.y / resolution.x;
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 position = (uv * 2.0) - 1.0;
	if (aspect < 1.0) {
		aspect = 1.0 / aspect;
		position.x *= aspect;
	} else {
		position.y *= aspect;
	}

	vec3 color = vec3(1.0);
	
	vec2 hmouse = vec2((mouse.x - 0.5) * 2.0, 0.0);

	float imax = MAX_ITER * nsin(time * SPEED);

	vec2 z = (ORIGIN + position - hmouse * MACCEL) * ZOOM;
	
	float cz = collatz_iter(z, imax).x;
	
	float acz = abs(cz);
	float mcz = sqrt(acz);
	
	color = vec3(clamp(mcz, 0.0, 1.0));
	color = WHITE - color;
		
	gl_FragColor = vec4(color, 1.0);
}
