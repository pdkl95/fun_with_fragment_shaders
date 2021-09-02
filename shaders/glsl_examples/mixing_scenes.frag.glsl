#version 330

in vec2 position;
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;


layout(location = 0) out vec4 frag_color;

/*
 * Utility function that rescales values
 *   from: the zero-centered range [-1.0 -> 1.0]
 *     to: the half-size, always-positive range [0.0 -> 1.0]
 * 
 * example:
 *   uncenter(sin(...)) varies between 0 and 1, which is useful
 *     as a color value, input to mix(), etc.
 */
#define uncenter(value) ((value + 1.0) / 2.0)

/*
 * opposite of uncenter() - centers values in range [0.0 -> 1.0]
 * to the range [-1.0 -> 1.0], such that [0.0, 0.0] is in the
 * center of the screen
 */
#define to_center(value) ((value * 2.0) - 1.0)

void main(void) {
    //void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    /*
     * convert the current pixel (fragment) coords
     *   from pixels (0 <= fragCoord < iResolution)
     *   to fraction-of-the-image (0.0 < uv < 1.0)
     *   where the top left is [0.0, 0.0]
     */
    //vec2 uv = fragCoord/iResolution.xy;
    vec2 uv = uncenter(position);

    /*
     * uv recentered so [0.0, 0.0] is the center of the screen.
     *   uv.x ranges from -1.0 (left edge) to 1.0 (right edge)
     *   uv.y ranges from -1.0 (top edge) to 1.0 (bottom edge)
     *
     * Note that math on a vec2/vec3/vec4 applies in parallel
     *   to each component! By working with vectors, We get both
     *   parallel computaton and cleaner source code for free!
     &
     *   This expression is equivalent to:
     *     float pos_x = (uv.x * 2.0) - 1.0;
     *     float pos_y = (uv.y * 2.0) - 1.0;
     *     vec2 pos = vec2( pos_x, pos_y );
     */
    vec2 pos = (uv * 2.0) - 1.0;
    //vec2 pos = to_center(uv);

    /*
     * other useful values
     */
    float slow_fade = uncenter(sin(time * 0.25));
    float fast_fade = uncenter(sin(time * 2.0));

    float fancy_fade = 0.2 + (slow_fade * 0.5) + (fast_fade * 0.3);

    // length of the "pos" vector is the distance to the center of the screen
    float center_dist = length(pos);
    // max distance is the corner: vec2(1.0, 1.0)
    float max_center_dist = length(vec2(1.0, 1.0));
    float normalized_center_dist = center_dist / max_center_dist;

    // mouse stuff
    //vec2 mouse = iMouse.xy/iResolution.xy;
    vec2 mouse_pos = mouse; //to_center(mouse);
    float mouse_dist = distance(pos, mouse_pos);
    float in_mouse_hl_ring = step(mouse_dist, 0.05) // outer distance
        * step(0.03, mouse_dist); // inner distance

    /*
     * define some RGB colors
     */
    // show uv.x as red, uv.y as blue
    vec3 color_uvx_as_red  = vec3(uv.x, 0.0, 0.0);
    vec3 color_uvy_as_blue = vec3(0.0, 0.0, uv.y);
    vec3 color_uv_as_rb    = vec3(uv.x, 0.0, uv.y);

    // fade between gradients over time
    vec3 color_gradient_fade = mix(color_uvx_as_red,
                                   color_uvy_as_blue,
                                   fast_fade);

    // show the distance to the center of the screen
    // brighter is further away
    // scaled to max distance at the corner
    vec3 color_center_dist = vec3(normalized_center_dist);

    // highlight mouse position with a circle
    vec3 color_mouse_hl = mix( vec3(0.0),
                               vec3(1.0, 0.78, 0.0588),
                               in_mouse_hl_ring );

    // fun shading based on the dot product
    float mouse_dot = dot(pos, mouse_pos);
    float mouse_halo = clamp(mouse_dot - (1.0-mouse_dist*fancy_fade), 0.0, 1.0);
    vec3 color_mouse_halo = vec3(0.3647, 0.298, 0.937) * mouse_halo;
    float mouse_shadow = clamp(1.0 - mouse_dist, 0.0, 1.0);
    float mouse_centershade = clamp(1.0 - center_dist, 0.0, 1.0);
    vec3 color_mouse_shadow = vec3(0.9294, 0.2941, 0.5882) * (mouse_shadow * mouse_centershade) * (1.0 - fancy_fade);

    vec3 color_mouse_dotfun =
        mix((color_mouse_halo * fancy_fade) + color_mouse_shadow,
            color_mouse_hl,
            in_mouse_hl_ring);

    /*
     * default to black (#000)
     */
    vec3 color = vec3(0.0);

    /*
     * which scene to show?
     * (uncomment one of these)
     */

    /* SCENE #1:
          visualize uv as two gradients */
    //color = color_uv_as_rb;

    /* SCENE #2:
          fade between two gradients by mixing colors */
    //color = color_gradient_fade;

    /* SCENE #3:
         using some basic linear algebra */
    //color = color_center_dist;

    /* SCENE #4:
         mouse highlight ring (click somewhere) *dot(pos, mouse_pos));/
    //color = color_mouse_hl;

    /* SCEN$ #5:
       mouse highlight with fading dotproduct shading */
    //color = color_mouse_dotfun;

    /*
     * output the pixel (fragment) color with standard (opaque) alpha
     */
    frag_color = vec4(color, 1.0);
}

