//#version 150
//https://www.shadertoy.com/view/MtVXDz
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

#define L for(int i=0;i<17;i++)
#define V vec4

void mainImage( out vec4 c, in vec2 w )
{
	V p = V(w,0.,1.);
	
	float v=.0, f, r[17];
    V s=V(2,2,1,0);

	L
		r[i]=0.;
	
	r[0]=p.x+p.y;
	r[1]=p.y;
	
	L{
		f=-2.*floor(r[i]/2.)/s[0];
		for(int j=0;j<3;j++)
			r[i+j]+=f*s[j];
        
	}
	
	L
		v+=mod(r[i],2.)*exp2(float(i));
    v/=exp2(17.);
    

	c = V(v);
  
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