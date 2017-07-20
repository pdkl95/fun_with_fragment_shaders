#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 resolution;

#define SPIN_SPEED 0.5
#define spin_offset() (time * SPIN_SPEED)

#define COLOR_Y_FG1 vec3(0.87843137,0.65882353,0.12941176)
#define COLOR_Y_BG1 vec3(0.38039216,0.22352941,0.03137255)
#define COLOR_Y_FG2 vec3(0.72156863,0.48235294,0.06666667)
#define COLOR_Y_BG2 vec3(0.25098039,0.14901961,0.01960784)

#define COLOR_B_FG1 vec3(0.09411765,0.32941176,0.00000000)
#define COLOR_B_BG1 vec3(0.01568627,0.24705882,0.40392157)
#define COLOR_B_FG2 vec3(0.00392157,0.29803922,0.00000000)
#define COLOR_B_BG2 vec3(0.00784314,0.17254902,0.27058824)

float color_mix;
#define COLOR_SELECT(a,b) mix(a, b, color_mix)

#define color_fg1() COLOR_SELECT(COLOR_Y_FG1, COLOR_B_FG1)
#define color_bg1() COLOR_SELECT(COLOR_Y_BG1, COLOR_B_BG1)
#define color_fg2() COLOR_SELECT(COLOR_Y_FG2, COLOR_B_FG2)
#define color_bg2() COLOR_SELECT(COLOR_Y_BG2, COLOR_B_BG2)

#define TAU 6.283185307179586

#define nsin(x) ((sin(x) + 1.0) / 2.0)
#define atan2(y,x) \
    ((abs(x) > abs(y)) ? \
     (3.14159265358979/2.0 - atan(x,y)) : \
     atan(y,x))

#define polar_to_cart(r,t) vec2((r) * cos(t), (r) * sin(t))
#define polarvec_to_cart(v) polar_to_cart((v).x, (v).y)
#define polar_normal(t) normalize(polar_to_cart(1.0, (t)))

vec2 position;

vec2 rotate(vec2 point, float rads)
{
    float cs = cos(rads);
    float sn = sin(rads);
    return point * mat2(cs, -sn, sn, cs);
}


// mat4 get_rotation_matrix(vec3 axis, float angle)
// {
//     axis = normalize(axis);
//     float s = sin(angle);
//     float c = cos(angle);
//     float oc = 1.0 - c;
    
//     return mat4(oc * axis.x * axis.x + c,
//                 oc * axis.x * axis.y - axis.z * s,
//                 oc * axis.z * axis.x + axis.y * s,
//                 0.0,
                
//                 oc * axis.x * axis.y + axis.z * s,
//                 oc * axis.y * axis.y + c,
//                 oc * axis.y * axis.z - axis.x * s,
//                 0.0,

//                 oc * axis.z * axis.x - axis.y * s,
//                 oc * axis.y * axis.z + axis.x * s,
//                 oc * axis.z * axis.z + c,
//                 0.0,
                
//                 0.0,
//                 0.0,
//                 0.0,
//                 1.0);
// }

// vec3 rotate3d(vec3 v, vec3 axis, float angle)
// {
//     mat4 m = get_rotation_matrix(axis, angle);
//     retur7n (m * vec4(v, 1.0)).xyz;
// }

vec2 lside;
vec2 rside;

float lineside(vec2 p1, vec2 p2, vec2 p)
{
    vec2 diff = p2 - p1;
    vec2 perp = vec2(-diff.y, diff.x);
    float d = dot(p - p1, perp);
    return sign(d);
}

bool in_region(float r, float width)
{
    vec2 lside2 = vec2(1.0, 0.0);
    vec2 rside2 = rotate(lside2, TAU/6.0);
    bool above_bottom = lineside(lside * r, rside * r, position) > 0.0;
    r += width;
    bool below_top    = lineside(lside * r, rside * r, position) > 0.0;
    
    return (!above_bottom && below_top);
}

void main()
{
    color_mix = 0.0;

	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 orig_position = (uv * 2.0) - 1.0;
	orig_position.y *= resolution.y/resolution.x;
    position = rotate(orig_position, spin_offset());

	vec3 color = vec3(0.0);

    // vec3 rotangle = vec3(sin(time/5.0),
    //                      sin((time + (TAU/3.3))/7.7),
    //                      0.0);
    // float rotsize = nsin(time + ((3.11 * TAU)/4.0)) * 0.32;
    // vec3 pos3d = rotate3d(vec3(position, 0.0), rotangle, rotsize);
    // position = pos3d.xy;

	float orig_theta = atan(position.y/ position.x) + (TAU/4.0);
    if (position.x < 0.0) { orig_theta += TAU/2.0; }
    float theta = orig_theta / TAU;
    theta = mod(theta, 1.0);

    float hextheta = theta * 6.0;
    float pairtheta = mod(hextheta, 2.0);

    float wedge_id = floor(hextheta);
    float wedge_angle = hextheta - wedge_id;

    float ltheta = (-TAU/2.0) * (TAU/4.0);
    lside = polar_normal(ltheta);
    rside = rotate(lside, TAU/.0);;

    vec3 fg = vec3(0.0);
    vec3 bg = vec3(0.0);

    if (pairtheta < 1.0) {
        fg = color_fg1();
        bg = color_bg1();
    } else {
        fg = color_fg2();
        bg = color_bg2();
    }

    color = bg;

	float r = length(position);

    if (in_region(nsin(time), 0.1)) {
        color = fg;
    }


    // float zbright = pos3d.z * 0.5;
    // color += zbright;

	gl_FragColor = vec4(color, 1.0);
}
