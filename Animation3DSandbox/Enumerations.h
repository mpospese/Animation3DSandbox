//
//  Enumerations.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 2/27/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#ifndef EnterTheMatrix_Enumerations_h
#define EnterTheMatrix_Enumerations_h

static inline double radians (double degrees) {return degrees * M_PI/180;}
static inline double degrees (double radians) {return radians * 180/M_PI;}

typedef NS_ENUM(NSInteger, TransformOperation)
{
	TransformSkew,
	TransformTranslate,
	TransformScale,
	TransformRotate
};

typedef NS_ENUM(NSInteger, AnchorPointLocation)
{
	AnchorPointTopLeft,
	AnchorPointTopCenter,
	AnchorPointTopRight,
	AnchorPointMiddleLeft,
	AnchorPointCenter,
	AnchorPointMiddleRight,
	AnchorPointBottomLeft,
	AnchorPointBottomCenter,
	AnchorPointBottomRight
};

typedef NS_ENUM(NSInteger, SkewMode)
{
	SkewModeInverse,
	SkewModeNone,
	SkewModeLow,
	SkewModeNormal,
	SkewModeHigh
};

typedef NS_ENUM(NSInteger, DurationMultiplier)
{
	DurationMultiplier1x,
	DurationMultiplier2x,
	DurationMultiplier5x,
	DurationMultiplier10x
};

typedef NS_ENUM(NSInteger, TimingCurve)
{
    TimingCurveLinear,
    TimingCurveEaseIn,
    TimingCurveEaseOut,
    TimingCurveEaseInOut,
    TimingCurveDefault,
    TimingCurveCustom
};

typedef NS_OPTIONS(NSInteger, BallComponent)
{
    BallComponentNone = 0,
    BallComponentMove = 1 << 0,
    BallComponentScale = 1 << 1,
    BallComponentOpacity = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, FoldComponent)
{
    FoldComponentNone = 0,
    FoldComponentBounds = 1 << 0,
    FoldComponentOpacity = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, FlipComponent)
{
    FlipComponentNone = 0,
    FlipComponentFacingShadow = 1 << 0,
    FlipComponentRevealShadow = 1 << 1
};

typedef NS_ENUM(NSInteger, AnimationType)
{
    AnimationTypeBall,
    AnimationTypeFold,
    AnimationTypeFlip
};

typedef NS_ENUM(NSInteger, ThemeType)
{
    ThemeRenaissance,
    ThemeCocoaConf,
    Theme360iDev
};

#endif
