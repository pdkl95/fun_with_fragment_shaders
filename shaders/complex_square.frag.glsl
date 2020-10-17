#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

/*** config ***/

#define FADE_RATE 4.0
#define LINEWIDTH 0.0085
#define SIZE (1.0/8.0)

/* uncomment this to use a complex square root
   instead of a complex square */
//#define DO_SQUARE_ROOT

/***/

#define TAU 6.283185307179586
#define PI (TAU/2.0)

#define nsin(x) ((sin(x) + 1.0) / 2.0)
#define ncos(x) ((cos(x) + 1.0) / 2.0)

#define cx_mul(a, b) vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x)
#define cx_div(a, b) vec2(((a.x*b.x+a.y*b.y)/(b.x*b.x+b.y*b.y)),((a.y*b.x-a.x*b.y)/(b.x*b.x+b.y*b.y)))
#define cx_modulus(a) length(a)
#define cx_conj(a) vec2(a.x,-a.y)

vec2 cx_exp(vec2 z) {
	return vec2(exp(z.x) * cos(z.y), exp(z.x) * sin(z.y));
}

vec2 cx_log(vec2 a) {
	float b =  atan(a.y,a.x);
	if (b>0.0) b-=2.0*3.1415;
	return vec2(log(length(a)),b);
}

vec2 cx_pow(vec2 z, float n) {
	float r2 = dot(z,z);
	return pow(r2,n/2.0)*vec2(cos(n*atan(z.y,z.x)),sin(n*atan(z.y,z.x)));
}

vec2 cx_pow2(vec2 z, vec2 a) {
	return cx_exp(cx_mul(cx_log(z), a));
}

vec2 cx_sqrt(vec2 a) {
    float r = sqrt(a.x*a.x+a.y*a.y);
    float rpart = sqrt(0.5*(r+a.x));
    float ipart = sqrt(0.5*(r-a.x));
    if (a.y < 0.0) ipart = -ipart;
    return vec2(rpart,ipart);
}

vec2 cx_mobius(vec2 a) {
    vec2 c1 = a - vec2(1.0,0.0);
    vec2 c2 = a + vec2(1.0,0.0);
    return cx_div(c1, c2);
}

vec2 rotate(in vec2 point, in float rads)
{
	float cs = cos(rads);
	float sn = sin(rads);
	return point * mat2(cs, -sn, sn, cs);
}

float ease(float k)
{
	if ((k *= 2.0) < 1.0) {
		return 0.5 * k * k * k * k * k;
	}

	return 0.5 * ((k -= 2.0) * k * k * k * k + 2.0);
}

void main( void ) {
	float fade = mod(time / FADE_RATE, 2.0);
	if (fade > 1.0) {
		fade = 2.0 - fade;
	}
	fade = ease(fade);

	vec2 position = ((gl_FragCoord.xy / resolution.xy ) * 2.0) - 1.0;
	position.y *= resolution.y/resolution.x;
	
	vec2 pos = position;


#ifdef DO_SQUARE_ROOT
	vec2 fpos = mix(position, cx_sqrt(position), fade);
#else
	vec2 fpos = cx_pow(position, fade + 1.0);
#endif

	vec2 frpos = mod(fpos, SIZE);

	vec3 color = vec3(0.0);
	
	color.rb = abs(fpos.yx) * 0.7;
	
	if ((frpos.x < LINEWIDTH) || (frpos.y < LINEWIDTH)) {
		color = vec3(1.0);
	}
	
	gl_FragColor = vec4(color, 1.0);
}
