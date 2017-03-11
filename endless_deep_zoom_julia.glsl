//#version 150
//https://www.shadertoy.com/view/llySWz
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
const float speed = -0.0491528*2.;

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
vec2 getRepeller (vec2 z) {
	float x = z.x;
	float y = z.y;
	float com = pow(pow(1. -4.*x,2.) +16.*y*y,1./4.);
	float ax = 1.-4.*x;
	float ay = -4.*y;
	float ang = 0.;
	if (ax>0.) {
 		ang = atan(ay,ax);
	} else if (ax <0. && ay <0.) {
  		ang = atan(ay,ax) -pi;
	} else if (ax <0. && ay >=0.) {
  		ang = atan(ay,ax) +pi;
	} else if (ax==0. && ay >0.) {
  		ang =  pi/2.;
	} else if (ax==0. && ay <0.) {
  		ang = -pi/2.;
	}
	float re = (1. +com*cos(ang/2.))/2.;
	float im = com*sin(ang/2.)/2.;    
    vec2 w = vec2(re,im);
    return w;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime;
    float iter=0.;
    float scale = 165.5;
    float basespeed = 5.62;//3.75;
    float t =mod(time/basespeed,1.);
    float tt = (exp(t)-1.)/(exp(1.)-1.);
    
    vec2 uv=2.*iMouse.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.);   
    if(iMouse.xy==vec2(0.))
        uv=vec2(-1.,0.);
    
    float repeat = 1.;
    float theta = 0.;
    if (false) { 
	    uv = vec2(-1./4., 0.);
	    repeat = 2.4;
    } else if (false) {
    	uv = vec2(-1., 0.);
    	repeat = 3.25;
    } else  if (false) {
        float ppp = 0.5;
    	uv = vec2(mix(-1.,-1./4.,ppp), 0.);
    	repeat = mix(3.25,2.4,ppp);
    } else if (false) {
    	uv = vec2(-1., 0.2);
        // rotate
        repeat = 3.25;
        theta = 0.008*t*2.*pi;
     } else if (true) {
        float ppp=-1.4;
    	uv = vec2(-1., mix(0.,0.2,ppp));
        // rotate
        repeat = 3.25;
        theta = 0.0085*ppp*t*2.*pi;       
     } else {
    	uv = vec2(-0.4, 0.5);
        // rotate
        repeat = 10.2;
        theta = 0.05*t*2.*pi;       
    }
    

    float mag = 1./(scale*mix(1., repeat, tt ));
    
    //vec2 center = vec2((1.+sqrt(5.))/2., 0.);
    vec2 center = getRepeller(uv);
    
	vec2 z =   mag*(2.*fragCoord.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.));
    float zx = z.x;
    float zy = z.y;
    z.x = zx * cos(theta) - zy*sin(theta);
    z.y = zx * sin(theta) + zy*cos(theta);
    z += center;
    bool bailed=false;
    for(float i = 0.;i<maxiter;i++)
    {
        iter=i;
        z=z*mat2(z*vec2(1,-1),z.yx)+uv;

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

    cx += speed*t*pow(degree,iter);
    
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
