//
//  Shader.fsh
//  Rotozoomer
//
//  Created by Richard Smith on 16/05/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//


uniform sampler2D tex;
varying highp vec2 TexCoord;
uniform highp float a;
uniform highp float z;
uniform highp float offset;


//highp mat2 rotationMatrix(highp float angle)
//{
//    highp float s = sin(angle);
//    highp float c = cos(angle);
//    
//    return highp mat2(c,-s,s,c);
//}
//
//
//void main()
//{
//    //gl_FragColor = vec4(1,0,0,0);
//    highp mat2 rot = rotationMatrix(a)/z;
//    highp vec2 offsetv = vec2(offset,0);
//	gl_FragColor = texture2D(tex, offsetv+TexCoord.xy * rot);
//}

void main()
{

    highp float x = TexCoord.x/3.0;
	highp float y = TexCoord.y/4.0;
    highp 	float c =   (0.5 + (0.5 * sin((x) * 16.0))
            + 0.5 + (0.5 * sin((y) * 32.0))
            + 0.5 + (0.5 * sin((x) * 16.0))
            + 0.5 + (0.5 * sin(sqrt(x * x + y * y) * offset * 32.0))
        ) / 4.0;

    highp float r = 0.5 + 0.5 * sin(3.1415 * c * 16.0);
    highp float g = 0.5 + 0.5 * sin(3.1415 * c * 2.0);
    highp float b = 0.0;
    gl_FragColor = vec4(r,g,b,1.0);

}
