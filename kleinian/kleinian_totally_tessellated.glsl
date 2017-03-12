//#version 150
//https://www.shadertoy.com/view/XtKXRh
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

precision mediump float;

// from Syntopia http://blog.hvidtfeldts.net/index.php/2015/01/path-tracing-3d-fractals/
vec2 rand2n(vec2 co, float sampleIndex) {
	vec2 seed = co * (sampleIndex + 1.0);
	seed+=vec2(-1,1);
	// implementation based on: lumina.sourceforge.net/Tutorials/Noise.html
	return vec2(fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453),
                 fract(cos(dot(seed.xy ,vec2(4.898,7.23))) * 23421.631));
}

vec2 circleInverse(vec2 pos, vec2 circlePos, float circleR){
	return ((pos - circlePos) * circleR * circleR)/(length(pos - circlePos) * length(pos - circlePos) ) + circlePos;
}

vec2 cPos1 = vec2(0);
vec2 cPos2 = vec2(0);
float cr1 = 0.;
float cr2 = 0.;
const int ITERATIONS = 50;
bool g_outer = false;
vec2 g_pos = vec2(0);
vec2 g_avepos = vec2(0);

const float a = 2.0*(atan(sqrt(3.) + sqrt(6.) - sqrt((2.*(10. + 7.*sqrt(2.)))/(1. + sqrt(2.))),1.));
vec2 move(vec2 pos, float t) {
        if (pos.x < 0.){
            pos *= vec2(-1, 1);
        }
        return pos;
}
int IIS(vec2 pos){
    //if(length(pos) > 1.) return 0;

    bool fund = true;
    int invCount = 1;
	for(int i = 0 ; i < ITERATIONS ; i++){
        fund = true;
        if(distance(pos, -cPos1) < cr1 ){
                pos = circleInverse(pos, -cPos1, cr1);
                invCount++;
                fund = false;

        }
        if(distance(pos, -cPos2) < cr2 ){
                pos = circleInverse(pos, -cPos2, cr2);
                invCount++;
                fund = false;
        }        
        /*
        if (pos.x < 0.){
            pos *= vec2(-1, 1);
            invCount++;
	       	fund = false;
        }
        if(pos.y < 0.){
            pos *= vec2(1, -1);
            invCount++;
            fund = false;
        }*/
        if(distance(pos, cPos1) < cr1 ){
                pos = circleInverse(pos, cPos1, cr1);
                invCount++;
                fund = false;

        }
        if(distance(pos, cPos2) < cr2 ){
                pos = circleInverse(pos, cPos2, cr2);
                invCount++;
                fund = false;
        }
        g_pos = pos;
        if(fund){
            if(length(pos) > 1.5){
                g_outer = true;
            	return invCount;
            }
        	return invCount;
        }
    }
	return invCount;
}


int calc(const float width, const float height, const vec2 coord){
    float ratio = width/height;
    vec2 pos = vec2(0);
    pos.y = mix(-ratio, ratio, coord.x/width);
    pos.x = mix(-1., 1., coord.y/height);
    return IIS(pos);
}

vec2 reverseStereoProject(vec3 pos){
	return vec2(pos.x / (1. - pos.z), pos.y / (1. - pos.z));
}

vec3 getCircleFromSphere(vec3 upper, vec3 lower){
	vec2 p1 = reverseStereoProject(upper);
    vec2 p2 = reverseStereoProject(lower);
   	return vec3((p1 + p2) / 2., distance(p1, p2)/ 2.); 
}

vec2 crosspoint (vec2 c1,vec2 c2, float cr1, float cr2) {

        float c1c2 = distance(c2, c1);
        float c1mid = (cr1*cr1 -cr2*cr2 +c1c2*c1c2)/(2.*c1c2);
        vec2  mid = mix(c1,c2,c1mid/c1c2);
        float pmid = sqrt(cr1*cr1-c1mid*c1mid);
        vec2  dir = c1-mid;
        vec2 vec = vec2(-1.*dir.y, dir.x);
        return (mid+ vec*(pmid/c1mid));
}
float calcU(float a,float b,float s, float r) {
    float aa=a*a;
    float bb=b*b;
    float ss=s*s;
    float rr=r*r;
    float aaa=a*a*a;
    float bbb=b*b*b;
    float sss=s*s*s;
    float rrr=r*r*r;

	float x = pow(16.0* aaa*sss - 48.* aa*sss - 60.* aa*ss + sqrt(pow(16.* aaa*sss - 48.*aa*sss - 60.* aa*ss + 144.* a*r*ss + 48.*a*sss + 120.*a*ss - 24.* a*s - 108.* bb*ss - 144.* r*ss + 36.* r*s - 16.* sss - 60.* ss + 24.* s - 2., 2.) + 4.*pow(12.*s*(2.* a*s - a + r + s) - pow(-2.* a*s - 4.*s + 1.,2.),3.)) + 144.*a*r*ss + 48.* a*sss + 120.* a*ss - 24.* a*s - 108.* bb*ss - 144.* r*ss + 36.* r*s - 16.* sss - 60.* ss + 24.* s - 2.,(1./3.))/(6.*pow(2.,(1./3.))*s) - (12.*s*(2.* a*s - a + r + s) - pow(-2.* a*s - 4.*s + 1.,2.))/(3.* pow(2.,(2./3.))*s*pow(16.* aaa*sss - 48.*aa *sss - 60.*aa*ss  + sqrt(pow(16.* aaa*sss - 48.*aa*sss - 60.* aa*ss + 144.* a* r* ss + 48.*a*sss + 120.* a*ss - 24.* a*s - 108.* bb*ss - 144.* r*ss + 36.* r*s - 16.* sss - 60.* ss + 24.* s - 2.,2.) + 4.* pow(12.* s*(2.* a*s - a + r + s) - pow(-2.*a* s - 4.*s + 1.,2.),3.)) + 144.* a*r*ss + 48.* a*sss + 120.*a*ss - 24.*a*s - 108.* bb+ ss - 144.*r*ss + 36.* r*s - 16.* sss - 60.* ss + 24.*s - 2.,(1./3.))) - (-2.* a*s - 4.*s + 1.)/(6.* s);
    return x;
}

vec2 transNyanCat(vec2 pos, float time) {
 	pos.x = pos.x*40.0/256.0;
	pos.y = 0.5 + 1.2*(0.5-pos.y);
	pos = clamp(pos,0.0,1.0);
	float fr = floor( mod( 20.0*time, 6.0 ) );
	pos.x += fr*40.0/256.0;           
    return pos;
}
const float pxa = 0.47;
const float pxb = 0.19;
const float pxc = 0.72;
const float pxd = 0.9;
const float pxw = (pxb-pxa)/(pxc-pxb);
const float pxz = (pxd-pxc)/(pxc-pxb);
const float pxv = pxz/(1.+pxw+pxz);

const float pyb = 0.21;
const float pyc = 0.74;
const float pyd = 0.78;
const float pyz = (pyd-pyc)/(pyc-pyb);
const float pyv = pyz/(1.+pyz);
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	float time = iGlobalTime;  
    float range = mod(0.16*time,1.);
    if (range>.5) {
        range = 1.-range;
    }
    //range = 0.;
    float bendX = .5*range;
    mat3 xRotate = mat3(1, 0, 0,
                        0, cos(bendX), -sin(bendX),
                        0, sin(bendX), cos(bendX));
    float bendY = 0.0;
    mat3 yRotate = mat3(cos(bendY), 0, sin(bendY),
                         0, 1, 0,
                         -sin(bendY), 0, cos(bendY));
    
    float vv = 1./sqrt(3.);
    vec3 va = vec3(0.,1., sqrt(2.))*vv;
    vec3 vb = vec3(0.,1., -sqrt(2.))*vv;
    vec3 c1 = getCircleFromSphere(va* xRotate,  vb* xRotate);
    vec3 c2 = getCircleFromSphere(va.yxz * yRotate,vb.yxz * yRotate);
 	vec2 l1 = reverseStereoProject(vb* xRotate);
    vec2 l2 = reverseStereoProject(vb.yxz * yRotate);   

	cr1 = c1.z;
    cr2 = c2.z;
    cPos1 = c1.xy;
    cPos2 = c2.xy;

    vec2 cro = crosspoint(cPos1, cPos2, cr1, cr2);    

    float even=0.;
    float odd=0.;
    float outside=0.;    
    float d = 0.;
    vec2 avepos = vec2(0);
    const float SAMPLE_NUM = 20.;
  	for(float i = 0. ; i < SAMPLE_NUM ; i++){
    	vec2 coordOffset = rand2n(gl_FragCoord.xy, i);
          
    	
    	int d = calc(iResolution.x, iResolution.y, fragCoord.xy + coordOffset);
        if(g_outer){
            outside+= 1.; 
        }else{            
			if(mod(float(d), 2.) == 0.){
              even += 1.;
            } else {
              odd += 1.;              
            }
            avepos += g_pos/SAMPLE_NUM;
        }        
  	}
    if (outside*3. > SAMPLE_NUM ) {
    	fragColor = vec4(0);
    } else {    
        float red = mod(.5*avepos.x/cro.x+0.5,1.);
        float blue =mod(.5*avepos.y/cro.y+0.5,1.);
        float green = 0.;
         if (even*3. > SAMPLE_NUM) {
             red = 1.-red;
             blue = 1.-blue;
    	} else if (odd*3. > SAMPLE_NUM) {
             red = 1.-red;
        }
        
        
        vec2 coe = vec2(1.);
        vec2 xy = vec2((red-.5)*2.,(blue-.5)*2.);
    	vec2 uv = vec2(0);
        
        if (xy.x==0.) {
            coe.x = 0.;
        } else if (xy.x>0.){
            coe.x = 1.;
        } else {
            coe.x = -1.;
        }
        if (xy.y==0.) {
            coe.y = 0.;
        } else if (xy.y>0.){
            coe.y = 1.;
        } else {
            coe.y = -1.;
        }

        uv.x = calcU(xy.x*coe.x, xy.y*coe.y,1.5, cr1);
        uv.y = calcU(xy.y*coe.y, xy.x*coe.x,1.5, cr2);
        uv.x = (uv.x*coe.x+1.)/2.;
        uv.y = (uv.y*coe.y+1.)/2.;
  		vec4 color = getNyanCatColor(uv.yx,time);//
        float d_p1 = distance( cPos1,avepos);
        float d_m1 = distance(-cPos1,avepos);
        float d_p2 = distance( cPos2,avepos);
        float d_m2 = distance(-cPos2,avepos);
        float d_min = 0.008;
        if ( (cr1 >= d_p1-d_min) || (cr1 >= d_m1-d_min) || (cr2 >= d_p2-d_min) || (cr2 >= d_m2-d_min)) { 
            green = 1.;
        }
#if SHADER != SHADER_SHADERTOY
	    fragColor = vec4(1.*uv.x, green, 0.*uv.y,1.);
#else
        fragColor = color;    
#endif
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