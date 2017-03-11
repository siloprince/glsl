# glsl
## ifdef 
* header
````
//#define shadertoy https://www.shadertoy.com/view/MtVXzz
#ifndef shadertoy
#define texture vec4(0);
#endif
````

* main

````
#ifndef shadertoy
	    fragColor = vec4(red,green,blue,1.0);
#else
        fragColor = getNyanCatColor(vec2(blue,red),time);    
#endif 

#ifndef shadertoy
void main(void)
{
    vec4 fragColor = vec4(0);
    mainImage(fragColor,gl_FragCoord.xy);
    gl_FragColor = fragColor;
}
#endif 
````

## vscode GLSL Preview
    * iMouse is not supported
