//#define shadertoy https://www.shadertoy.com/view/MtVXDz
#ifndef shadertoy
#define texture vec4(0);
#endif
#define L for(int i=0;i<17;i++)
#define V vec4

void mainImage( out vec4 c, in vec2 w )
{
	V p = V(w,0.,1.);
	
	float v=.0, f, r[17];
    V s=V(2,2,1,0);

	L
		r[i]=0.;
	
	r[0]=p.x+p.y;
	r[1]=p.y;
	
	L{
		f=-2.*floor(r[i]/2.)/s[0];
		for(int j=0;j<3;j++)
			r[i+j]+=f*s[j];
        
	}
	
	L
		v+=mod(r[i],2.)*exp2(float(i));
    v/=exp2(17.);
    

	c = V(v);
  
}

#ifndef shadertoy
void main(void)
{
    vec4 fragColor = vec4(0);
    mainImage(fragColor,gl_FragCoord.xy);
    gl_FragColor = fragColor;
}
#endif 