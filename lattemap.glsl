//#version 150
//https://www.shadertoy.com/view/ltVXWR
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
const float bailout = 1.*exp(ratiopi2);
const float speed = -0.5;
const float scale = 1.5;

vec2 cdiv(vec2 z0, vec2 z1) {
        float base = dot(z1,z1);
        vec3 crossed = cross(vec3(z1,0.),vec3(z0,0.));
        return vec2(dot(z1,z0),  crossed.z)/base;
}
vec2 cmul(vec2 z0,vec2 z1) {
        return z0*mat2(z1*vec2(1,-1),z1.yx);
}
vec2 cpow(vec2 z, int n) {
   vec2 m2 = cmul(z,z);
   if (n==2) {
      return m2;
   } else if (n==3) {
     return cmul(z,m2);
   } else if (n==4) {
     return cmul(m2,m2);
   } else {
     // todo:
     return vec2(0);
   }
}
// (z^2+1)^2 / (4 z (z^2-1))
vec2 g(vec2 z) {
        vec2 one = vec2(1.,0.);
        vec2 a = cmul(z,z);
        vec2 top  = cmul(a+one,a+one);
        vec2 base = cmul(z,a-one)*4.;
        return cdiv(top,base);
}
// z-> (z-2)^2/z^2
vec2 h(vec2 z) {
    	vec2 two = vec2(2., 0.);
    	vec2 a = cmul(z-two, z-two);
    	vec2 b = cmul(z,z);
    	return cdiv(a,b);
}
//  z -> (z2-a)^2/(4z(z-1)(z-a))
vec2 k(vec2 z,vec2 a) {
    	// k= -1 is the best
        vec2 z2 = cpow(z,2);
        vec2 top = cpow( z2-a, 2);
        vec2 base= 4.* cmul(z2-z, z-a);
        return cdiv(top,base);
}
vec2 mcmullen(vec2 z) {
        vec2 I = vec2(0.,1.);
        vec2 top = cpow(z- I, 2);
        vec2 base= cpow(z+ I, 2);
        return cdiv(top, base);
}
vec2 schroder(vec2 z, vec2 k) {
        vec2 one= vec2(1.,0.);
        vec2 z2 = cpow(z,2);
        vec2 k2 = cpow(k,2);
        vec2 top= 4. *cmul(z-z2, one -cmul(k2,z));
        vec2 base=cpow(one-cmul(k2,z2), 2);
        return cdiv(top,base);
}
vec2 milnorbeau(vec2 z, vec2 k) {
        vec2 one= vec2(1.,0.);
        vec2 z3 = cpow(z,3);
        vec2 top= z3+k;
        vec2 base=cmul(k,z3)+one;
        return cdiv(top,base);
}
vec2 milnorflex(vec2 z, vec2 k) {
        vec2 one= vec2(1.,0.);
        vec2 z2 = cmul(z,z);
        vec2 z3 = cmul(z2,z);
        vec2 z4 = cmul(z2,z2);
        vec2 k2 = cmul(k,k);
        vec2 k4 = cmul(k2,k2);
        vec2 up = cpow(cmul(k4,z4)-6.*cmul(k2,z2)+4.*cmul(k2+one,z)-3.*one,2);
        vec2 top= cmul(z,up);
        vec2 base=cpow(3.*cmul(k4,z4)-4.*cmul(k4,z3)-4.*cmul(k2,z3)+6.*cmul(k2,z2)-one,2);
        return cdiv(top,base);
}

vec2 ff(vec2 z, vec2 c) {
        return cmul(z,z)+c;
}
// z -> (z3+a)/(az3+1), with a = exp(2pi/3)
vec2 j(vec2 z) {
        vec2 z3 = cpow(z,3);
        float a = exp(pi2/3.);
        vec2 one =vec2(1.,0.);
        vec2 top = z3 +a *one;
        vec2 base= a *z3 +one;
        return cdiv(top, base);
}

vec2 f (vec2 z,  vec2 c, out int fnum, out vec2 fix0, out vec2 fix1, out vec2 fix2, out vec2 fix3) {
    fnum= 0;
    fix0 =fix1=fix2=fix3=vec2(0);
    vec2 w = vec2(0);
    if (false) {
        // skip
        // z -> z^2 + c
	    w = z*mat2(z*vec2(1,-1),z.yx)+c;
     } else if (false) {
        // nice
        // 
        w = schroder(z, vec2(0., 1.));            
      
    } else if (false) {
        // good
        w = g(z);   
        fnum = 4;
        // they are all repeller fixed points
        fix0.y = (sqrt(sqrt(17.) -3.))/2.;
        fix1 = -fix0;
        fix2.x = sqrt(sqrt(17.) +3.)/2.;
        fix3 = -fix2;          
    } else if (true) {
        // z -> (z + 1/z)/(2i )
        w = cdiv(z+cdiv(vec2(1.,0),z), vec2(0.,2));
        // they are all repeller fixed points        
        fnum = 4;
        fix0 = vec2(-0.351577584,0.56886448);
		fix1 = -fix0;
        fix2 = vec2(-0.7861513761216772, -1.272019649635746);
        fix3 = vec2(1.,0.);
    } else if (true) {
        // good but too complex
        // http://www.math.stonybrook.edu/~jack/PREPRINTS/lattes-ims.ps
        w = milnorflex(z, vec2(0., 1.));          
        
      } else if (true) {
        // good only for this param symm
        w = k(z, vec2(-1., 0.));            
               
     } else if (true) {
        // not symm
        w = mcmullen(z);
     } else if (true) {
        // bad
        w = j(z);         
    } else if (false) {
        // skip
        // what is w3?
        // http://www.math.stonybrook.edu/~jack/PREPRINTS/lattes-ims.ps
        w = milnorbeau(z, vec2(0, 1.));  
    } else if (true) {
        // z -> (z^2+1)^2 / (4 z (z^2-1)) 
        float x = z.x;
        float y = z.y;
		float xx = x *x;
		float xxx = xx *x;
		float xxxx = xxx *x;
		float xxxxx = xxxx *x;
		float xxxxxx = xxxxx *x;
		float xxxxxxx = xxxxxx *x;
		float yy = y *y;
		float yyy = yy *y;
		float yyyy = yyy *y;
		float yyyyy = yyyy *y;
		float yyyyyy = yyyyy *y;
		float yyyyyyy = yyyyyy *y;
        float xy = x *y;

		float base = (4. *(xx +yy) *(4. *xx *yy + pow(xx -yy -1., 2.)));

		w.x = ( (-x -xxx +xxxxx +xxxxxxx) + xy *( -(5. *y) +yyyyy +(5. *yyy) +(3. *xxxx *y) +2. *(3. *xx *y) +(3. *xx *yyy)))/base;

		w.y = ( (+y -yyy -yyyyy +yyyyyyy) + xy *( -(5. *x) +xxxxx -(5. *xxx) +(3. *x *yyyy) -2. *(3. *x *yy) +(3. *xxx *yy)))/base;        
    } else {
        // z-> (z-2)^2/z^2
        float x = z.x;
        float y = z.y;
		float xx = x *x;
		float xxx = xx *x;
		float xxxx = xxx *x;
		float xxxxx = xxxx *x;
		float xxxxxx = xxxxx *x;
		float xxxxxxx = xxxxxx *x;
		float yy = y *y;
		float yyy = yy *y;
		float yyyy = yyy *y;
		float yyyyy = yyyy *y;
		float yyyyyy = yyyyy *y;
		float yyyyyyy = yyyyyy *y;
        float xy = x *y;       
		float base = pow(xx + yy, 2.);
		float re = (2. *xx *yy +4. *xx -4. *x *yy -4. *yy + yyyy + xxxx - 4. *xxx)/base;
		float im = 4. *y *(xx - 2. *x + yy)/base;        
    }
    return w;
}
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
    vec2 z0 = z;
    bool bailed=false;
    int fnum;
    vec2 fix0,fix1,fix2,fix3;
    for(float i = 0.;i<maxiter;i++)
    {
        iter=i;
        z = f(z,uv,fnum,fix0,fix1,fix2,fix3);

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
    int fcnt=0;
    if (fnum>fcnt++  && length(fix0-z0)<0.05){
    	    fragColor = vec4(0.,0.,1.,1.);
      		return;
    }
    if (fnum>fcnt++  && length(fix1-z0)<0.05){
    	    fragColor = vec4(1.,0.,0.,1.);
      		return;
    }
    if (fnum>fcnt++  && length(fix2-z0)<0.05){
    	    fragColor = vec4(0.,1.,1.,1.);
      		return;
    }
    if (fnum>fcnt++  && length(fix3-z0)<0.05){
    	    fragColor = vec4(0.,1.,0.,1.);
      		return;
    }    
    
    float red = mod(cy/(ratiopi2),1.);
    float green = 0.;
    float blue  = mod(cx/(2.*pi),1.);    
#if SHADER != SHADER_SHADERTOY
	    fragColor = vec4(red,green,blue,1.0);
#else
        fragColor = getNyanCatColor(vec2(blue,red),time);    
#endif    
}

vec2 d_fn(vec2 z, int n) {
  vec2 one = vec2(1.,0.);
  vec2 z2  = cmul(z,z);
  vec2 z4  = cmul(z2,z2);
  if (n==1) {
    //return ((z^2 + 1) (z^4 - 6 z^2 + 1))/(4 z^2 (z^2 - 1)^2);

    vec2 top = cmul(z2 +one, z4 -6.*z2 +one);
    vec2 base= 4. *cmul(z2, cpow(z2 -one,2));
    return cdiv(top,base);
  } else if (n==2) {
    //https://www.wolframalpha.com/input/?i=(+(w%5E2%2B1)%5E2+%2F+(4+w+(w%5E2-1))+)+where+w+%3D++(z%5E2%2B1)%5E2+%2F+(4+z+(z%5E2-1))
    //return ((z^8 + 20 z^6 - 26 z^4 + 20 z^2 + 1) (z^16 - 88 z^14 + 92 z^12 - 872 z^10 + 1990 z^8 - 872 z^6 + 92 z^4 - 88 z^2 + 1))/(16 z^2 (z^2 - 1)^2 (z^2 + 1)^3 (z^4 - 6 z^2 + 1)^3);

    vec2 z6  = cmul(z2,z4);
    vec2 z8  = cmul(z4,z4);
    vec2 z10 = cmul(z8,z2);
    vec2 z12 = cmul(z8,z4);
    vec2 z14 = cmul(z8,z6);
    vec2 z16 = cmul(z8,z8);
    vec2 top = cmul(z8 +20.*z6 -26.*z4 +20.*z2 +one, z16 -88.*z14 +92.*z12 -872.*z10 +1990.*z8 -872.*z6 +92.*z4 -88.*z2 +one);
    vec2 base= cmul(16.*z2,cmul(cpow(z2 -one,2), cmul(cpow(z2 +1.,3),cpow(z4 -6.*z2 +one,3))));
    return cdiv(top, base);
  } else if (n==3) {

  }
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