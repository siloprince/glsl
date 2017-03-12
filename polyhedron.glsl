//#version 150
//https://www.shadertoy.com/view/4dXyD7
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
// Created by David Crooks
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// An exercise in platonic geometry with signed distance funcions.
// https://en.wikipedia.org/wiki/Platonic_solid
// SDF
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
// http://www.alanzucconi.com/2016/07/01/signed-distance-functions/

#define TWO_PI 6.283185
#define PI 3.14159265359

struct Ray {
   vec3 origin;
   vec3 direction;
};
struct LightColor {
	vec3 diffuse;
	vec3 specular;
};  
struct Material {
    LightColor  color;
    float shininess;
    float mirror;
    float refractiveIndex;
    float opacity;  
};
struct MapValue {
    float 	  signedDistance;
    Material  material;
};
struct Trace {
    float    dist;
    vec3     p;
    vec3 normal;
    Ray 	 ray;
    Ray reflection;
    Material material;
    bool hit;
};
struct PointLight {
    vec3 position;
    LightColor color;
};  
struct DirectionalLight {
    vec3 direction;
    LightColor color;
};
PointLight  light1,light2;
Material whiteMat,blueMat,yellowMat;
vec3 rayPoint(Ray r,float t) {
 	return r.origin +  t*r.direction;
}
MapValue addObjects(MapValue d1, MapValue d2 )
{
    if (d1.signedDistance<d2.signedDistance) {
    	return    d1 ;
    }
    else {
    	return d2;
    }
}
mat3 rotationMatrix(vec3 axis, float angle)
{
    //http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s, 
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

float  plane(vec3 p, vec3 origin, vec3 normal){ 
   return dot(p - origin,normal);   
}
MapValue plane(vec3 p, vec3 origin, vec3 normal , Material m ){
 
  MapValue mv;
  mv.material = m;
   
  mv.signedDistance = plane(p,origin,normal);
  return mv;
}

MapValue xzPlane( vec3 p ,float y, Material m)
{
  MapValue mv;
  mv.material = m;
  mv.signedDistance = p.y - y;
  return mv;
}

//////////////////////////////////////////////////////////
//---------------Platonic solids -----------------------//
//////////////////////////////////////////////////////////

//cube by iq
MapValue cube( vec3 p, float d , Material m)
{
  MapValue mv;
  mv.material = m;
 
  mv.signedDistance = length(max(abs(p) -d,0.0));
  return mv; 
}

MapValue tetrahedron(vec3 p, float d, Material m) {
    
  MapValue mv;
  mv.material = m;
 
  float dn =1.0/sqrt(3.0);
  
   //The tetrahedran is the intersection of four planes:
    float sd1 = plane(p,vec3(d,d,d) ,vec3(-dn,dn,dn)) ; 
    float sd2 = plane(p,vec3(d,-d,-d) ,vec3(dn,-dn,dn)) ;
 	float sd3 = plane(p,vec3(-d,d,-d) ,vec3(dn,dn,-dn)) ;
 	float sd4 = plane(p,vec3(-d,-d,d) ,vec3(-dn,-dn,-dn)) ;
  
    //max intersects shapes
    mv.signedDistance = max(max(sd1,sd2),max(sd3,sd4));
  return mv; 
}
float  doubleplane(vec3 p, vec3 origin, vec3 normal){ 
   return max(dot(p - origin,normal),dot(-p - origin,normal));   
}

MapValue polyhedron(vec3 p, float d, Material m) {
    
   //Alternative construction of octahedran.
   //The same as for a terahedron, except intersecting double planes (the volume between two paralell planes). 
    
    MapValue mv;
    mv.material = m;
 
    float dn =1.0/sqrt(3.0);
    float sd1 = doubleplane(p,vec3(d,d,d) ,vec3(-dn,dn,dn)) ; 
    float sd2 = doubleplane(p,vec3(d,-d,-d) ,vec3(dn,-dn,dn)) ;
 	float sd3 = doubleplane(p,vec3(-d,d,-d) ,vec3(dn,dn,-dn)) ;
 	float sd4 = doubleplane(p,vec3(-d,-d,d) ,vec3(-dn,-dn,-dn)) ;
    
    mv.signedDistance = max(max(sd1,sd2),max(sd3,sd4));
  return mv; 
}

//////////////////////////////////////////////////////////////


void setMaterials() {
    float t  = iGlobalTime;
    float s = 0.4*(1.0+sin(t));
    vec3 specular = vec3(0.3); 
    float shininess = 16.0;
    whiteMat = Material(LightColor(vec3(1.0),vec3(1.0)) ,shininess ,0.75,1.0,1.0);
    blueMat = Material(LightColor(vec3(0.3,0.3,0.75),vec3(0.3,0.3,1.0)) ,shininess ,0.75,1.0,1.0);
    yellowMat = Material(LightColor(vec3(0.8,0.8,0.4),vec3(0.9,0.9,0.2)) ,shininess ,0.75,1.0,1.0);
}


vec3 orbit(float t){
    return vec3(0.,0.25,0.);
}

/////////////////////Map the sceane/////////////////////////////////////////////


MapValue map(vec3 p){
   float t  = iGlobalTime;
   mat3 R = rotationMatrix(orbit(0.2*t),0.67*t);
   float r = 0.8; 
   vec3 pos = R*(p + r*orbit(t+ TWO_PI*0.2));
   MapValue objects = polyhedron(pos,0.25,whiteMat);
   //objects = addObjects(objects,cube( R*(p + r*orbit(t)),0.25,whiteMat));

   //add a floor and a cieling
  // objects = addObjects(objects,xzPlane(p,-0.75,blueMat));
    
   return objects;
}


///////////////////////////Raytracing////////////////////////////////////////


vec3 calculateNormal(vec3 p) {
    float epsilon = 0.001;
    
    vec3 normal = vec3(
                       map(p +vec3(epsilon,0,0)).signedDistance - map(p - vec3(epsilon,0,0)).signedDistance,
                       map(p +vec3(0,epsilon,0)).signedDistance - map(p - vec3(0,epsilon,0)).signedDistance,
                       map(p +vec3(0,0,epsilon)).signedDistance - map(p - vec3(0,0,epsilon)).signedDistance
                       );
    
    return normalize(normal);
}

Trace castRay(in Ray ray, float maxDistance){
    float dist = 0.01;
    float presicion = 0.001;
	vec3 p;
    MapValue mv;
    bool hit = false;
    
    for(int i=0; i<64; i++){
    	p = rayPoint(ray,dist);
       	mv = map(p);
         dist += 0.5*mv.signedDistance;
        if(mv.signedDistance < presicion)
        {
          hit = true; 
            break;
        } 
         if(dist>maxDistance) break;
       
    }

    return Trace(dist,p,p,ray,ray,mv.material,hit);
}

Trace traceRay(in Ray ray, float maxDistance) {
    Trace trace = castRay(ray,maxDistance);
    trace.normal = calculateNormal(trace.p);

    return trace;
}

Ray cameraRay(vec3 viewPoint, vec3 lookAtCenter, vec2 p , float d){ 
	vec3 v = normalize(lookAtCenter -viewPoint);
    
    vec3 n1 = cross(v,vec3(0.0,1.0,0.0));
    vec3 n2 = cross(n1,v);  
        
    vec3 lookAtPoint = lookAtCenter + d*(p.y*n2 + p.x*n1);
                                    
    Ray ray;
                    
    ray.origin = viewPoint;
   	ray.direction =  normalize(lookAtPoint - viewPoint);
    
    return ray;
}

vec3 diffuseLighting(in Trace trace, vec3 lightColor,vec3 lightDir){
    float lambertian = max(dot(lightDir,trace.normal), 0.0);
  	return  lambertian * trace.material.color.diffuse * lightColor; 
}

vec3 pointLighting(in Trace trace, PointLight light){
    vec3 lightDir = light.position - trace.p;
	float d = length(lightDir);
  	lightDir = normalize(lightDir);
   
  	vec3 color =  diffuseLighting(trace, light.color.diffuse, lightDir);

    float  attenuation = 1.0 / (1.0 +  0.1 * d * d);
    return  color;
}

vec3 directionalLighting(Trace trace, DirectionalLight light){

    vec3 color =  diffuseLighting(trace, light.color.diffuse, light.direction);

    return  color;
}


void setLights(){
  	float  time = iGlobalTime;
    vec3 specular = vec3(1.0);
  	light1 = PointLight(vec3(cos(1.3*time),1.0,sin(1.3*time)),LightColor( vec3(1.0),specular));
  	light2 = PointLight(vec3(0.7*cos(1.6*time),1.1+ 0.35*sin(0.8*time),0.7*sin(1.6*time)),LightColor(vec3(1.0),specular)); 
} 


vec3 lighting(in Trace trace){
    vec3 color = vec3(0.01,0.01,0.2);//ambient color     
	color += pointLighting(trace, light1);
	color += pointLighting(trace, light2) ;

    return color;
}

float rayDistance(Ray r,vec3 p){
    vec3 v = r.origin - p;
    return length(v - dot(v,r.direction)*r.direction);
}

vec3 render(vec2 p){
    vec3 viewpoint = vec3(-1.0,1.9,-2.3);
    
    vec3 lookAt = vec3(0.0,-0.15,0.0);
    
  	Ray ray = cameraRay(viewpoint,lookAt,p,2.4);
    vec3 color = vec3(0.0);
    float frac = 1.0;
   
    float d = 0.0;
    
    float maxDistance = 7.0;
    for(int i = 0; i<2; i++) {
        Trace trace = traceRay(ray,maxDistance);
        
 		if(i==0) d = trace.dist;
        maxDistance -= trace.dist;
    	color += lighting(trace)*(1.0 - trace.material.mirror)*frac;
        if(!trace.hit) break;
        
        if(frac < 0.1 || maxDistance<0.0) break;
    }
   	
    
   
   	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = (fragCoord - 0.5*iResolution.xy) / iResolution.y;
    
  	setLights();
    setMaterials();
    
   	vec3 colorLinear =  render(p);
    float screenGamma = 2.2;
    vec3 colorGammaCorrected = pow(colorLinear, vec3(1.0/screenGamma));
	fragColor = vec4(colorGammaCorrected,1.0);
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