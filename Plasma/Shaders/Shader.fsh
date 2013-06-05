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
    mediump vec2 c = TexCoord * (8.0 + sin(time));
    v += sin((c.x + time));
    v += sin((c.y + time) / 2.0);
    v += sin((c.x + c.y - time) / 3.0);
    v = v / 3.0;
    
    
    //Palette lookup
//    mediump float r = 0.5 + 0.5 * sin(3.1415 * v * 16.0);
//    mediump float g = 0.5 + 0.5 * sin(3.1415 * v * 2.0);
//    mediump float b = 0.0;
//    gl_FragColor = vec4(r,g,b,1.0);
    
    //Look up palette in texture
    gl_FragColor = texture2D(palette,vec2(v,1.0));

}
