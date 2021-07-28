#version 330

#ifdef GL_ES
precision mediump float;
#endif

layout(location = 0) out vec4 frag_color;

in vec2 position;
in vec4 color;

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;

#define TAU 6.283185307179586
#define PI (TAU/2.0)

float theta, r, use_mouse;
vec2 uv, mpos, uvm;

#define atan2(y,x) ((abs(x) > abs(y)) ? (3.14159265358979/2.0 - atan(x,y)) : atan(y,x))
#define nsin(x) ((sin(x) + 1.0) / 2.0)

vec2 rotate(in vec2 point, in float rads)
{
    float cs = cos(rads);
    float sn = sin(rads);
    return point * mat2(cs, -sn, sn, cs);
}

vec3 sdgBox(in vec2 p, in vec2 b)
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
                s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}

vec3 sdgCross(in vec2 p, in vec2 b)
{
    vec2 s = sign(p);
    p = abs(p);
    vec2 q = ((p.y>p.x)?p.yx:p.xy) - b;
    float h = max( q.x, q.y );
    vec2 o = max( (h<0.0)?vec2(b.y-b.x,0.0)-q:q, 0.0 );
    float l = length(o);
    vec3 r = (h<0.0 && -q.x<l)?vec3(-q.x,1.0,0.0):vec3(l,o/l);
    return vec3(sign(h)*r.x, s*((p.y>p.x)?r.zy:r.yz));
}

vec3 sdgHexagon(in vec2 p, in float r)
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    vec2 s = sign(p);
    p = abs(p);
    float w = dot(k.xy,p);
    p -= 2.0*min(w,0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    float d = length(p)*sign(p.y);
    vec2 g = (w<0.0) ? mat2(-k.y,-k.x,-k.x,k.y)*p : p;
    return vec3(d, s*g/d);
}

vec3 sdgRound(in vec3 dis_gra, in float r)
{
    return vec3(dis_gra.x - r, dis_gra.yz);
}

vec3 sdgOnion(in vec3 dis_gra, in float r)
{
    return vec3(abs(dis_gra.x) - r, sign(dis_gra.x)*dis_gra.yz);
}

vec3 sdgMax(in vec3 a, in vec3 b)
{
    return (a.x<b.x)?b:a;
}

vec3 sdgMin(in vec3 a, in vec3 b)
{
    return (a.x<b.x)?a:b;
}

vec3 sdgSmoothMin(in vec3 a, in vec3 b, in float k)
{
    float h = max(k-abs(a.x-b.x),0.0);
    float m = 0.25*h*h/k;
    float n = 0.50*  h/k;
    return vec3( min(a.x,  b.x) - m, 
                 mix(a.yz, b.yz, (a.x<b.x)?n:1.0-n) );
}

vec3 scene(in vec2 p)
{
    float dd = dot(p,mpos);

    vec2 off = mpos;
    vec3 hex = sdgHexagon(rotate(p - off, time), 0.45+dd);
    hex.yz = rotate(hex.yz, -time);
    vec3 cr = sdgCross(p, vec2(0.8-dd, 0.2+dd));

    vec3 hc = sdgSmoothMin(hex, cr, 0.02+dd);
    //vec3 hc = sdgMin(hex, cr);

    //hc = sdgRound(hc, 0.1);
    hc = sdgOnion(hc, 0.1+dd);

    return hc;
}

void main(void)
{
    use_mouse = step(-1.0, mouse.x);

    float aspect = resolution.x / resolution.y;
    uv = gl_FragCoord.xy / resolution;
    uv = uv * 2.0 - 1.0;
    uv.x *= aspect;

    mpos = mouse * use_mouse;
    mpos.x *= aspect;

    uvm = uv - mpos;

    theta = atan2(uvm.y, uvm.x);
#define T6 (TAU/6.0)
#define T12 (TAU/12.0)
    r = smoothstep(-T12, T12, mod(theta, TAU/6.0) - T12);

    vec3 sdg = scene(uv);
    float d = sdg.x;
    float da = abs(d);
    vec2 grad = sdg.yz;
    

    vec3 color = vec3(0);

#define BANDSIZE 0.05
#define LINESIZE 0.008

    float fade = nsin(r * TAU + (time * 6.0)) * 0.2;

    if (d > 0.0) {
        color.b = d;

        color += fade/4.0;
    } else {
        color.g = -d;
        color.g *= 4.0;
    }

    float gs = dot(grad, vec2(-1.0, 1.0));
    if (gs > 0.0) {
        if (d > 0.0) {
            //color += (gs)/1.0;
        } else {
            color *= 1.0 + gs/1.6;
        }
    } else {
        if (d > 0.0) {
        } else {
            color += gs / 24.0;
        }
    }

    bool odd = mod(da, BANDSIZE) < (BANDSIZE / 2.0);
    if (odd) {
        color *= 0.296;

        if (d > 0.0) {
            color.r += fade/2.0;
        }
    }

    if (da < LINESIZE) {
        float line = 1.0 - smoothstep(0.0, LINESIZE, da);
        color = max(color, vec3(line));
    }

    frag_color = vec4(color, 1.0);
}
