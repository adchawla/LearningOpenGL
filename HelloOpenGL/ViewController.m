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
@interface ViewController ()
-(void) initGL;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // initialize the rendering context for OpenGL ES 2
    context = [ [EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // associate the context with the GLKView
    GLKView* view = (GLKView*) self.view;
    view.context = context;
    
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
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // rendering function
    
    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    //enable writing ot the postion variable
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);

    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 0, vertices);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 0, colors);

    glDrawArrays(GL_TRIANGLES, 0, 3);
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
