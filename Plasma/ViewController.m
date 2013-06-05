//
//  ViewController.m
//  Rotozoomer
//
//  Created by Richard Smith on 16/05/2013.
//  Copyright (c) 2013 Richard Smith. All rights reserved.
//

#import "ViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define TEX_COORD_MAX   1.0f
#define SQUARE_SIDE 0.99f
#define FPSSAMPLES 30

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_TEX_COORD,
    UNIFORM_TIME,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

// Palette index.
enum
{
    PALETTE_MESCALINE,
    PALETTE_NORMAL,
    PALETTE_MIDNIGHT,
    NUM_PALETTES
};

GLfloat * gVertexData;
GLint vertexCount;
float FPSsamples[FPSSAMPLES];
int FPSsampleOffset = 0;

@interface ViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    
    float _time;
    float _direction;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint _texture;
    
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end


@implementation ViewController

@synthesize FPSreadout;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //set initial direction
    _direction = 1;
    
    //calculate aspect ratio of screen
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    
    
    //create orthographic projection (identity) matrix with aspect ratio correction
    _modelViewProjectionMatrix = GLKMatrix4Make(1.0f / aspect, 0.0f, 0.0f, 0.0f,
                                                0.0f, 1.0f, 0.0f, 0.0f,
                                                0.0f, 0.0f, 1.0f, 0.0f,
                                                0.0f, 0.0f, 0.0f, 1.0f);
    
    //make a quad that fills the screen
    gVertexData = (GLfloat [6*5])
    {
        // Data layout for each line below is:
        // positionX, positionY, positionZ,     texX, texY,
        -aspect, -1.0f, 0.0f,        0.0f, 0.0f,
        aspect, -1.0f, 0.0f,        TEX_COORD_MAX, 0.0f,
        -aspect, 1.0f, 0.0f,         0.0f, TEX_COORD_MAX/aspect,
        -aspect, 1.0f, 0.0f,         0.0f, TEX_COORD_MAX/aspect,
        aspect, -1.0f, 0.0f,         TEX_COORD_MAX, 0.0f,
        aspect, 1.0f, 0.0f,          TEX_COORD_MAX, TEX_COORD_MAX/aspect
     };

    vertexCount = 6*5;
    
    //set up GL
    [self setupGL];
    
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    _texture = [self generatePalette:PALETTE_NORMAL];
    
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(GLfloat), gVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(uniforms[UNIFORM_TEX_COORD]);
    glVertexAttribPointer(uniforms[UNIFORM_TEX_COORD], 2, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(12));
    
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
        
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    
    _time += self.timeSinceLastUpdate * 0.2f * _direction;
    
    if (_time > 12.0 * M_PI)
    {
        _time -= 12.0 * M_PI;
    }
    
    [self updateFPS];

}

- (void) updateFPS
{
    if (FPSsampleOffset == FPSSAMPLES)
    {
        float FPSmin = FPSsamples[0];
        float FPStotal = 0;
        for (int i = 0; i<FPSSAMPLES; i++)
        {
            FPSmin = FPSmin < FPSsamples[i] ? FPSmin : FPSsamples[i];
            FPStotal += FPSsamples[i];
        }
        
        [FPSreadout setText:[NSString stringWithFormat:@" fps min:%04.1f \t avg:%04.1f", FPSmin, FPStotal / FPSSAMPLES]];

        FPSsampleOffset = 0;
    }
    FPSsamples[FPSsampleOffset++] = 1.0 / self.timeSinceLastUpdate;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    glUniform1f(uniforms[UNIFORM_TIME], _time);

    // Render the object  with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    //uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program,"palette");
    
    uniforms[UNIFORM_TEX_COORD] = glGetAttribLocation(_program, "TexCoordIn");

    uniforms[UNIFORM_TIME] = glGetUniformLocation(_program, "time");

    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (GLuint)generatePalette:(unsigned int)palette
{
    //allocate memory for palette
    unsigned int paletteSize = 1024;
    GLubyte * paletteData = (GLubyte *) calloc(paletteSize * 4, sizeof(GLubyte));
    
    //draw palette
    unsigned char r;
    unsigned char g;
    unsigned char b;
    for (int i = 0; i<paletteSize; i++)
    {
        float x = (float)i / (float)paletteSize;
        switch (palette)
        {
            case PALETTE_MESCALINE :
                r = 128 + 128 * sin(3.1415 * x * 16.0);
                g = 128 + 128 * sin(3.1415 * x * 2.0);
                b = 0;
                break;
                
            case PALETTE_NORMAL :
                r = 128 + 128 * sin(3.1415 * x * 8.0);
                g = 128 + 128 * sin(3.1415 * x * 4.0);
                b = 128 + 128 * sin(3.1415 * x * 2.0);
                break;
                
            case PALETTE_MIDNIGHT :
                r = 128 + 128 * sin(3.1415 * x * 2.0);
                g = 128 + 128 * sin(3.1415 * x * 2.0);
                b = 156 + 100 * sin(3.1415 * x * 2.0);
                break;

        }
        paletteData[i * 4] = r;
        paletteData[i * 4 + 1] = g;
        paletteData[i * 4 + 2] = b;
    };
    

    //bind texture
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, paletteSize, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, paletteData);
    
    free(paletteData);
    return texName;
}

- (IBAction) paletteA: (id)sender
{
    _texture=[self generatePalette:PALETTE_MESCALINE];
}

- (IBAction) paletteB: (id)sender
{
    _texture=[self generatePalette:PALETTE_NORMAL];
}

- (IBAction) paletteC: (id)sender
{
    _texture=[self generatePalette:PALETTE_MIDNIGHT];
}

@end
