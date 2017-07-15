// -- wobble2 by pdkl95 (2015) --

// Interacts with mouse position!

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define TAU 6.283185307179586
#define TAU_3 (TAU / 3.0)
#define TAU_4 (TAU / 4.0)
#define TAU_6 (TAU / 6.0)
#define TAU_8 (TAU / 8.0)
#define TAU_16 (TAU / 16.0)
#define TAU_32 (TAU / 32.0)
#define TAU_64 (TAU / 64.0)

#define LAST_TIME_DELTA   (1.0/50.0)
#define TS_MAG             3.4
#define RV_MAG             0.0666
#define RING_RADIUS        0.28
#define RING_WIDTH         0.1
#define RING_BORDER_WIDTH  0.01
#define RIPPLE_MAG        85.0
#define WOBBLE_MAG         0.02
#define HUE_CYCLE_TIME     4.0

vec3 rgb2hsv(in vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(in vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 rotate(in vec2 point, in float rads) {
	float cs = cos(rads);
	float sn = sin(rads);
	return point * mat2(cs, -sn, sn, cs);
}	

float rectify(in float x) {
    return ((x + 1.0) * 0.5);
}

float crectify(in float c) {
    return 1.0 - clamp(c, 0.0, 1.0);
}

float mkring(in float width, in float ringwidth, in vec2 obj_pos, in vec2 pos, in vec2 dir) {
    float d = distance(obj_pos, pos);
    float rnear = width - ringwidth;
    float rfar = width + ringwidth;
    if (d <= (rfar - RING_BORDER_WIDTH)) {
        float cyl_fade =  ((sin(time * 0.1) + 1.0) / 2.0) * 0.7 + 0.05;
        vec3 cyl_normal = vec3(vec2(obj_pos - pos), d);

        vec3 cyl_light_normal = vec3(-1.0, -1.0, -1.0);

        float cyl = (dot(cyl_normal, vec3(dir, -0.9)) * 0.12) +
            (dot(cyl_normal, cyl_light_normal) * 0.09);

        return cyl * (cyl_fade);
    }
    if (abs(d - rfar) < RING_BORDER_WIDTH) {
        return 1.0;
    }
    float rfar2 = 2.0 * rfar;
    if (d < rfar2) {
        return (rfar2 - d /rfar2);
        float rf2 = clamp(((d/4.0)/rfar2), 0.0, 1.0) / 8.0;
        return rf2;
    } else {
        return 0.0;
    }
}

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec2 position = (uv * 2.0) - 1.0;
    position.y *= resolution.y/resolution.x;

    float time_prev = time - LAST_TIME_DELTA;

    float ts        = TS_MAG * time;
    float ts_prev   = TS_MAG * time_prev;

    vec2 spot_freq      = vec2(0.7, 0.4);
    vec2 spot_amplitude = vec2(0.5, 0.3);

    vec2 sfreq      = spot_freq + (sin(100.0 + ts)      * WOBBLE_MAG) / ts;
    vec2 sfreq_prev = spot_freq + (sin(100.0 + ts_prev) * WOBBLE_MAG) / ts_prev;
    vec2  spot      = vec2(spot_amplitude.x * sin(sfreq.x * ts),
                           spot_amplitude.y * cos(sfreq.y * ts));
    vec2  spot_prev = vec2(spot_amplitude.x * sin(sfreq_prev.x * ts_prev),
                           spot_amplitude.y * cos(sfreq_prev.y * ts_prev));

    float ring_radius = RING_RADIUS;
    float ring_width  = RING_WIDTH;

    vec2 cmouse = (mouse * 2.0) - 1.0;

    float mwarp = ring_radius * 12.0;
    float mdist = distance(spot, cmouse) + mwarp / 8.0;
    float mfract = 1.01 - cos(TAU_64 - TAU_6 * ((mwarp - mdist) / mwarp));
    float mforce = mix(0.0, mfract, step(mdist, mwarp));

    vec2 mp = cmouse - position;
    vec2 nmp = normalize(mp);
    float dmp = distance(mouse, position);

    vec2 mvec = mforce * (mwarp / 7.0) * nmp;

    ring_radius = mix(ring_radius, ring_radius * 1.2,  mforce);
    ring_width  = mix(ring_width,  ring_width  * 0.8,  mforce);
    spot        = mix(spot,        spot        + (1.2 * mvec), mforce);
    spot_prev   = mix(spot_prev,   spot_prev   + (2.2 * mvec), mforce);

    vec2 pos = position;
    pos -= mvec;

    float mpd = 48.0 * (dmp/2.0 + 0.125);
    
    vec2 mpdvec = nmp / (mpd * mpd);
    pos = pos - mpdvec;
    
    vec2 dir        = spot - spot_prev;

    float d         = distance(spot,      pos);
    float d_prev    = distance(spot_prev, pos);

    float delta_d   = d - d_prev;

    float ripple    = sin(ts + (delta_d * RIPPLE_MAG));
    float rv        = RV_MAG * ripple;
    float ringv = mkring(ring_radius + rv, ring_width, spot, pos, dir);

    float tc = time * 5.0;

    float hue_cycle = HUE_CYCLE_TIME;
    float hue_time  = mod(time, hue_cycle);
    float hue_fract = hue_time / hue_cycle;

    vec3 top_color = mix(vec3(1.0, 1.0, 1.0), vec3(0.0, 0.0, 1.0), uv.x);
    vec3 bot_color = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), uv.x);
    vec3 basecolor = mix(bot_color, top_color, uv.y);
	
    vec3 hsvcolor = rgb2hsv(basecolor.rgb);
    hsvcolor.x = fract(hsvcolor.x + hue_fract);
    vec3 rcolor = hsv2rgb(hsvcolor);

    vec3 c = vec3( crectify(sin(1.5 * tc)) * rcolor.r,
                   crectify(cos(2.1 * tc)) * rcolor.g,
                   crectify(sin(3.7 * tc)) * rcolor.b );

    vec3 cmix = mix(c, rcolor, 1.0 - (ringv / 4.0));
    vec3 outc = cmix * ringv;
    float a = ringv + 0.185;

    gl_FragColor = vec4(outc, clamp(a, 0.0, 1.0));
}

