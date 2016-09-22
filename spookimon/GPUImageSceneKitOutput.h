//
//  GPUImageSceneKitOutput.h
//  spookimon
//
//  Created by Nate Parrott on 9/22/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import <GPUImage/GPUImage.h>
@import SceneKit;

@interface GPUImageSceneKitOutput : GPUImageOutput

- (void)render:(SCNRenderer *)renderer size:(CGSize)size time:(CFTimeInterval)time;

@end
