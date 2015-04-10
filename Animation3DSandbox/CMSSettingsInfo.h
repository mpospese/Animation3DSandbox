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

@property (nonatomic, assign) AnimationType type;
@property (nonatomic, assign) CFTimeInterval duration;

// Timing Curve
@property (nonatomic, assign) CGPoint cp1;
@property (nonatomic, assign) CGPoint cp2;
@property (nonatomic, assign) TimingCurve timingCurve;

// Components

@property (nonatomic, assign) BallComponent ballComponents;
@property (nonatomic, assign) FoldComponent foldComponents;
@property (nonatomic, assign) FlipComponent flipComponents;

// View

@property (nonatomic, assign) BOOL useDropShadows;
@property (nonatomic, assign) AnchorPointLocation anchorPoint;
@property (nonatomic, assign) BOOL useBackground;
@property (nonatomic, assign) SkewMode skewMode;
@property (nonatomic, assign) BOOL setShadowPath;
@property (nonatomic, assign) BOOL antiAliase;

// Theme

@property (nonatomic, assign) ThemeType theme;

- (CGFloat)skewMultiplier;

@end
