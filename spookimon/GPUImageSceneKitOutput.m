//
//  GPUImageSceneKitOutput.m
//  spookimon
//
//  Created by Nate Parrott on 9/22/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "GPUImageSceneKitOutput.h"

@implementation GPUImageSceneKitOutput

- (void)render:(SCNRenderer *)renderer size:(CGSize)size time:(CFTimeInterval)time {
    [GPUImageContext useImageProcessingContext];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:size textureOptions:self.outputTextureOptions onlyTexture:YES];
    [outputFramebuffer activateFramebuffer];
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT);
    // glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    glGetError();
    [renderer renderAtTime:time];
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [currentTarget setInputSize:size atIndex:textureIndexOfTarget];
            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
        }
    }
    // [outputFramebuffer unlock];
}

@end
