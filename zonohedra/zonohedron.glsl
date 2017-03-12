//#version 150
//hhttps://www.shadertoy.com/view/ltVXDW
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

#define TRANSPILER 1
#if TRANSPILER == 0
const vec2 console = vec2(0);
# define dir  x*
#endif
const int n = 3;
const int m = n*(n-1)/2;
const int l = m*4;
vec3 vertices[2*l];
vec4 quad[m];
vec3 star[n];

vec3 project(float face[n], vec3 star[n]) {
        vec3 v = vec3(0);
        for(int i = 0; i < n; i++) {
                v += star[i]*face[i];
        }
        return v;
}
//unique sign for degenerate vertex (careful, will fail with more than 2 identical vertices)
float triSign(int i, int j, int k, vec3 star_i, vec3 star_j, vec3 star_k) {
        float ii = float(i);
        float jj = float(j);
        float kk = float(k);
        vec3 a = star_i + vec3(1., ii, ii*ii)*1e05;
        vec3 b = star_j + vec3(1., jj, jj*jj)*1e05;        vec3 c = star_k + vec3(1., kk, kk*kk)*1e05;
        return sign(dot(cross(a,b),c));
}
void zonohedron(vec3 star[n]) {
        star[0] = vec3(2.,0.,0.);
        star[1] = vec3(0.,1.,0.);
        star[2] = vec3(0.,0.,1.);        //star[3] = vec3(0);
        //star[4] = vec3(0);
        float face[n];

        for(int i =0; i <n; i++) {
                for(int j =0; j <n; j++) {
                        if (j<i+1) {
                                continue;
                        }
                        vec3 normal = cross(star[i],star[j]);
                        for(int k =0; k <n; k++) {
                                if(k ==i || k ==j) {
                                        face[k] = 0.;
                                } else {
                                        face[k] = sign(dot(normal, star[k]));
                                        //in case of degenerate faces, this will decompose it correctly. (why? I just guessed)
                                       if(face[k] ==0.) {
                                                face[k] = triSign(i, j, k, star[i],star[j],star[k]);
                                        }
                                }
                        }
                        //find 4 vertices

                        face[i] = -1.;
                        face[j] = -1.;
                        vertices[4*(j-i-1+i*(-i+2*n-1)/2)+0] = project(face, star);
                        face[i] = 1.;
                        vertices[4*(j-i-1+i*(-i+2*n-1)/2)+1] = project(face, star);
                        face[j] = 1.;
                        vertices[4*(j-i-1+i*(-i+2*n-1)/2)+2] = project(face, star);
                        face[i] = -1.;
                        vertices[4*(j-i-1+i*(-i+2*n-1)/2)+3] = project(face, star);
                }
        }
        for (int i =0; i< l; i++) {
               vec3 v = vertices[l-i-1];
               vertices[i+l] = -1.*v;
        }
        float q;
        for (int i =0; i< 2*m; i++) {
                q = float(i)*4.;
                quad[i] = vec4(q+0., q+1., q+2., q+3.);
        }
}


void mainImage( out vec4 c, in vec2 w ){
        zonohedron(star);
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
