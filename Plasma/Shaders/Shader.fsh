//
//  Shader.fsh
//  Rotozoomer
//
//  Created by Richard Smith on 16/05/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//


varying mediump vec2 TexCoord;
uniform mediump float time;
uniform sampler2D palette;

void main()
{
    
    //Compute plasma
    mediump float v = 0.0;
    mediump vec2 c = TexCoord * 20.0;
    v += sin((c.x+time));
    v += sin((c.y+time)/2.0);
    v += sin((c.x+c.y+time)/2.0);
    //c += 0.5 * vec2(sin(time/3.0), cos(time/2.0));
    mediump float d = c.x*c.x+c.y*c.y+1.0;
    v += sin(sqrt(d)+time);
    v = v/4.0;
    
    
    //Palette lookup
    //mediump float r = 0.5 + 0.5 * sin(3.1415 * v * 16.0);
    //mediump float g = 0.5 + 0.5 * sin(3.1415 * v * 2.0);
    //mediump float b = 0.0;
    //gl_FragColor = vec4(r,g,b,1.0);
    gl_FragColor = texture2D(palette,vec2(v,1.0));

}
