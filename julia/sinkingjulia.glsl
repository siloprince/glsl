//#version 150
//https://www.shadertoy.com/view/MlGXWz
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

const float maxiter=200.;
const float miniter=30.;
const float pi = 4.*atan(1.,1.);
const float pi2 = pi*2.;
const float degree = 2.0;
const float speed = -0.18;
const float scale = 1.2;
const float ratio = 0.63;
const float ratiopi2 = ratio*pi2;
const vec2 one = vec2(1., 0.);

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

void getGradient(vec2 c,inout vec2 der,inout vec2 gz,inout float len, float bailout) {
        // based on gradient equation found at:
        // http://linas.org/art-gallery/escape/ray.html
    der = vec2(0);
    vec2 z = vec2(0);
    vec2 D = vec2(0);
    float xTemp;    
    float n = 0.;
    for(float i = 0.;i<miniter;i++)
    {
        n = i;
        if(length(z)>bailout) {
            break;
        }
        // compute new derivative:
        der = 2.* der *mat2(z*vec2(1,-1),z.yx) +  one;
        // compute new z value:        
        z = z *mat2(z*vec2(1,-1),z.yx) +  c;
    }
    len = length(z);
    float m = n + 1. - (log(log(len)) / log(2.));
    float f = pow(2.,-m); // Douady-Hubbard potential

    D.x = z.x*( der.x/2.) -z.y*(-der.y/2.); // real part of zn * Dn
    D.y = z.x*(-der.y/2.) +z.y*( der.x/2.); // imag part of zn * Dn
    gz = f*D / (len*len*log(len)); // gradient for c
}
float externalAngle(vec2 c, float bailout) {
    // uses 4th order Runge-Kutta integration to find external angle
    vec2 ck = c;
    vec2 ckTemp = vec2(0);
    vec2 der = vec2(0);
    float len = 0.;
    float derLength = 0.;
    float dist = 0.;
    vec2 gz = vec2(0);
    vec2 gzA = vec2(0);
    vec2 gzB = vec2(0);
    vec2 gzC = vec2(0);
    vec2 gzD = vec2(0);

    for(float i = 0.;i<maxiter;i++)
    {
        if(length(ck)>bailout) {
            break;
        }
        // integrate with Runge-Kutta outwards along gradient:
        getGradient(ck,der,gzA,len,bailout);
        
        derLength = length(der);
        dist = .5 * log(len) * len / derLength;
        dist = min(16.,0.5*dist); // reduce step size
        
        ckTemp = ck + (0.5 *dist *normalize(gzA)); // walk to midpoint
        getGradient(ckTemp,der,gzB,len,bailout);
        
        ckTemp = ck + (0.5 * dist * normalize(gzB)); // walk to midpoint using B
        getGradient(ckTemp,der,gzC,len,bailout);
        
        ckTemp = ck + (dist * normalize(gzC)); // walk full step using C
        getGradient(ckTemp,der,gzD,len,bailout);
        
        gz = (gzA +2.*(gzB+gzC) +gzD)/6.; // average the values together
        
        ck += dist * normalize(gz); // normalize gradient and scale by dist
    }
    return (atan(ck.y,ck.x));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime;
	float t =mod(speed*time,1.);
    float iter=0.;
    vec2 z = vec2(0);
	vec2 c =  (2.*fragCoord.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.)+vec2(0.11,0))*scale;
    float magic = mix(sqrt(ratiopi2),ratiopi2,t);
	float bailout = exp(magic);
    bool bailed=false;
    for(float i = 0.;i<maxiter;i++)
    {
        iter=i;
        if (degree==2.) {
          z=z*mat2(z*vec2(1,-1),z.yx)+c;
        } else if (degree==3.) {
           // TODO:
        }
        if(length(z)>bailout) {
            bailed = true;
            break;
        }
    }
    float angle=0.;
    if (bailed) {
	    angle = externalAngle(c,bailout);
    } else {
        fragColor = vec4(0);
        return;
    }
 
    float bx = atan(z.y,z.x);

    float ex = angle/pi;
    if (c.y < 0.) {
        ex *= -1.;
        bx = 1.-bx;
    }
    float dx = ex*pow(degree,iter); //
    //dx = sign(dx)*(floor(abs(dx))+bx);
    float cx = mix(2.*dx,dx,t);
    float cy = log(length(z));

     if (c.y < 0.) {
        cx *= -1.;
    }   
    
    //cx += -0.8*speed*time*pow(degree,iter);
    //atan(z.y,z.x);// 
    float red = 1.0-mod(cy/magic,1.);
    float green = 0.;
    float blue  = 1.0-mod(cx,1.);    
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