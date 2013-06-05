//
//  Shader.vsh
//  Rotozoomer
//
//  Created by Richard Smith on 16/05/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

attribute vec4 position;
attribute vec2 TexCoordIn;
varying vec2 TexCoord;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{    
    gl_Position = modelViewProjectionMatrix * position;
    TexCoord=TexCoordIn;
}
