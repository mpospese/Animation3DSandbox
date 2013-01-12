//
//  CMSSettingsInfo.h
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enumerations.h"

@interface CMSSettingsInfo : NSObject

// Animations

@property (nonatomic, assign) CFTimeInterval duration;

// Timing Curve
@property (nonatomic, assign) CGPoint cp1;
@property (nonatomic, assign) CGPoint cp2;

// Components

@property (nonatomic, assign) FoldComponent components;

// View

@property (nonatomic, assign) BOOL useDropShadows;
@property (nonatomic, assign) AnchorPointLocation anchorPoint;

@end
