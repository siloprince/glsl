//#version 150
//https://www.shadertoy.com/view/MtVXRh
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

precision mediump float;

// from Syntopia http://blog.hvidtfeldts.net/index.php/2015/01/path-tracing-3d-fractals/
vec2 rand2n(vec2 co, float sampleIndex) {
	vec2 seed = co * (sampleIndex + 1.0);
	seed+=vec2(-1,1);
	// implementation based on: lumina.sourceforge.net/Tutorials/Noise.html
	return vec2(fract(sin(dot(seed.xy ,vec2(12.9898,78.233))) * 43758.5453),
                 fract(cos(dot(seed.xy ,vec2(4.898,7.23))) * 23421.631));
}

const float EPSILON = 0.001;

const float NO_HIT = 9999999.;

const int MTL_PLANE = 0;
int g_mtl = -1;

vec2 crosspoint (vec2 c1,vec2 c2, float cr1, float cr2) {

        float c1c2 = distance(c2, c1);
        float c1mid = (cr1*cr1 -cr2*cr2 +c1c2*c1c2)/(2.*c1c2);
        vec2  mid = mix(c1,c2,c1mid/c1c2);
        float pmid = sqrt(cr1*cr1-c1mid*c1mid);
        vec2  dir = c1-mid;
        vec2 vec = vec2(-1.*dir.y, dir.x);
        return (mid+ vec*(pmid/c1mid));
}
vec4 intersectPlane(vec3 p, vec3 n, 
                    vec3 rayOrigin, vec3 rayDir, vec4 isect){
    float d = -dot(p, n);
    float v = dot(n, rayDir);
    float t = -(dot(n, rayOrigin) + d) / v;
    if(EPSILON < t && t < isect.x){
        g_mtl = MTL_PLANE;
    	return vec4(t, n);
    }
    return isect;
}


vec2 circleInverse(vec2 pos, vec2 circlePos, float circleR){
	return ((pos - circlePos) * circleR * circleR)/(length(pos - circlePos) * length(pos - circlePos) ) + circlePos;
}

bool revCircle = false;
bool revCircle2 = false;
vec2 cPos1 = vec2(0);
vec2 cPos2 = vec2(0);
float cr1 = 0.;
float cr2 = 0.;
const int ITERATIONS = 50;
bool g_outer = false;
vec2 g_pos = vec2(0);
vec2 g_avepos = vec2(0);

vec2 reverseStereoProject(vec3 pos){
	return vec2(pos.x / (1. - pos.z), pos.y / (1. - pos.z));
}

vec3 getCircleFromSphere(vec3 upper, vec3 lower){
	vec2 p1 = reverseStereoProject(upper);
    vec2 p2 = reverseStereoProject(lower);
   	return vec3((p1 + p2) / 2., distance(p1, p2)/ 2.); 
}

const float pi = 4.*atan(1.,1.);

vec2 rotate(vec2 xy, float theta) {
    vec2 pos = vec2(0);
    pos.x = xy.x*cos(theta) - xy.y*sin(theta);
     pos.y = xy.x*sin(theta) + xy.y*cos(theta);
    return pos;    
}

const float SMALL=0.02;
vec2 _translate(vec2 xy, float time) {
    if (time>1.0-SMALL) {
        return xy;
    }    
     xy *= vec2(1, -1);
             
    float theta = mix(atan(sqrt(2.),1.), 2.*atan(1.,1.)*0.99, mod(time,1.));
    vec3 va = vec3(0.,cos(theta),  sin(theta));
    vec3 vb = vec3(0.,cos(theta), -sin(theta));
    vec3 c1 = getCircleFromSphere(va,  vb);
    
     return circleInverse(xy, c1.xy, c1.z);
    
}
vec2 translate(vec2 xy, float time) {

    float theta = 0.; 
    if (abs(1.-time) < SMALL) {
        return xy;
    }
    if (abs(time) < SMALL) {
        return xy;
    }    
     xy *= vec2(1, -1);  
    float data = mod(-abs(time),1.);
     theta =  2.*(-atan(-data,1.));
    vec3 va = vec3(0.,cos(theta),  sin(theta));
    vec3 vb = vec3(0.,cos(theta), -sin(theta));
    vec3 c1 = getCircleFromSphere(va,  vb);
    
     return circleInverse(xy, c1.xy, c1.z);
    
}
vec2 move(vec2 pos) {
	float time=iGlobalTime;
    
    vec2 uv = 2.*iMouse.xy /iResolution.y-vec2(iResolution.x/iResolution.y,1.);
    
   pos = rotate(pos, pi/2.);
   pos = translate(pos,0.3);
    pos = rotate(pos,  -time*0.35);
    
    vec2 cro = crosspoint(cPos1, cPos2, cr1, cr2); 
    float dist = 1.-0.57;// length(cro);
    pos = translate(pos,dist);
   pos = rotate(pos, pi/4.);
    //pos = translateByDistance(pos,0.5*length(uv));
    //pos = rotate(pos, atan(uv.y, uv.x));
     //dist = length(uv);
     //pos = translate(pos,dist);
     return pos;
}

int IIS(vec2 pos){
    //if(length(pos) > 1.) return 0;

    bool fund = true;
    int invCount = 1;
	for(int i = 0 ; i < ITERATIONS ; i++){
        fund = true;
        if (pos.x < 0.){
            pos *= vec2(-1, 1);
            invCount++;
	       	fund = false;
        }
        if(pos.y < 0.){
            pos *= vec2(1, -1);
            invCount++;
            fund = false;
        }
        if(revCircle){
            if(distance(pos, cPos1) > cr1 ){
                pos = circleInverse(pos, cPos1, cr1);
                invCount++;
                fund = false;
            }
        }else{
        	if(distance(pos, cPos1) < cr1 ){
                pos = circleInverse(pos, cPos1, cr1);
                invCount++;
                fund = false;
            }
        }
        
        if(revCircle2){
            if(distance(pos, cPos2) > cr2 ){
                pos = circleInverse(pos, cPos2, cr2);
                invCount++;
                fund = false;
            }
        }else{
        	if(distance(pos, cPos2) < cr2 ){
                pos = circleInverse(pos, cPos2, cr2);
                invCount++;
                fund = false;
            }
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

vec4 getIntersection(vec3 eye, vec3 ray){
	vec4 isect = vec4(NO_HIT);
    isect = intersectPlane(vec3(0, 0., 0.), vec3(0, 1, 0),
                            eye, ray, isect);
    
    return isect;
}

vec4 getNyanCatColor( vec2 p, float time )
{
	p = clamp(p,0.0,1.0);
    p.x = mix(.072, .88, p.x);
    p.y = mix(0.23, 0.765, p.y);
	p.x = p.x*40.0/256.0;
	p.y = 0.5 + 1.2*(0.5-p.y);
	p = clamp(p,0.0,1.0);
	float fr = floor( mod( 20.0*time, 6.0 ) );
	p.x += fr*40.0/256.0;
	return texture( iChannel0, p );
}

int calc(const float width, const float height, const vec2 coord){
    float ratio = width/height;
    vec2 pos = vec2(0);
    pos.y = mix(-ratio, ratio, coord.x/width);
    pos.x = mix(-1., 1., coord.y/height);
    return IIS(move(pos));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	float time = iGlobalTime;  
    float range = mod(0.16*time,1.);
    if (range>.5) {
        range = 1.-range;
    }
    range = 0.;
    float bendX = .6*range;
    mat3 xRotate = mat3(1, 0, 0,
                        0, cos(bendX), -sin(bendX),
                        0, sin(bendX), cos(bendX));
    float bendY = 0.0;
    mat3 yRotate = mat3(cos(bendY), 0, sin(bendY),
                         0, 1, 0,
                         -sin(bendY), 0, cos(bendY));
    
    float x = 1./sqrt(3.);    
	float y = 1./sqrt(3.);    
    vec3 c1 = getCircleFromSphere(
        vec3(0, y, sqrt(1. - y * y))* xRotate,
        vec3(0, y, -sqrt(1. - y * y))* xRotate);
    vec3 c2 = getCircleFromSphere(
        vec3(x, 0, sqrt(1. - x * x)) * yRotate,
        vec3(x, 0, -sqrt(1. - x * x)) * yRotate);

	cr1 = c1.z;
    cr2 = c2.z;
    cPos1 = c1.xy;
    cPos2 = c2.xy;
    if(y > cPos1.y){
    	revCircle = true;
    }
	if(x > cPos2.x){
    	revCircle2 = true;
    }
    float dist = 1.8;
    vec3 eye = vec3(0, dist, 0);
    vec3 target = vec3(0);
    vec3 up = vec3(1, 0, 0);
    float fov = 60.;
    
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
        float red = mod(3.15*g_pos.x,2.);
        float blue = mod(3.15*(1.-bendX*1.2)*g_pos.y,2.);
         if (even*3. > SAMPLE_NUM) {
            blue = .5*(1.+blue);
    	} else if (odd*3. > SAMPLE_NUM) {
            blue = .5*(1.-blue);
        }
    
    	vec2 uv = vec2(blue,red);

#if SHADER != SHADER_SHADERTOY
	    fragColor = vec4(red,0.,blue,1.0);
#else
        fragColor = getNyanCatColor(uv,time);
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