//
//  Shader.fsh
//  Rotozoomer
//
//  Created by Richard Smith on 16/05/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//


uniform sampler2D tex;
varying mediump vec2 TexCoord;
uniform mediump float a;
uniform mediump float z;
uniform mediump float offset;


//mediump mat2 rotationMatrix(mediump float angle)
//{
//    mediump float s = sin(angle);
//    mediump float c = cos(angle);
//    
//    return mediump mat2(c,-s,s,c);
//}
//
//
//void main()
//{
//    //gl_FragColor = vec4(1,0,0,0);
//    mediump mat2 rot = rotationMatrix(a)/z;
//    mediump vec2 offsetv = vec2(offset,0);
//	gl_FragColor = texture2D(tex, offsetv+TexCoord.xy * rot);
//}

void main()
{

    mediump float x = TexCoord.x * 10.0;
	mediump float y = TexCoord.y * 10.0;
//    mediump 	float c =   (0.5 + (0.5 * sin((x) * 16.0))
//            + 0.5 + (0.5 * sin((y) * 32.0))
//            + 0.5 + (0.5 * sin((x) * 16.0))
//            + 0.5 + (0.5 * sin(sqrt(x * x + y * y) * offset * 32.0))
//        ) / 4.0;

    
    
    mediump float v = 0.0;
    mediump vec2 c = TexCoord * 20.0;
    v += sin((c.x+offset));
    v += sin((c.y+offset)/2.0);
    v += sin((c.x+c.y+offset)/2.0);
    c += 0.5 * vec2(sin(offset/3.0), cos(offset/2.0));
    v += sin(sqrt(c.x*c.x+c.y*c.y+1.0)+offset);
    v = v/2.0;
    
    mediump float r = 0.5 + 0.5 * sin(3.1415 * v * 16.0);
    mediump float g = 0.5 + 0.5 * sin(3.1415 * v * 2.0);
    mediump float b = 0.0;
    gl_FragColor = vec4(r,g,b,1.0);

}
