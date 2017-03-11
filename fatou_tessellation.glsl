//#define shadertoy https://www.shadertoy.com/view/MtGXzz
#ifndef shadertoy
#define texture vec4(0);
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

    cx += speed*time*pow(degree,iter);
    
    float red = mod(cy/(ratiopi2),1.);
    float green = 0.;
    float blue  = mod(cx/(2.*pi),1.);    
#ifndef shadertoy
	fragColor = vec4(red,green,blue,1.0);
#else
    fragColor = getNyanCatColor(vec2(blue,red),time);    
#endif 
}

#ifndef shadertoy
void main(void)
{
    vec4 fragColor = vec4(0);
    mainImage(fragColor,gl_FragCoord.xy);
    gl_FragColor = fragColor;
}
#endif 