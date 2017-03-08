//#define shadertoy https://www.shadertoy.com/view/MlKXzh
#ifndef shadertoy
#define texture vec4(0);
#endif
//by Jos Leys
//Rewrote by Yoshiaki Araki

void InvXAxis(inout vec3 z) {
    z.y *= -1.;
}
void InvYAxis(inout vec3 z) {
    z.x *= -1.;
}
void InvZAxis(inout vec3 z) {
    z.z *= -1.;
}
void InvCircle(inout vec3 z,vec3 center, float radius) {
    z -= center;
	z *=radius*radius/dot(z,z);
    z+=center; 
}
void TransA(inout vec3 z, vec3 pqr){
    InvCircle(z, vec3(0),1.);
    z -= pqr;     // loxodromic
    InvXAxis(z);
}
void TransB(inout vec3 z, vec3 center, vec3 xyz) {
    z.x += center.x;   
    z.x = mod(z.x, xyz.x);
    z.x -= center.x;      
}
void TransC(inout vec3 z, vec3 center, vec3 xyz) {
    z.z += center.z;   
    z.z = mod(z.z, xyz.z);
    z.z -= center.z;          
}
bool checkB(vec3 z, vec3 pqr) {
    // The dividing line based on the iteration of the point (1-b/2,a/2) ca, for calculation speed,
    // be replaced by an approximating line.
    // By trial and error, the following works fairly well: 
    float f = sign(pqr.x) ;
    float vx = z.x + pqr.x/2.;
    float va = pqr.y-1.95;
    float u =  f* sign(vx)* (1. - exp(-(7.2-(va)*15.)* abs(vx)));
    float w = (pqr.y * (2.+u) + va*u) /4.;
    return (z.y >= w);
}
void TransD(inout vec3 z, vec3 pqr){
    // Rotate by 180° about (b/2, a/2)
    InvYAxis(z);
    z -= pqr;
    InvXAxis(z);
}

float  JosKleinian(vec3 z, vec3 paramA, vec3 paramB, vec3 paramC)
{  
    float flag=0.;
	vec3 lz=z;
    vec3 llz=z; 
	for (int i = 0; i < 100 ; i++) 
	{
        vec3 center = (paramB+paramC)/2.+ vec3(abs(paramA.x),0., abs(paramA.z))*z.y/paramA.y;
		//Apply transformation B and Tessellate
        TransB(z,center,paramB);
		//Apply transformation C and Tessellate
        TransC(z,center,paramC);        
        
		//If above the separation line
        if (checkB(z,paramA)){            
			//Rotate by 180° about (b/2, a/2)
        	TransD(z,paramA);
        }
        
		//Apply transformation A
		TransA(z, paramA);
		
		//If the iterated points enters a 2-cycle , bail out.
        if(dot(z-llz,z-llz) < 1e-5) {break;}
        //if the iterated point gets outside z.y=0 and z.y=a
        if(z.y<0. || z.y> paramA.y ){flag=1.; break;}
        //Store prévious iterates
		llz=lz; lz=z;
	}
	return flag;
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
   	vec2 uv = fragCoord.xy / iResolution.yy;
    uv = mix(vec2(0.),vec2(2.),  uv);
    
	vec3 paramA = vec3(0.011278, 1.958591, 0.);
    vec3 paramB = vec3(2., 0.,0.);    
    vec3 paramC = vec3(0., 0.,0.);        
    vec3 xyz = vec3(uv.xy, 0.);
    float hit=JosKleinian(xyz,paramA, paramB,paramC);
    
    vec4 color = vec4(0);
    if (hit==1.) {
        color = vec4(1.);
    }
	fragColor = color;
#ifndef shadertoy
    gl_FragColor = fragColor;
#endif    
}

