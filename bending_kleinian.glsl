//#version 150
//https://www.shadertoy.com/view/MtVXzz
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

int calc(vec3 eye, vec3 ray){
    int d = 0;
    vec4 isect = getIntersection(eye, ray);
    if(isect.x != NO_HIT){
        vec3 intersection = eye + ray * isect.x;
        if(g_mtl == MTL_PLANE){
            d = IIS(intersection.xz);
        }
    }
	return d;
}

vec3 calcRay (const vec3 eye, const vec3 target,
              const vec3 up, const float fov,
              const float width, const float height, const vec2 coord){
  float imagePlane = (height * .5) / tan(radians(fov) * .5);
  vec3 v = normalize(target - eye);
  vec3 focalXAxis = normalize(cross(v, up));
  vec3 focalYAxis =  normalize(cross(v, focalXAxis ));
  vec3 center = v * imagePlane;
  vec3 origin = center - (focalXAxis * (width  * .5)) - (focalYAxis * (height * .5));
  return normalize(origin + (focalXAxis * coord.x) + (focalYAxis * (height - coord.y)));
}

vec2 reverseStereoProject(vec3 pos){
	return vec2(pos.x / (1. - pos.z), pos.y / (1. - pos.z));
}

vec3 getCircleFromSphere(vec3 upper, vec3 lower){
	vec2 p1 = reverseStereoProject(upper);
    vec2 p2 = reverseStereoProject(lower);
   	return vec3((p1 + p2) / 2., distance(p1, p2)/ 2.); 
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	float time = iGlobalTime;  
    float range = mod(0.16*time,1.);
    if (range>.5) {
        range = 1.-range;
    }
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
          
    	vec3 ray = calcRay(eye, target, up, fov,
        	               iResolution.x, iResolution.y,
            	           gl_FragCoord.xy + coordOffset);
          
    	int d = calc(eye, ray);
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
#if SHADER != SHADER_SHADERTOY
	    fragColor = vec4(red,0.,blue,1.0);
#else
         fragColor = getNyanCatColor(vec2(blue,red),time);    
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
