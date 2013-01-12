//
//  CMSSettingsInfo.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSSettingsInfo.h"

@interface CMSSettingsInfo()

@end

@implementation CMSSettingsInfo

- (id)init
{
    self = [super init];
    if (self) {
        _duration = 0.3;
        
        _cp1 = CGPointMake(0.25, 0.1);
        _cp2 = CGPointMake(0.25, 0.1);
        
        _components = FoldComponentTransform | FoldComponentOpacity | FoldComponentBounds;

        _useDropShadows = YES;
        _anchorPoint = AnchorPointCenter;
    }
    return self;
}

@end
