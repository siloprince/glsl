# glsl
## ifdef 
* header
````
//#version 150
//https://www.shadertoy.com/view/MtVXzz
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
````

* main

````
#if SHADER != SHADER_SHADERTOY
	    fragColor = vec4(red,green,blue,1.0);
#else
        fragColor = getNyanCatColor(vec2(blue,red),time);    
#endif 

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
````

## vscode GLSL Preview
    * iMouse is not supported
