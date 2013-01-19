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

typedef enum {
	TransformSkew,
	TransformTranslate,
	TransformScale,
	TransformRotate
} TransformOperation;

typedef enum {
	AnchorPointTopLeft,
	AnchorPointTopCenter,
	AnchorPointTopRight,
	AnchorPointMiddleLeft,
	AnchorPointCenter,
	AnchorPointMiddleRight,
	AnchorPointBottomLeft,
	AnchorPointBottomCenter,
	AnchorPointBottomRight
} AnchorPointLocation;

typedef enum {
	SkewModeInverse,
	SkewModeNone,
	SkewModeLow,
	SkewModeNormal,
	SkewModeHigh,
	SkewModeSide   // Not a real skew mode, but a change in view point
} SkewMode;

typedef enum {
	DurationMultiplier1x,
	DurationMultiplier2x,
	DurationMultiplier5x,
	DurationMultiplier10x
} DurationMultiplier;

typedef enum {
    TimingCurveLinear,
    TimingCurveEaseIn,
    TimingCurveEaseOut,
    TimingCurveEaseInOut,
    TimingCurveDefault,
    TimingCurveCustom
} TimingCurve;

enum {
    BallComponentNone = 0,
    BallComponentMove = 1 << 0,
    BallComponentScale = 1 << 1,
    BallComponentOpacity = 1 << 2
};
typedef NSUInteger BallComponent;

enum {
    FoldComponentNone = 0,
    FoldComponentBounds = 1 << 0,
    FoldComponentOpacity = 1 << 1
};
typedef NSUInteger FoldComponent;

enum {
    FlipComponentNone = 0,
    FlipComponentFacingShadow = 1 << 0,
    FlipComponentRevealShadow = 1 << 1
};
typedef NSUInteger FlipComponent;

typedef enum {
    AnimationTypeBall,
    AnimationTypeFold,
    AnimationTypeFlip
} AnimationType;


#endif
