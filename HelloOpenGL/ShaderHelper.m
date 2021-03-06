//
//  ShaderHelper.m
//  
//
//  Created by Amandeep Chawla on 14/03/16.
//
//


#import "ShaderHelper.h"
#import <OPENGLES/ES2/gl.h>


const char * V_SRC =
    "attribute vec4 a_Position; attribute vec4 a_Color; \n"
    "attribute vec2 a_TextureCoordinate;\n"
    "uniform mat4 u_ModelMatrix; \n"
    "uniform mat4 u_ProjectionMatrix; \n"
    "uniform mat4 u_ViewMatrix; \n"
    "varying vec4 v_Color; \n"
    "varying vec2 v_TextureCoordinate; \n"
    "void main() {\n"
    "   gl_Position = u_ProjectionMatrix * u_ViewMatrix * u_ModelMatrix * a_Position;\n"
    "   v_TextureCoordinate = a_TextureCoordinate;\n"
    "   v_Color = a_Color;\n"
    "}";
const char * F_SRC =
    "precision highp float;\n"
    "varying vec4 v_Color;\n"
    "varying vec2 v_TextureCoordinate;\n"
    "uniform sampler2D u_ActiveTexture;\n"
    "void main() {\n"
    "   vec4 textureColor = texture2D(u_ActiveTexture, v_TextureCoordinate);\n"
    "   gl_FragColor = textureColor;\n"
    "}";

@interface ShaderHelper()
-(int) createShaderOfType:(GLenum) type WithSrc:(const char*) src;
@end

@implementation ShaderHelper

-(int) createShaderOfType:(GLenum) type WithSrc:(const char*) src {
    // create shader object
    int shaderObj = glCreateShader(type);
    if ( shaderObj < 0 ) { NSLog(@"Unable to create Shader Object of type %d", type ); return -1; }
    
    // add source code to the shader object
    glShaderSource(shaderObj, 1, &src, 0);
    
    //compile the shader
    glCompileShader(shaderObj);
    
    // get the shader compilation status
    GLint success;
    glGetShaderiv(shaderObj, GL_COMPILE_STATUS, &success);
    if ( success == GL_TRUE) {
        NSLog(@"Shader compiled successfully");
        return shaderObj;
    } else {
        NSLog(@"Shader compilation failed");
        GLint length;
        glGetShaderiv(shaderObj, GL_INFO_LOG_LENGTH, &length);
        char * info = (char *) malloc(length);
        GLsizei l;
        glGetShaderInfoLog(shaderObj, length, &l, info);
        printf("Compiler error: %s", info);
        free(info);
        return -1;
    }
    return -1;
}

-(int) createProgramObject {
    int vertShaderObj = [self createShaderOfType:GL_VERTEX_SHADER WithSrc:V_SRC];
    int fragShaderObj = [self createShaderOfType:GL_FRAGMENT_SHADER WithSrc:F_SRC];
    
    if ( vertShaderObj < 0 || fragShaderObj < 0 ) {
        return -1;
    }
    
    // create a program object
    int programObj = glCreateProgram();
    
    // attach vertex and frag shader object to the program object
    glAttachShader(programObj, vertShaderObj);
    glAttachShader(programObj, fragShaderObj);
    
    // link shaders
    glLinkProgram(programObj);
    
    // check if linking successful
    GLint success;
    glGetProgramiv(programObj, GL_LINK_STATUS, &success);
    if (success==GL_TRUE) {
        NSLog(@"Shader Linked Successfully");
        return programObj;
    } else {
        NSLog(@"Shader Linking Failed");
    }
    return -1;
}
@end
