//
//  GPUImageSceneKitOutput.m
//  spookimon
//
//  Created by Nate Parrott on 9/22/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "GPUImageSceneKitOutput.h"

@interface GPUImageSceneKitOutput () {
    GLuint framebuffer;
    GLuint depthRenderbuffer;
    CGSize _size;
    GLuint texture;
}

@end

@implementation GPUImageSceneKitOutput

- (instancetype)initWithSize:(CGSize)size {
    _size = size;
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        
        // create the texture
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
        
        // depth buffer:
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, size.width, size.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"failed to make complete framebuffer object %x", status);
        }
        
        glBindTexture(GL_TEXTURE_2D, 0);
        
    });
    self = [super initWithTexture:texture size:size];
    return self;
}

- (void)render:(SCNRenderer *)renderer size:(CGSize)size time:(CFTimeInterval)time {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glViewport(0, 0, (int)_size.width, (int)_size.height);
        glClearColor(255,0,0,0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        // glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
        glGetError();
        [renderer renderAtTime:time];
        glFlush(); // TODO: can we remove this???
        [self processTextureWithFrameTime:kCMTimeIndefinite];
//        for (id<GPUImageInput> currentTarget in targets)
//        {
//            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
//            NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
//            
//            [currentTarget setInputSize:_size atIndex:targetTextureIndex];
//            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:targetTextureIndex];
//            [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:targetTextureIndex];
//        }
    });
}

@end
