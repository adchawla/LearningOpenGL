//
//  ViewController.h
//  HelloOpenGL
//
//  Created by Amandeep Chawla on 14/03/16.
//  Copyright (c) 2016 Amandeep Chawla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "ShaderHelper.h"

@interface ViewController : GLKViewController {
    EAGLContext* context;
    ShaderHelper* shaderHelper;
    int programObject;
    
    int positionIndex;
    int colorIndex;
    int matIndex;
    int projectionMatrixIndex;
    int viewMatrixIndex;
    GLKMatrix4 modelMatrix;
    GLKMatrix4 projectionMatrix;
    GLKMatrix4 viewMatrix;
    float angle;
    float scale;
    float xPos;
    GLuint triangleVBO;
    GLuint sunVBO;
}
- (IBAction)UpdateVBO:(id)sender;


@end

