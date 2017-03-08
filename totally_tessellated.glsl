//#define shadertoy https://www.shadertoy.com/view/ltKXRR
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
const float speed = -0.65;
const float scale = 1.15;

const float pxa = 0.07;
const float pxb = 0.225;
const float pxc = 0.75;
const float pxd = 0.9;
const float pxw = (pxb-pxa)/(pxc-pxb);
const float pxz = (pxd-pxc)/(pxc-pxb);
const float pxv = pxz/(1.+pxw+pxz);

const float pyb = 0.27;
const float pyc = 0.70;
const float pyd = 0.78;
const float pyz = (pyd-pyc)/(pyc-pyb);
const float pyv = pyz/(1.+pyz);

vec2 transNyanCat(vec2 pos, float time) {
 	pos.x = pos.x*40.0/256.0;
	pos.y = 0.5 + 1.2*(0.5-pos.y);
	pos = clamp(pos,0.0,1.0);
	float fr = floor( mod( 20.0*time, 6.0 ) );
	pos.x += fr*40.0/256.0;           
    return pos;
}
vec4 getNyanCatColor( vec2 p, float time)
{
	p = clamp(p,0.0,1.0);
    
    vec4 txtr = vec4(1.,1.,1.,1.);
    if (p.x <= pxz ) {
        vec2 r =  vec2(p.x/pxv, p.y);
        r.x = mix(pxc, pxd, r.x);
        r.y = mix(pyb, pyc,r.y);
        r = transNyanCat(r, time);
  	    txtr = texture( iChannel0, r );    
       if (!(txtr.x==1. && txtr.y==1. && txtr.z==1. )) {
           return txtr;
       }
    }
    if ( p.y <= pyv) {
        vec2 q = vec2(mod(p.x*2.,1.), p.y/pyv);
        q.x = mix(pxb, pxc, q.x); // intentinally shoten to avoid conflict
        q.y = mix(pyc, pyd, q.y);
        q = transNyanCat(q, time);
  	    txtr = texture( iChannel0, q );
       if (!(txtr.x==1. && txtr.y==1. && txtr.z==1. )) {
          return txtr;
       }
    }
    p.x = mix(pxb, pxc, p.x);
    p.y = mix(pyb, pyc, p.y);   
    p = transNyanCat(p, time);
	txtr = texture( iChannel0, p );
    return txtr;
}

#ifndef shadertoy
void main()
{
    highp vec2 fragCoord = gl_FragCoord.xy;
    vec4 fragColor = vec4(0);
#else
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
#endif
    float time = iGlobalTime;
    float iter=0.;
	vec2 z =  scale*(2.*fragCoord.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.));
    vec2 uv=2.*iMouse.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.);
    if(iMouse.xy==vec2(0.))
        uv=vec2(0.25,0.);
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
    float blue = 0.;
    float green  = mod(cx/(2.*pi),1.);
#ifndef shadertoy
	fragColor = vec4(red,green,blue,1.0);
#else
    fragColor = getNyanCatColor(vec2(green,red),time);    
#endif 

#ifndef shadertoy
    gl_FragColor = fragColor;
#endif      
}