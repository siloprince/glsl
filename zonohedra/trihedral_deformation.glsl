//#version 150
//https://www.shadertoy.com/view/ltKSDd
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

const int n = 4;
#define TRANSPILER 0

#if TRANSPILER == 1
 const int V =  String.fromCharCode(118);
 const int F =  String.fromCharCode(102);
 const int WSP =  String.fromCharCode(32);
 const vec2 iResolution = vec2(1.,1.);
 const float iGlobalTime = 0.;
#endif

void objVertex(vec3 v) {
#if TRANSPILER == 1
  console.log(V+WSP+v.x+WSP+v.y+WSP+v.z);
#endif
}

void objFace(vec4 f) {
#if TRANSPILER == 1
  int a = f.x;
  int b = f.y;
  int c = f.z;
  int d = f.w;
  console.error(F+WSP+a+WSP+b+WSP+c+WSP+d);
#endif
}

void logIntN(int dup[n]) {
#if TRANSPILER == 1
  console.log(dup);
#endif
}

 const int m = n*(n-1)/2;
 const int l = m*4;
 vec3 vertices[2*l];
 vec4 quad[m];
 highp vec3 star[n];
const highp float PI = 4.* atan(1.,1.);


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
         vec3 b = star_j + vec3(1., jj, jj*jj)*1e05;
         vec3 c = star_k + vec3(1., kk, kk*kk)*1e05;
         return sign(dot(cross(a,b),c));
 }

 void zonohedron(vec3 star[n]) {
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
         for (int i =0; i< 2*l; i++) {
                vec3 v = vertices[i];
                objVertex(v);
         }
         float q;
         for (int i =0; i< 2*m; i++) {
                q = float(i)*4.;
                quad[i] = vec4(q+0., q+1., q+2., q+3.);
                objFace(quad[i]);
         }
}

void seven (out vec3 star[n], float t) {
  float base = 2.*PI/float(n);
  float theta = 0.;
  float cp = cos(t);
  float sp = sin(t);
  for (float i=0.;i<float(n);i++) {
    theta = base*i;
    star[int(i)] = vec3( cp*cos(theta), cp*sin(theta), sp);
  }
 }
 void four0 (out highp vec3 star[n], highp  vec4 param) {
    highp float s = param[0];
    highp float t = param[1];
    highp float cs = cos(s);
    highp float ss = sin(s);
    highp float cst = cos(s+t);
    highp float sst = sin(s+t);
    highp float csT = cos(-s+t);
    highp float ssT = sin(-s+t);
    star[0]= vec3( cs, 0., ss);
    star[1]= vec3(-cs, 0., ss);
    star[2]= vec3(0., cst, sst);
    star[3]= vec3(0., csT, ssT);
  }
  mat3 idmat3 () {
    return mat3(
      1., 0., 0.,
      0., 1., 0.,
      0., 0., 1.
    );
  }
  highp mat3 tensorproduct (highp vec3 u) {
    return mat3(
      u.x * u.x, u.x*u.y, u.x*u.z,
      u.y * u.x, u.y*u.y, u.y*u.z,
      u.z * u.x, u.z*u.y, u.z*u.z
    );
  }
   highp mat3 crossmatrix (highp vec3 u) {
    return mat3(
        0.,  u.z, -u.y,
      -u.z,   0.,  u.x,
       u.y, -u.x, 0.
    );
  }
  highp mat3 rotateAroundAxis(highp vec3 n, highp float theta) {
    highp float x = n.x;
    highp float y = n.y;
    highp float z = n.z;
    highp float c = cos(theta);
    highp float oc = 1.-c;
    highp float s = sin(theta);
    // https://en.wikipedia.org/wiki/Rotation_matrix
    return c * idmat3() + s * crossmatrix(n) + oc * tensorproduct(n);
  }
  vec3 m3mul (highp mat3 a, highp vec3 v) {
    // issue: transpiler problem
    highp vec3 a0 = a[0];
    highp vec3 a1 = a[1];
    highp vec3 a2 = a[2];
    return vec3 (
      a0[0] *v.x + a1[0] *v.y + a2[0] *v.z,
      a0[1] *v.x + a1[1] *v.y + a2[1] *v.z,
      a0[2] *v.x + a1[2] *v.y + a2[2] *v.z
    );
  }
  void four1 (out highp vec3 star[n], highp vec4 param) {
    highp float s = param[0];
    highp float t = param[1];
    highp float cs = cos(s);
    highp float ss = sin(s);
    highp float ct = cos(t);
    highp float st = sin(t);
    star[0]=vec3( cs, 0., ss);
    star[1]=vec3(-cs, 0., ss);
	highp mat3 rot0 = rotateAroundAxis(star[0],t);
 	star[2] = m3mul(rot0,star[1]);
  	highp mat3 rot1 = rotateAroundAxis(star[1],-t);
 	star[3] = m3mul(rot1,star[0]);
}
void four2 (out highp vec3 star[n], highp vec4 param) {
  highp float s = param[0];
  highp float t = param[1];
  highp float cs = cos(s);
  highp float ss = sin(s);
  highp float ct = cos(t);
  highp float st = sin(t);
  star[0]=vec3( cs, 0., ss);
  star[1]=vec3(-cs, 0., ss);
  
  highp mat3 rot0 = rotateAroundAxis(star[0],t);
  star[2] = m3mul(rot0,star[1]);
  
  highp mat3 rot1 = rotateAroundAxis(star[1],t);
  star[3] = m3mul(rot1,star[0]);
}
void four3 (out highp  vec3 star[n], highp vec4 param) {
  highp float s = param[0];
  highp float t = param[1];
  highp float cs = cos(s);
  highp float ss = sin(s);
  highp float ct = cos(t);
  highp float st = sin(t);
  star[0]=vec3( cs, 0., ss);
  star[1]=vec3(-cs, 0., ss);
  star[2]=vec3( ct*cs, st*cs, ss);
  star[3]=vec3(-ct*cs,-st*cs, ss);
}
void four4 (out vec3 star[n], vec4 param) {
  float s = param[0];
  float t = param[1];
  float cs = cos(s);
  float ss = sin(s);
  float ct = cos(t);
  float st = sin(t);
  star[0]=vec3( cs,  0., ss);
  star[1]=vec3(-cs,  0., ss);
  star[2]=vec3( 0.,  ct, st);
  star[3]=vec3( 0., -ct, st);
}
void four5 (out vec3 star[n], vec4 param) {
  float s = param[0];
  float t = param[1];
  float cs = cos(s);
  float ss = sin(s);
  float ct = cos(t);
  float st = sin(t);
  star[0]=vec3( 1.,  0., 0.);
  star[1]=vec3( cs,  0., ss);
  star[2]=vec3( cs, st*ss, ct*ss);
  star[3]=vec3( cs,-st*ss, ct*ss);
}
void four6 (out vec3 star[n], vec4 param) {
  float s = param[0];
  float t = param[1];
  float cs = cos(s);
  float ss = sin(s);
  float c3 = cos(2.*PI/3.);
  float s3 = sin(2.*PI/3.);
  float ct = cos(t);
  float st = sin(t);
  star[0]=vec3( cs, 0.,    ss);
  star[1]=vec3( cs, s3*ss, c3*ss);
  star[2]=vec3( cs,-s3*ss, c3*ss);

  mat3 rot0 = rotateAroundAxis(star[0],t);
  star[3] = m3mul(rot0,star[1]);
}
void four7 (out vec3 star[n], vec4 param) {
  float s = param[0];
  float t = param[1];
  float cs = cos(s);
  float ss = sin(s);
  float c3 = cos(2.*PI/3.);
  float s3 = sin(2.*PI/3.);
  float ct = cos(t);
  float st = sin(t);
  star[0]=vec3( cs, 0., ss);
  star[1]=vec3( cs, s3*ss, c3*ss);
  star[2]=vec3( cs,-s3*ss, c3*ss);
  star[3]=vec3(ct, 0., st);
}
void five (out vec3 star[n], vec4 param) {
  float base = 2.*PI/float(n);
  float theta = 0.;
  float s = param[0];
  float t = param[1];
  float cs = cos(s);
  float ss = sin(s);
  float ct = cos(t);
  float st = sin(t);
  star[0]=vec3( cs, 0., ss);
  star[1]=vec3(-cs, 0., ss);
  star[2]=vec3( cs*ct, cs*st, ss);
  star[3]=vec3(-cs*ct,-cs*st, ss);
}
highp float angle(highp vec3 a,highp  vec3 b) {
   highp float c= abs(acos(dot(a,b)/(length(a)*length(b))))*180./PI;
   return  c;
}
vec4 dupcheck(highp vec3 star[n]) {
 highp  float base = 7.;
  int dup[n];
  for (int k=0;k<n;k++) {
    dup[k]=-1;
  }
  for (int i=0;i<n;i++) {
    for (int j=0;j<n;j++) {
      if (j<=i) {
        continue;
      }
      highp  float a = angle(star[i],star[j]);
      if (a >= 90.) {
         a = 180.-a;
      }
      a *= base;
      int b = int(floor(a));
      bool found=false;
      int last=-1;
      for (int k=0;k<n;k++) {
        if (dup[k]==-1) {
           last=k;
           break;
        } else if (dup[k]==b) {
           last=k;
           found = true;
           break;
        }
      }
      if (!found) {
        if (last==-1) {
          return vec4(0);
        }
        for (int k=0;k<n;k++) {
          if (k==last) {
            dup[k] = b;
            break;
          }
        }
      }
    }
  }
  int last=n;
  for (int k=0;k<n;k++) {
    if (dup[k]==-1) {
       last=k;
       break;
    }
  }
  logIntN(dup);
  float rgb0 = float(dup[0])/(90.*base);
  float rgb1 = float(dup[1])/(90.*base);
  float rgb2 = float(dup[2])/(90.*base);   
  if (last==3) {
      if ((dup[0]>dup[1])&&(dup[1]>dup[2])) {
          return vec4(rgb0,rgb1,rgb2,1.);
      }
      if ((dup[1]>dup[2])&&(dup[2]>dup[0])) {
          return vec4(rgb1,rgb2,rgb0,1.);
      }
      if ((dup[2]>dup[0])&&(dup[0]>dup[1])) {
          return vec4(rgb2,rgb0,rgb1,1.);
      }
      if ((dup[0]>dup[2])&&(dup[2]>dup[1])) {
          return vec4(rgb0,rgb2,rgb1,1.);
      }
      if ((dup[2]>dup[1])&&(dup[1]>dup[0])) {
          return vec4(rgb2,rgb1,rgb0,1.);
      }
      if ((dup[1]>dup[0])&&(dup[0]>dup[2])) {
          return vec4(rgb1,rgb0,rgb2,1.);
      }
  }
  if (last>3) {
      return vec4(1);
  }
    if(true) {
    if (last==1) {
  		return vec4(rgb0,rgb0,0.,1.);
    }
    if (last==2) {
        if (rgb0>rgb1) {
	  		return vec4(rgb0,rgb0,rgb1,1.);
        } else {
	  		return vec4(rgb1,rgb1,rgb0,1.);
        }
    }
    } else {
        if (last==1) {
  		return vec4(rgb0,0.,0.,1.);
    }
    if (last==2) {
        if (rgb0>rgb1) {
	  		return vec4(rgb0,rgb1,0.,1.);
        } else {
	  		return vec4(rgb1,rgb0,0.,1.);
        }
    }
    }
}
vec4 rgba_from_cmyk (vec4 cmyk) {
  float red =   1. - min(1., cmyk.x * (1. - cmyk.w) + cmyk.w);
  float green = 1. - min(1., cmyk.y * (1. - cmyk.w) + cmyk.w);
  float blue =  1. - min(1., cmyk.z * (1. - cmyk.w) + cmyk.w);
  return vec4(red,green,blue,1.);
}
void mainImage( out vec4 c, in vec2 w )
{
    
	vec2 uv;
    if (false) {
        uv =vec2(-1.*PI/4.,-1.*PI/4.)+ 2.5*PI* w.xy / iResolution.yy;
    } else {
        uv = PI* w.xy / iResolution.yy;
    }
        float s = uv.y; 
        float t = uv.x;
     //   four0(star,vec4(s,t,0.,0.));
   // four1(star,vec4(s,t,0.,0.));
       four2(star,vec4(s,t,0.,0.));
   //  four3(star,vec4(s,t,0.,0.));
 //     four4(star,vec4(s,t,0.,0.)); 
 // four5(star,vec4(s,t,0.,0.)); 
 //  four6(star,vec4(s,t,0.,0.)); 
  //  four7(star,vec4(s,t,0.,0.)); 
        vec4 col = dupcheck(star);  
    if(false) {
    float less = -0.05;
    float more = 0.05;
    if (( 0.38+less<col.z && col.z < 0.39+more && 0.61+less <col.y && col.y < 0.62+more && 0.74+less<col.x && col.x < 0.75+more)) {
       col = vec4(1.,0.,0.,1.);  
    } else
    if (( 0.38+less<col.z && col.z < 0.39+more && 0.61+less <col.y && col.y < 0.62+more && 0.76+less<col.x && col.x < 0.77+more)) {
       col = vec4(0.,1.,0.,1.); 
   } else 
    if (( 0.41+less<col.z && col.z < 0.42+more && 0.67+less <col.y && col.y < 0.68+more && 0.82+less<col.x && col.x < 0.83+more)) {
      col = vec4(0.,0.,1.,1.);
    } else
    if (( 0.32+less<col.z && col.z < 0.33+more && 0.6 +less<col.y && col.y < 0.61+more && 0.85+less<col.x && col.x < 0.86+more)) {
       col = vec4(1.,0.,1.,1.);
    } else 
    if (( 0.32+less<col.z && col.z < 0.33+more && 0.6+less <col.y && col.y < 0.61+more && 0.82+less<col.x && col.x < 0.83+more)) {
       col = vec4(1.,1.,0.,1.);
    } else {
         col.y = col.x;  col.z = col.x;      
    }
   }
      c = rgba_from_cmyk( vec4(sin(col.x),sin(col.z),0.,sin(col.y)));
#if TRANSPILER == 1     
    zonohedron(star);
#endif    
}
#if TRANSPILER == 1
vec4 c = vec4(0);
mainImage(c,vec2(PI/6., PI/3.));
#endif


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