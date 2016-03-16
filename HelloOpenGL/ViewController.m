//
//  ViewController.m
//  HelloOpenGL
//
//  Created by Amandeep Chawla on 14/03/16.
//  Copyright (c) 2016 Amandeep Chawla. All rights reserved.
//

#import "ViewController.h"

float vertices[] = { 0.5, 0.0, 0.0,     0.0, 0.5, 0.0,  -0.5, 0.0, 0.0};
float colors[] = { 1.0, 0.0, 0.0, 1.0,  0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0};
float verticesAndColors[] = {
    0.8,    0.8,    0.0,    1.0,    0.0,    0.0,    1.0,
    -0.8,    0.8,    0.0,    0.0,    1.0,    0.0,    1.0,
    0.8,   -0.8,    0.0,    0.0,    0.0,    1.0,    1.0,
    -0.8,    -0.8,   0.0,    0.0,    1.0,    0.0,    1.0
};

@interface ViewController ()
-(void) initGL;
-(void) drawClipTriangle;
@end

@implementation ViewController

-(void) drawClipTriangle {
    float vertices[] = { 0.5, 0.0, 0.0, 0.0, 0.5, 0.0, -0.5, 0.0, 0.0 };
    glEnableVertexAttribArray(positionIndex);
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 0, vertices);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(positionIndex);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // initialize the rendering context for OpenGL ES 2
    context = [ [EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // associate the context with the GLKView
    GLKView* view = (GLKView*) self.view;
    view.context = context;
 
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    // getting the stencil buffer
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    
    // make the context current
    [EAGLContext setCurrentContext:context];
    shaderHelper = [[ShaderHelper alloc] init];
    programObject = [shaderHelper createProgramObject];
    
    if ( programObject < 0 ) {
        NSLog(@"Shader Failed");
        return;
    }  else {
        NSLog(@"Shader executable loaded successfully");
        //load the shader executable on GPU
        glUseProgram(programObject);
    }
    
    // get the index of the attribute named "a_Position"
    positionIndex = glGetAttribLocation(programObject, "a_Position");
    colorIndex = glGetAttribLocation(programObject, "a_Color");
    
    [self initGL];
}

-(void) initGL {
    // set the clear color
    glClearColor( 1.0, 0.0, 0.0, 1.0 );
    glClearDepthf(1.0);
    glClearStencil(0.0);
    
    //glEnable(GL_DEPTH_TEST);
    glEnable(GL_STENCIL_TEST);
    
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // rendering function
    
    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    // disable writing to the color buffer
    glColorMask(false, false, false, false);
    
    // set up stencil function
    glStencilFunc(GL_ALWAYS, 1, 1 );
    glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);
    [self drawClipTriangle];
    
    // enable writing to the color buffer
    glColorMask(true, true, true, true);
    // set up stencil test for quad
    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    //enable writing ot the postion variable
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);

    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 28, verticesAndColors);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 28, verticesAndColors + 3);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);

    //flush the opengl pipeline so that the commands get set to GPU
    glFlush();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
