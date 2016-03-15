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
    0.5,    0.0,    0.0,    1.0,    0.0,    0.0,    1.0,
    0.0,    0.5,    0.0,    0.0,    1.0,    0.0,    1.0,
    -0.5,   0.0,    0.0,    0.0,    0.0,    1.0,    1.0
};

float rightAngleTriangle = 0.5;

GLubyte indices[] = { 0, 1, 2};


@interface ViewController ()
-(void) initGL;
-(void) drawTriangle;
-(void) drawQuad;
-(void) drawTriangleUsingVBO;
-(void) initTriangleVBO;
-(void) updateVBO;
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
    [self initTriangleVBO];
}

-(void) initGL {
    glViewport(0, 0, 300, 300);
    // set the clear color
    glClearColor( 1.0, 0.0, 0.0, 1.0 );
    glClearDepthf(1.0);
}

-(void) initTriangleVBO {
    // create an indentifier for the VBO
    glGenBuffers(1, &triangleVBO);
    
    // bind to the VBO
    glBindBuffer(GL_ARRAY_BUFFER, triangleVBO);
    
    // copy vertex data to the VBO
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 21, verticesAndColors, GL_STATIC_DRAW);
    
    //unbind from VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void) drawTriangleUsingVBO {
    //enable writing ot the postion variable
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);
    
    glBindBuffer(GL_ARRAY_BUFFER, triangleVBO);
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 28, 0);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 28, (void*)12);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    

}

-(void) drawTriangle {
    //enable writing ot the postion variable
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);
    
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 28, verticesAndColors);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 28, verticesAndColors + 3);
    
    //glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_BYTE, indices);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    
}

-(void) updateVBO {
    // bind to the VBO
    glBindBuffer(GL_ARRAY_BUFFER, triangleVBO);
    
    // update vertex data to the VBO
    glBufferSubData(GL_ARRAY_BUFFER, 28, 4, &rightAngleTriangle);
    
    //unbind from VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
}

-(void) drawQuad {
    float stripVertices[] = {
        -1.0,   -1.0,   0.0,    1.0,    1.0,    0.0,    1.0,
        1,0,    -1.0,    0.0,    1.0,    1.0,    0.0,    1.0,
        -1.0,   0.0,    0.0,    1.0,    1.0,    0.0,    1.0,
        1.0,    0.0,    0.0,    1.0,    1.0,    0.0,    1.0
    };
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);
    
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 28, stripVertices);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 28, stripVertices + 3);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // rendering function
    
    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, 1000, 1000);
    [self drawTriangleUsingVBO];
    [self drawQuad];
    
    //flush the opengl pipeline so that the commands get set to GPU
    glFlush();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)UpdateVBO:(id)sender {
    [self updateVBO];
}
@end
