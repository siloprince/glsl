//#version 150
//https://www.shadertoy.com/view/4tySDz
#define SHADER_SHADERTOY 0
#define SHADER_VSCODE 1
#define SHADER_KODELIFE 2

//#define SHADER SHADER_SHADERTOY
#define SHADER SHADER_VSCODE
//#define SHADER SHADER_KODELIFE

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

const float maxiter=256.;
const float pi = 4.0*atan(1.,1.);
const float pi2 = pi*2.;
const float degree = 2.0;
const float ratio = .6;
const float ratiopi2 = ratio*pi2;
const float bailout = exp(ratiopi2);
const float speed = -0.5;
const float scale = 1.4;

vec4 getNyanCatColor( vec2 p, float time )
{
	p = clamp(p,0.0,1.0);
    p.x = mix(0.07, 0.9, p.x);
    p.y = mix(0.24, 0.78, p.y);
	p.x = p.x*40.0/256.0;
	p.y = 0.5 + 1.2*(0.5-p.y);
	p = clamp(p,0.0,1.0);
	float fr = floor( mod( 20.0*time, 6.0 ) );
	p.x += fr*40.0/256.0;
	return texture( iChannel0, p );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime;
    float iter=0.;
	vec2 z =  scale*(2.*fragCoord.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.));
    vec2 uv=2.*iMouse.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.);
    if(iMouse.xy==vec2(0.))
        uv=vec2(-1.,0.);
    bool bailed=false;
    for(float i = 0.;i<maxiter;i++)
    {
        iter=i;
        float a = 3./2.;
        float x = z.x;
        float y = z.y;
        float xx = x*x;
		float yy = y*y;
		z.x = -a*x + x*xx - 3.*x* yy;
		z.y = -y*(a - 3. *xx + yy);

        if(length(z)>bailout) {
            bailed = true;
            break;
        }
    }
    if (bailed==false) {
        fragColor = vec4(0);
        return;
    }
    
    float cx = atan(z.y,z.x);
    float cy = log(length(z));

    cx += speed*time*pow(degree,iter);
    
    float red = mod(cy/(ratiopi2),1.);
    float green = 0.;
    float blue  = mod(cx/(2.*pi),1.);   
#if SHADER != SHADER_SHADERTOY
	    fragColor = vec4(red,green,blue,1.0);
#else
        fragColor = getNyanCatColor(vec2(blue,red),time);    
#endif 

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