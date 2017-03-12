//#version 150
//https://www.shadertoy.com/view/ltGSzz
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

// Bitmap font is based on Hamneggs's https://www.shadertoy.com/view/4dtGD2
// Tessellation code is based on soma_arc's https://www.shadertoy.com/view/4t3SDs

#define _f float
const lowp _f CH_C    = _f(0xe111e), CH_E    = _f(0xf171f), CH_F    = _f(0xf1711),
              CH_I    = _f(0xf444f), CH_L    = _f(0x1111f), CH_N    = _f(0x9bd99),
              CH_O    = _f(0x69996), CH_P    = _f(0x79971), CH_R    = _f(0x79759),
              CH_S    = _f(0xe1687), CH_T    = _f(0xf4444);
const lowp vec2 MAP_SIZE = vec2(4,5);
#undef flt
const lowp vec2 charSize = vec2(.5, .5);
const lowp vec2 charPos = vec2(0.45, 0.25);
const lowp vec2 rectSize = vec2(1.3333, 1.);
const float minxRange = -9.0 * rectSize.x;
const float maxxRange = 10.0 * rectSize.x;
const vec4 black = vec4(0,0,0,0);
// CEFILNOPRST
const vec4 color_c = vec4(0.850,0.862,0.898,1.0);
const vec4 color_e = vec4(0.839,0.803,0.764,1.0);
const vec4 color_f = vec4(0.803,0.796,0.705,1.0); 
const vec4 color_i = vec4(0.823,0.831,0.854,1.0); 
const vec4 color_l = vec4(0.843,0.835,0.788,1.0); 
const vec4 color_n = vec4(0.760,0.764,0.705,1.0); 
const vec4 color_o = vec4(0.717,0.741,0.741,1.0); 
const vec4 color_p = vec4(0.850,0.886,0.905,1.0); 
const vec4 color_r = vec4(0.803,0.811,0.807,1.0); 
const vec4 color_s = vec4(0.803,0.827,0.768,1.0); 
const vec4 color_t = vec4(0.772,0.760,0.694,1.0); 

float getBit( in float map, in float index )
{
    return mod( floor( map*exp2(-index) ), 2.0 );
}
float drawChar( in float char, in vec2 pos, in vec2 size, in vec2 uv )
{
    uv-=pos;
    uv /= size;
    float res;
    res = step(0.0,min(uv.x,uv.y)) - step(1.0,max(uv.x,uv.y));
    uv *= MAP_SIZE;
    res*=getBit( char, 4.0*floor(uv.y) + floor(uv.x) );
    return clamp(res,0.0,1.0);
}
vec4 getColor(float opCount, vec2 pos) {
    float chr = 0.0; 
    float which=mod(opCount,17.0);    
    if (which==0.0 || which==11.0) {
        chr = drawChar( CH_S, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_s; }
    } else if (which==1.0 || which==6.0 || which==15.0) {
        chr = drawChar( CH_I, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_i; }
    } else if (which==2.0) {
        chr = drawChar( CH_L, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_l; }
    } else if (which==3.0) {
        chr = drawChar( CH_O, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_o; }
    } else if (which==4.0 || which==10.0) {
        chr = drawChar( CH_P, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_p; }
    } else if (which==5.0 ) {
        chr = drawChar( CH_R, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_r; }
    } else if (which==7.0) {
        chr = drawChar( CH_N, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_n; }
    } else if (which==8.0 || which==14.0) {
        chr = drawChar( CH_C, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_c; } 
    } else if (which==9.0 || which==13.0) {
        chr = drawChar( CH_E, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_e; }
    } else if (which==12.0) {
        chr = drawChar( CH_F, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_f; }
    } else if (which==16.0) {
        chr = drawChar( CH_T, charPos, charSize, pos);
        if (chr >0.0) { return black; } else { return color_t; }
    }
}

const int MAX_ITERATIONS = 100;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ratio = iResolution.x / iResolution.y / 2.0;
    
    vec2 pos = (fragCoord.xy / iResolution.yy ) - vec2(ratio, 0.5);
    pos *= 15.0;
    pos.y += 0.5;
    pos.x +=0.65;
    if (pos.x < minxRange || pos.x > maxxRange ) {
        fragColor = black;
        return;
    }
    
    bool isFund = true;
    float opCount = 0.;
    for(int i = 0 ; i < MAX_ITERATIONS ; i++){
        isFund = true;
        if(pos.x < 0. || rectSize.x < pos.x){
            opCount += abs(floor(pos.x / rectSize.x));
            pos.x = mod(pos.x, rectSize.x);
            isFund = false;
        }
        if(pos.y < 0. || rectSize.y < pos.y){
            opCount += abs(floor(pos.y / rectSize.y));
            pos.y = mod(pos.y, rectSize.y);
            isFund = false;
        }
        if(isFund) break;
    }   
    if (isFund==false) {
        fragColor = black;
        return;
    }
    fragColor = getColor(opCount,pos);
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