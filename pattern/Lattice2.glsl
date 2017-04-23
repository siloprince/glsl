//#version 150
// https://www.shadertoy.com/view/ldjyzK
// originally
// https://github.com/keijiro/ShaderSketches/blob/master/Fragment/Lattice2.glsl
#define SHADER_SHADERTOY 0
#define SHADER_VSCODE 1
#define SHADER_KODELIFE 2

#if __VERSION__ != 150
//#define SHADER SHADER_SHADERTOY
#define SHADER SHADER_VSCODE
#else
#define SHADER SHADER_KODELIFE
#endif

#if SHADER != SHADER_SHADERTOY
#define texture vec4(0);
#endif
#if SHADER == SHADER_KODELIFE
uniform float time;uniform vec2 mouse, resolution;uniform vec3 spectrum;uniform sampler2D texture0, texture1, texture2, texture3, prevFrame;out vec4 fragColor;
#define iResolution resolution
#define iGlobalTime time
#define iMouse mouse
#define iChannel0 texture0
#define iChannel1 texture1
#define iChannel2 texture2
#define iChannel3 texture3
#endif

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float pi = 3.1415926;
    float t = iGlobalTime * 0.7;

    float scale = 10. / float(iResolution.y);
    vec2 p = gl_FragCoord.xy * scale + 0.5; // pos normalized /w grid
    p += vec2(2, 0.5) * iGlobalTime;

    float rnd = fract(sin(dot(floor(p), vec2(21.98, 19.37))) * 4231.73);
    float flip = fract(rnd * 13.8273) > 0.5 ? 1. : -1.;
    rnd = floor(rnd * 2.) / 2. + floor(t) * flip / 2.;

    float anim = smoothstep(0., 0.66, fract(t));
    float phi = pi * (rnd + anim * flip / 2. + 0.25);
    vec2 offs = vec2(cos(phi), sin(phi)) * sqrt(2.) / 2.;

    vec2 pf = fract(p);
    float d1 = abs(0.5 - distance(pf, vec2(0.5 - offs))); // arc 1
    float d2 = abs(0.5 - distance(pf, vec2(0.5 + offs))); // arc 2

    float w = 0.1 + 0.08 * sin(t);
    fragColor = vec4((w - min(d1, d2)) / scale);
}

#if SHADER != SHADER_SHADERTOY
void main(void)
{
#if SHADER == SHADER_VSCODE
    vec4 fragColor = vec4(0);
#endif
    mainImage(fragColor,gl_FragCoord.xy);
#if SHADER == SHADER_VSCODE 
    gl_FragColor = fragColor;
#endif  
}
#endif 