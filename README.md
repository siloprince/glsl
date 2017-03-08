# glsl
## ifdef 
* header
````
//#define shadertoy https://www.shadertoy.com/view/MtVXzz
#ifndef shadertoy
#define texture vec4(0);
#endif
````

* begin of main

````
#ifndef shadertoy
void main()
{
    highp vec2 fragCoord = gl_FragCoord.xy;
    vec4 fragColor = vec4(0);
#else
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
#endif
````

* end of main

````
#ifndef shadertoy
	    fragColor = vec4(red,0.,blue,1.0);
#else
         fragColor = getNyanCatColor(vec2(blue,red),time);    
#endif 

#ifndef shadertoy
    gl_FragColor = fragColor;
#endif 
````

## vscode GLSL Preview
    * iMouse is not supported
