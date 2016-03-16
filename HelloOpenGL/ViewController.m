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
    0.5,    0.0,    0.0,    1.0,    0.0,    0.0,    1.0, 1,1,
    0.0,    0.5,    0.0,    0.0,    1.0,    0.0,    1.0, 0.5, 0,
    -0.5,   0.0,    0.0,    0.0,    0.0,    1.0,    1.0, 0, 1
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
-(int) loadTexture:(NSString*)fileName;
-(int) loadTextures;
-(GLubyte*) pixelsFromImage:(NSString*)fileName;
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
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
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
    matIndex = glGetUniformLocation(programObject, "u_ModelMatrix");
    projectionMatrixIndex = glGetUniformLocation(programObject, "u_ProjectionMatrix");
    viewMatrixIndex = glGetUniformLocation(programObject, "u_ViewMatrix");
    textureCoordinateIndex = glGetAttribLocation(programObject, "a_TextureCoordinate");
    activeTextureIndex = glGetUniformLocation(programObject, "u_ActiveTexture");
    angle = 0.0;
    scale = 0.0;
    xPos = 0.0;
    
    [self initGL];
    [self initTriangleVBO];
}

-(void) initGL {
    glViewport(0, 0, 300, 300);
    // set the clear color
    glClearColor( 1.0, 0.0, 0.0, 1.0 );
    glClearDepthf(1.0);
    glEnable(GL_DEPTH_TEST);
    
    projectionMatrix = GLKMatrix4Identity;
    float aspect = (float) self.view.bounds.size.width/(float)self.view.bounds.size.height;
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), aspect, 0.1, 100.0);
    glUniformMatrix4fv(projectionMatrixIndex, 1, false, projectionMatrix.m);
    
    textureId = [self loadTextures];
}

-(int)loadTexture:(NSString*) fileName {
    GLuint textureID;
    glGenTextures(1, &textureID);
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte*) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    // bind to texture
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // specify the minification and magnification parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // specify the wrapping around x and y axis
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    
    glBindTexture(GL_TEXTURE_2D, 0 );
    free(spriteData);
    
    return textureID;
}

-(GLubyte*) pixelsFromImage:(NSString*)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte*) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    return spriteData;
}

-(int)loadTextures {
    GLuint textureID;
    glGenTextures(1, &textureID);
    
    // bind to texture
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    // Load Image at Level 0
    GLubyte* pixels = [self pixelsFromImage:@"mipmap128.png"];

    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 128, 128, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    //Load Image at Level 1
    pixels = [self pixelsFromImage:@"mipmap64.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 1, GL_RGBA, 64, 64, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    pixels = [self pixelsFromImage:@"mipmap32.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 2, GL_RGBA, 32, 32, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    pixels = [self pixelsFromImage:@"mipmap16.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 3, GL_RGBA, 16, 16, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    pixels = [self pixelsFromImage:@"mipmap8.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 4, GL_RGBA, 8, 8, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    pixels = [self pixelsFromImage:@"mipmap4.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 5, GL_RGBA, 4, 4, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    pixels = [self pixelsFromImage:@"mipmap2.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 6, GL_RGBA, 2, 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    pixels = [self pixelsFromImage:@"mipmap1.png"];
    
    //upload sprite image data to the texture object
    glTexImage2D(GL_TEXTURE_2D, 7, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    free( pixels );
    
    // specify the minification and magnification parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    
    // specify the wrapping around x and y axis
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    
    glBindTexture(GL_TEXTURE_2D, 0 );
    
    return textureID;
}

-(void) initTriangleVBO {
    // create an indentifier for the VBO
    glGenBuffers(1, &triangleVBO);
    
    // bind to the VBO
    glBindBuffer(GL_ARRAY_BUFFER, triangleVBO);
    
    // copy vertex data to the VBO
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 27, verticesAndColors, GL_STATIC_DRAW);
    
    //unbind from VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void) drawTriangleUsingVBO {
    //enable writing ot the postion variable
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);
    glEnableVertexAttribArray(textureCoordinateIndex);
    
    glBindBuffer(GL_ARRAY_BUFFER, triangleVBO);
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 36, 0);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 28, (void*)12);
    glVertexAttribPointer(textureCoordinateIndex, 2, GL_FLOAT, false, 36, (void*)28);

    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    glDisableVertexAttribArray(textureCoordinateIndex);
    
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
        -0.25,   -0.25,   0.0,    1.0,    1.0,    0.0,    1.0,  0,  1,
        0.25,    -0.25,    0.0,    1.0,    1.0,    0.0,   1.0,  1,  1,
        -0.25,   0.25,    0.0,    1.0,    1.0,    0.0,    1.0,  0,  0,
        0.25,    0.25,    0.0,    1.0,    1.0,    0.0,    1.0,  1,  0
    };
    //make the texture unit 0 active
    glActiveTexture(GL_TEXTURE0);
    
    //bind the texture to the active texture unit 0
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    // tell the fragment shader that texture unit 0 is active
    glUniform1i(activeTextureIndex, 0);
    
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);
    glEnableVertexAttribArray(textureCoordinateIndex);
    
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 36, stripVertices);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 36, stripVertices + 3);
    glVertexAttribPointer(textureCoordinateIndex, 2, GL_FLOAT, false, 36, stripVertices + 7);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    glDisableVertexAttribArray(textureCoordinateIndex);
    
}

float zPos = 0.0;
float zPosMultiplier = 1.0;

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // rendering function
    
    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_DEPTH_BUFFER_BIT);
    //glViewport(0, 0, 1000, 1000);
    
    angle += 1.0;
    if ( angle >= 360.0 ) angle = 0.0;
    zPos += zPosMultiplier * 0.05;
    
    if ( zPos > 50.0 ) {
        zPosMultiplier = -1.0;
    }
    if (zPos <= 0.04 ) {
        zPosMultiplier = 1.0;
    }
 
    viewMatrix = GLKMatrix4Identity;
    viewMatrix = GLKMatrix4MakeLookAt(0, 0, 1.0 + zPos, 0, 0, 0, 0.0, 1, 0);
    glUniformMatrix4fv(viewMatrixIndex, 1, false, viewMatrix.m);
    modelMatrix = GLKMatrix4Identity;
    //modelMatrix = GLKMatrix4Translate(modelMatrix, 0.0, 0.0, -5.0 );
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(angle), 0.0, 1.0, 0.0);
    // write the matrix to the shader
    glUniformMatrix4fv(matIndex, 1, false, modelMatrix.m);
    [self drawQuad];

    modelMatrix = GLKMatrix4Translate(modelMatrix, 0.8, 0.0, 0.0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(-angle), 0.0, 1.0, 0.0);
    modelMatrix = GLKMatrix4Scale(modelMatrix, 0.5, 0.5, 0.5);
    glUniformMatrix4fv(matIndex, 1, false, modelMatrix.m);
    [self drawTriangleUsingVBO];
    
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
