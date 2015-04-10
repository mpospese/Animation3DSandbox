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
        _duration = 1.5;
        
        [self setTimingCurve:TimingCurveDefault];
       
        _ballComponents = BallComponentMove;
        _foldComponents = FoldComponentOpacity | FoldComponentBounds;
        _flipComponents = FlipComponentFacingShadow | FlipComponentRevealShadow;
        
        _useDropShadows = YES;
        _anchorPoint = AnchorPointCenter;
        _useBackground = YES;
        _skewMode = SkewModeNormal;
        _theme = ThemeCocoaConf;
        _setShadowPath = YES;
        _antiAliase = YES;
        _type = AnimationTypeBall;
    }
    return self;
}

- (TimingCurve)timingCurve
{
    if (CGPointEqualToPoint(self.cp1, CGPointZero))
    {
        if (CGPointEqualToPoint(self.cp2, (CGPoint){1, 1}))
            return TimingCurveLinear;
        else if (CGPointEqualToPoint(self.cp2, [CMSSettingsInfo timingEaseOutPoint2]))
            return TimingCurveEaseOut;
    }
    else if (CGPointEqualToPoint(self.cp1, [CMSSettingsInfo timingEaseInPoint1]))
    {
        if (CGPointEqualToPoint(self.cp2, [CMSSettingsInfo timingEaseInPoint2]))
            return TimingCurveEaseIn;
        else if (CGPointEqualToPoint(self.cp2, [CMSSettingsInfo timingEaseOutPoint2]))
            return TimingCurveEaseInOut;
    }
    else if (CGPointEqualToPoint(self.cp1, [CMSSettingsInfo timingDefaultPoint]) && CGPointEqualToPoint(self.cp2, [CMSSettingsInfo timingDefaultPoint]))
        return TimingCurveDefault;
    
    return TimingCurveCustom;
}

+ (CGPoint)timingEaseInPoint1
{
    return CGPointMake(0.42f, 0.0f);
}

+ (CGPoint)timingEaseInPoint2
{
    return CGPointMake(1.0f, 1.0f);
}

+ (CGPoint)timingEaseOutPoint1
{
    return CGPointMake(0.0f, 0.0f);
}

+ (CGPoint)timingEaseOutPoint2
{
    return CGPointMake(0.58f, 1.0f);
}

+ (CGPoint)timingDefaultPoint
{
    return CGPointMake(0.25f, 0.10f);
}

- (void)setTimingCurve:(TimingCurve)timingCurve
{
    switch (timingCurve) {
        case TimingCurveLinear:
            self.cp1 = CGPointZero;
            self.cp2 = (CGPoint){1, 1};
            break;
            
        case TimingCurveEaseIn:
            self.cp1 = [CMSSettingsInfo timingEaseInPoint1];
            self.cp2 = [CMSSettingsInfo timingEaseInPoint2];
            break;
            
        case TimingCurveEaseOut:
            self.cp1 = [CMSSettingsInfo timingEaseOutPoint1];
            self.cp2 = [CMSSettingsInfo timingEaseOutPoint2];
            break;
            
        case TimingCurveEaseInOut:
            self.cp1 = [CMSSettingsInfo timingEaseInPoint1];
            self.cp2 = [CMSSettingsInfo timingEaseOutPoint2];
            break;
            
        case TimingCurveDefault:
            self.cp1 = [CMSSettingsInfo timingDefaultPoint];
            self.cp2 = [CMSSettingsInfo timingDefaultPoint];
            break;
            
        default:
            break;
    }
}

- (CGFloat)skewMultiplier
{
	switch (self.skewMode) {
		case SkewModeInverse:
			return 4.666667;
			
		case SkewModeNone:
			return 0;
			
		case SkewModeLow:
			return -14.5;
			
		case SkewModeNormal:
			return -4.666667;
			
		case SkewModeHigh:
			return -1.5;
	}
}

@end
