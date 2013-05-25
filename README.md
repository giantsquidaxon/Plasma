#OpenGL ES 2.0 Plasma Shader for iOS

A slightly crap bit of tutorial code by Ritchie Smith ( [@narrenschiff](https://twitter.com/Narrenschiff) )

##Introduction
This project implements a groovy retro-style plasma for iOS as an OpenGL Shader Language fragment shader. It's based heavily on the default apple "OpenGL Game" template, but with most of the GLKit code removed so it's mostly just plain old OpenGL ES 2.0.

##Requirements
Requires Xcode and the iOS 6 developer stuff. Will run fine in the simulator.

##How it works
###viewController
viewController is a subclass of GLKViewController. The desired frame rate defaults to 30 fps, but actual frame rate is slower depending on hardware.

* `- (void)viewDidLoad` sets up the coordinates of a quad filling the whole screen, sets up an orthographic projection matrix that accounts for aspect ratio, then calls setupGL

* `- (void)setupGL` loads in shaders and sets up vertex buffers and other bits of state for OpenGL

* `- (void)update` is called once per frame, and increments the _time ivar to animate the effect.

* `- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect` draws the frame and passes in the value of _time as a Uniform for the shader.

###shader.fsh
This fragment shader that uses the texture coordinates and the time to draw the plasma. This is probably the bit you want to play around with.

##Bugs
* Frame rate is a bit shanty, probably due to using sqrt in the shader. Will probably swap to using textures as a lookup table.
* It isn't the 90s anymore.