#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backbuffer;

#define TAU 6.283185307179586

#define NUMOBJ     32.0
#define SPEED      0.25
#define SIZE       ((resolution.x/3.0) + ((resolution.x/7.0) * sin(time / 1.33)))
#define VERTSCALE  0.66
#define LISS_SPEED (TAU * 3.557)
#define LISS_LIMIT 0.77


#define LASTCOLOR vec3(0.0, 0.0, 1.0)
#define NEXTCOLOR vec3(1.0, 0.0, 0.0)

float size     = SIZE / resolution.x;
float vertsize = size * VERTSCALE;

vec2 position;

vec2 pos_at_time(in float t)
{
	float tt = t * LISS_SPEED * TAU;
	
	vec2 lisa = vec2( sin( tt / 5.0 ),
			  sin( tt / 7.0 ) );

	return lisa * LISS_LIMIT;
}

vec2 bezier(in vec2 p0, in vec2 c1, in vec2 c2, in vec2 p3, float t )
{
    vec3 p;
    float mt = 1.0 - t;
    float b0 = mt * mt * mt;
    float b1 = 3.0 * t * mt * mt;
    float b2 = 3.0 * t * t * mt;
    float b3 = t * t * t;
    return (b0 * p0) + (b1 * c1) + (b2 * c2) + (b3 * p3);
}

vec3 obj_color(in float dist, in float radius, in vec3 objcolor)
{
	if (dist < radius) {
		return objcolor * ((radius - dist) / radius);
	} else {
		return vec3(0);
	}
}

float str(in float r, in float value)
{
	r *= 14.0;
	r += 0.88666;
	r = pow(r, (sin(time * TAU * (value / 7.0))/1.0) + 2.2);
	float f = 1.0 / (r * r);
	return f / 1.0;
}

vec3 obj(inout float glow, in float objtime, in float objspeed)
{
	float t = objtime * objspeed;

	float qt  = floor(t);
	float perc = t - qt;

	vec2 p0 = pos_at_time(qt);
	vec2 c1 = pos_at_time(qt + 0.3);
	vec2 c2 = pos_at_time(qt + 0.7);
	vec2 p3 = pos_at_time(qt + 1.0);

	float dp0 = distance(position, p0);
	float dp3 = distance(position, p3);
	
	vec2 curpos = bezier(p0, c1, c2, p3, perc);
	float curdist = distance(position, curpos);

	vec3 c = vec3(0.0);

	glow += str(curdist, 1.0/objspeed);
	//float f = str(dp0, 1.332) + str(dp3, 1.55) + str(curdist, 2.7);
	//c += obj_color(glow, size / 1111.0, vec3(0.1));
	//c += mix(vec3(0.0), vec3(1.0), glow/5.0);
	c += vec3(1.0) * (glow/25.0);

	//c += obj_color(dp0, vertsize, LASTCOLOR);
	//c += obj_color(dp3, vertsize, NEXTCOLOR);
	
	float fade = (sin(t * TAU / 4.0) + 1.0) / 2.0;
	vec3 movecolor = mix(LASTCOLOR, NEXTCOLOR, 1.0 - fade) * ((size - curdist) / size); 

	c += obj_color(curdist, size, movecolor);

	return c;
}

void main(void)
{
	position = ((gl_FragCoord.xy / resolution.xy) - 0.5) * 2.0;
	vec2 m = (mouse - 0.5) / 2.0;
	vec2 mm = (m * 0.17) * length(m);

	vec2 texpos = position * 1.027;
	vec2 uv = (texpos / 2.0) + 0.5;
	vec4 tex = texture2D(backbuffer, uv - mm);

	vec3 color = vec3(0.0);
	float alpha = 1.0;

	float glow = 0.0;

	for (float i = 0.0 ; i < NUMOBJ ; i += 1.0) {
		float  time_offset = 6.66;
		float speed_offset = sin(i) / 6.0;

		color += obj(glow,
			     time  + (i * time_offset),
			     SPEED + speed_offset);
	}

//	color += obj(glow, time, SPEED);

	color += mix(vec3(0.0), vec3(1.0), glow);

	alpha = clamp(glow, 0.0, 1.0);

	float ta = mix(alpha, tex.a, 0.6);
	color = (color ) + (tex.rgb * ta);
	alpha = 0.999 * ta;
	//alpha = ta;
	gl_FragColor = vec4(color, alpha);
}
