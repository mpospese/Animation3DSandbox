//
//  FoldViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "FoldViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MPAnimation.h"
#import "CMSSettingsController.h"

#define DEFAULT_DURATION 0.3
#define FOLD_SHADOW_OPACITY 0.25

@interface FoldViewController()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *centerBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *skewSegment;
@property (weak, nonatomic) IBOutlet UIView *controlFrame;

@property (readonly) CGFloat skew;

@property (assign, nonatomic, getter = isFolded) BOOL folded;
@property (assign, nonatomic, getter = isFolding) BOOL folding;
@property (assign, nonatomic) CGFloat pinchStartGap;
@property (assign, nonatomic) CGFloat lastProgress;
@property (assign, nonatomic) CGFloat durationMultiplier;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) CALayer *perspectiveLayer;
@property (strong, nonatomic) CALayer *topSleeve;
@property (strong, nonatomic) CALayer *bottomSleeve;
@property (strong, nonatomic) CAGradientLayer *upperFoldShadow;
@property (strong, nonatomic) CAGradientLayer *lowerFoldShadow;
@property (strong, nonatomic) CALayer *firstJointLayer;
@property (strong, nonatomic) CALayer *secondJointLayer;
@property (assign, nonatomic) CGPoint animationCenter;
@property (readonly, nonatomic) SkewMode skewMode;
@property (readonly, nonatomic) BOOL isInverse;

@property (strong, nonatomic) UIImage *slideUpperImage;
@property (strong, nonatomic) UIImage *foldUpperImage;
@property (strong, nonatomic) UIImage *foldLowerImage;
@property (strong, nonatomic) UIImage *slideLowerImage;

@property (nonatomic, readonly) CGFloat foldHeight;


@end

@implementation FoldViewController

- (void)doInit
{
	_durationMultiplier = 1;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
		[self doInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
		[self doInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Set drop shadows and shadow path
    [self.contentView layer].shadowOffset = CGSizeMake(0, 3);
	[[self.contentView layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.contentView bounds]] CGPath]];
    [self updateDropShadow:NO];
    
	// Add our tap gesture recognizer
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.delegate = self;
	[self.contentView addGestureRecognizer:tapGesture];
	
	// Add our pinch gesture recognizer
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.view addGestureRecognizer:pinchGesture];
}

- (void)updateImages
{
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIImage *entire = [MPAnimation renderImageFromView:self.contentView withInsets:insets];
    
    CGFloat yOffset = 0;
	self.slideUpperImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.topBar.bounds.size.height + insets.top)];
    yOffset += self.slideUpperImage.size.height;
    self.foldUpperImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.centerBar.bounds.size.height/2)];
    yOffset += self.foldUpperImage.size.height;
    self.foldLowerImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.centerBar.bounds.size.height/2)];
    yOffset += self.foldLowerImage.size.height;
	self.slideLowerImage = [MPAnimation renderImage:entire withRect:CGRectMake(0, yOffset, entire.size.width, self.bottomBar.bounds.size.height + insets.bottom)];    
}

- (CGFloat)foldHeight
{
    return CGRectGetHeight(self.centerBar.bounds);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// needed to keep view auto-sizing behavior from behaving badly with the optional side transform on contentView
	UIView *superview = [self.contentView superview];
	self.contentView.center = CGPointMake(roundf(CGRectGetMidX(superview.bounds)), roundf(CGRectGetMidY(superview.bounds)));
	self.contentView.bounds = CGRectMake(0, 0, 512, 512);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	UIView *superview = [self.contentView superview];
	// needed to keep view auto-sizing behavior from behaving badly with the optional side transform on contentView
	self.contentView.center = CGPointMake(roundf(CGRectGetMidX(superview.bounds)), roundf(CGRectGetMidY(superview.bounds)));
	self.contentView.bounds = CGRectMake(0, 0, 512, 512);
}

#pragma mark - Properties

- (SkewMode)skewMode
{
	return (SkewMode)[self.skewSegment selectedSegmentIndex];
}

- (CGFloat)skew
{
	switch ([self skewMode])
	{
		case SkewModeInverse:
			return 1 / ((self.foldHeight / 2) *  4.666666667);
			
		case SkewModeNone:
		case SkewModeSide:
			return 0;
			
		case SkewModeLow:
			return -1 / ((self.foldHeight / 2) *  14.5);
			
		case SkewModeNormal:
			return -1 / ((self.foldHeight / 2) *  4.666666667);
			
		case SkewModeHigh:
			return -1 / ((self.foldHeight / 2) *  1.5);
	}
}

- (BOOL)isInverse
{
	return [self skewMode] == SkewModeInverse;
}

- (void)updateDropShadow:(BOOL)animated
{
    if (self.isFolded)
    {
        // we have to unfold first (so that we can properly render the images)
        [self fold:^{
            [self updateDropShadow:animated];
        }];
        return;
    }
    
    CGFloat shadowOpacity = self.settings.useDropShadows? 0.5 : 0;
    if (!animated)
    {
        [self.contentView.layer setShadowOpacity:shadowOpacity];
        [self updateImages];
        return;
    }
    
    [CATransaction begin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    CALayer *presentationLayer = self.contentView.layer.presentationLayer;
    animation.fromValue = @(presentationLayer.shadowOpacity);
    animation.toValue = @(shadowOpacity);
    [self.contentView.layer addAnimation:animation forKey:@"shadowOpacity"];
    
    [CATransaction setCompletionBlock:^{
        [self.contentView.layer setShadowOpacity:shadowOpacity];
        [self updateImages];
    }];
    
    [CATransaction commit];
}

#pragma mark - Gesture handlers

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
	[self fold:nil];
}

- (void)fold:(void (^)(void))block
{
	[self setLastProgress:0];
	[self startFold];
	[self animateFold:YES completion:block];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = [gestureRecognizer state];
	
	CGFloat currentGap = [self pinchStartGap];
	if (state != UIGestureRecognizerStateEnded && gestureRecognizer.numberOfTouches == 2)
	{
		CGPoint p1 = [gestureRecognizer locationOfTouch:0 inView:self.view];
		CGPoint p2 = [gestureRecognizer locationOfTouch:1 inView:self.view];
		currentGap = fabsf(p1.y - p2.y);
    }
	
    if (state == UIGestureRecognizerStateBegan)
    {		
		[self setPinchStartGap:currentGap];
		[self startFold];
    }
	
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
    {
		[self endFold];
    }
	else if (state == UIGestureRecognizerStateChanged && gestureRecognizer.numberOfTouches == 2)
	{
		if ([self isFolded])
		{
			// pinching out, want + diff
			if (currentGap < [self pinchStartGap])
				currentGap = [self pinchStartGap]; // min
			
			if (currentGap > [self pinchStartGap] + self.foldHeight)
				currentGap = [self pinchStartGap] + self.foldHeight; // max
		}
		else 
		{
			// pinching in, want - diff
			if (currentGap < [self pinchStartGap] - self.foldHeight)
				currentGap = [self pinchStartGap] - self.foldHeight; // min
			
			if (currentGap > [self pinchStartGap])
				currentGap = [self pinchStartGap]; // max
		}
		
		[self doFold:currentGap - [self pinchStartGap]];
	}
}

- (IBAction)skewValueChanged:(UISegmentedControl *)sender {
	BOOL wasSideView = !CATransform3DIsIdentity(self.contentView.layer.transform);
	BOOL isSideView = self.skewMode == SkewModeSide;
	
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	CATransform3D contentTransform = CATransform3DIdentity;
	
	if (isSideView)
	{
		// Special transform so that we can view the fold from the side
		perspectiveTransform.m34 = -0.0010;
		perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 30, -35, 0);
		perspectiveTransform = CATransform3DRotate(perspectiveTransform, radians(60), .75, 1, -0.5);
		contentTransform = perspectiveTransform;
	}
	else
		perspectiveTransform.m34 = [self skew];		
	
	if (isSideView != wasSideView)
	{
		// animate the change in view point
		CGFloat duration = DEFAULT_DURATION * [self durationMultiplier];
		[UIView animateWithDuration:duration animations:^{
			self.contentView.layer.transform = contentTransform;
		}];
	}
	else
		self.contentView.layer.transform = contentTransform;
	
	[[self perspectiveLayer] setSublayerTransform:perspectiveTransform];	
}

- (IBAction)durationValueChanged:(UISegmentedControl *)sender {
	switch ([sender selectedSegmentIndex]) {
		case 0:
			[self setDurationMultiplier:1];
			break;
			
		case 1:
			[self setDurationMultiplier:2];
			break;
			
		case 2:
			[self setDurationMultiplier:5];
			break;
			
		case 3:
			[self setDurationMultiplier:10];
			break;
			
		default:
			break;
	}
}

- (CGFloat)currentProgress
{
    if (!self.isFolding)
        return 0;
    
	NSString *rotationKey = @"transform.rotation.x";
	double factor = M_PI / 180;
    
    NSNumber *rotationFromValue = [[self.firstJointLayer presentationLayer] valueForKeyPath:rotationKey];
    return [rotationFromValue floatValue]/(-90 * factor);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ([self isFolding])
        return NO;
    
    return YES;
}

#pragma mark - Other Animations

#pragma mark - Animations

- (void)startFold
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];

	[self setFolding:YES];
	[self buildLayers];
	[self doFold:[self isFolded]? 1 : 0];

	[CATransaction commit];
}

- (void)doFold:(CGFloat)difference
{
	CGFloat progress = fabsf(difference) / self.foldHeight;
	if ([self isFolded])
		progress = 1 - progress;
	
	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;
	
	if (progress == [self lastProgress])
		return;
	[self setLastProgress:progress];
	
	double angle = radians(90 * progress);
	double cosine = cos(angle);
	double foldHeight = cosine * self.foldHeight;

	[CATransaction begin];
    [CATransaction setAnimationDuration:0.15];
	
    self.firstJointLayer.transform = CATransform3DMakeRotation(-1*angle, 1, 0, 0);
    self.secondJointLayer.transform = CATransform3DMakeRotation(2*angle, 1, 0, 0);
    self.topSleeve.transform = CATransform3DMakeRotation(1*angle, 1, 0, 0);
    self.bottomSleeve.transform = CATransform3DMakeRotation(-1*angle, 1, 0, 0);
    
    if (self.settings.foldComponents & FoldComponentOpacity)
    {
        self.upperFoldShadow.opacity = FOLD_SHADOW_OPACITY * (1- cosine);
        self.lowerFoldShadow.opacity = FOLD_SHADOW_OPACITY * (1 - cosine);
	}
    
    if (self.settings.foldComponents & FoldComponentBounds)
        self.perspectiveLayer.bounds = (CGRect){CGPointZero, CGSizeMake(self.perspectiveLayer.bounds.size.width, foldHeight)};

	[CATransaction commit];
}

- (void)endFold
{	
	BOOL finish = NO;
	if ([self isFolded])
	{
		finish = 1 - cosf(radians(90 * [self lastProgress])) <= 0.5;
	}
	else
	{
		finish = 1 - cosf(radians(90 * [self lastProgress])) >= 0.5;
	}
    
    CGFloat currentProgress = [self currentProgress];
	
	if (currentProgress> 0 && currentProgress < 1)
		[self animateFold:finish completion:nil];
	else
		[self postFold:finish];
}

// Post fold cleanup (for animation completion block)
- (void)postFold:(BOOL)finish
{
	[self setFolding:NO];
	
	// final animation completed
	if (finish)
		[self setFolded:![self isFolded]];
	
	// remove the animation view and restore the center bar
	[self.animationView removeFromSuperview];
	self.animationView = nil;
	self.perspectiveLayer = nil;
	self.topSleeve = nil;
	self.bottomSleeve = nil;
	self.upperFoldShadow = nil;
	self.lowerFoldShadow = nil;
	self.firstJointLayer = nil;
	self.secondJointLayer = nil;
	
	if ([self isFolded])
	{
        if (self.settings.foldComponents & FoldComponentBounds)
        {
            CGPoint anchorPoint = [self anchorPoint];
            self.topBar.transform = CGAffineTransformMakeTranslation(0, anchorPoint.y * self.foldHeight);
            self.bottomBar.transform = CGAffineTransformMakeTranslation(0, (anchorPoint.y - 1) * self.foldHeight);
            self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, anchorPoint.y * self.foldHeight, self.contentView.bounds.size.width, self.contentView.bounds.size.height - self.foldHeight)].CGPath;
        }
        else
        {
            self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -self.foldHeight);
            self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height - self.foldHeight)].CGPath;
        }
		[self.centerBar setHidden:YES];
	}
	else 
	{
		self.topBar.transform = CGAffineTransformIdentity;
		self.bottomBar.transform = CGAffineTransformIdentity;
		[self.centerBar setHidden:NO];
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds].CGPath;
	}
	[self.contentView setHidden:NO];	
}

- (void)animateFold:(BOOL)finish completion:(void (^)(void))block
{
	[self setFolding:YES];
	
	// Figure out how many frames we want
	CGFloat duration = DEFAULT_DURATION * [self durationMultiplier];
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
		
	// Create a transaction
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:self.settings.cp1.x :self.settings.cp1.y :self.settings.cp2.x :self.settings.cp2.y]];
	[CATransaction setCompletionBlock:^{
		[self postFold:finish];
        
        if (block)
            block();
	}];
	
	[self.animationView setCenter:[self animationCenter]];

	BOOL forwards = finish != [self isFolded];
	NSString *rotationKey = @"transform.rotation.x";
	double factor = M_PI / 180;
	CGFloat fromProgress = [self currentProgress];
    if (!forwards)
        fromProgress = 1 - fromProgress;

    // fold the first (top) joint away from us
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
    //[animation setFromValue:forwards? [NSNumber numberWithDouble:-90*factor*fromProgress] : [NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
    [animation setToValue:forwards? [NSNumber numberWithDouble:-90*factor] : [NSNumber numberWithDouble:0]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    animation.speed = 1;
    [self.firstJointLayer addAnimation:animation forKey:nil];
    
    // fold the second joint back towards us at twice the angle (since it's connected to the first fold we're folding away)
    animation = [CABasicAnimation animationWithKeyPath:rotationKey];
    //[animation setFromValue:forwards? [NSNumber numberWithDouble:180*factor*fromProgress] : [NSNumber numberWithDouble:180*factor*(1-fromProgress)]];
    [animation setToValue:forwards? [NSNumber numberWithDouble:180*factor] : [NSNumber numberWithDouble:0]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    animation.speed = 1;
    [self.secondJointLayer addAnimation:animation forKey:nil];
    
    // fold the bottom sleeve (3rd joint) away from us, so that net result is it lays flat from user's perspective
    animation = [CABasicAnimation animationWithKeyPath:rotationKey];
    //[animation setFromValue:forwards? [NSNumber numberWithDouble:-90*factor*fromProgress] : [NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
    [animation setToValue:forwards? [NSNumber numberWithDouble:-90*factor] : [NSNumber numberWithDouble:0]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    animation.speed = 1;
    [self.bottomSleeve addAnimation:animation forKey:nil];
    
    // fold top sleeve towards us, so that net result is it lays flat from user's perspective
    animation = [CABasicAnimation animationWithKeyPath:rotationKey];
    //[animation setFromValue:forwards? [NSNumber numberWithDouble:90*factor*fromProgress] : [NSNumber numberWithDouble:90*factor*(1-fromProgress)]];
    [animation setToValue:forwards? [NSNumber numberWithDouble:90*factor] : [NSNumber numberWithDouble:0]];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    animation.speed = 1;
    [self.topSleeve addAnimation:animation forKey:nil];
    
	// Build an array of keyframes for perspectiveLayer.bounds.size.height
	NSMutableArray* arrayHeight = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* arrayShadow = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	CGFloat cosine;
	CGFloat cosHeight;
	CGFloat cosShadow;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = fromProgress + (((1 - fromProgress) * frame) / frameCount);
		//progress = (((float)frame) / frameCount);
		cosine = forwards? cos(radians(90 * progress)) : sin(radians(90 * progress));
		if ((forwards && frame == frameCount) || (!forwards && frame == 0 && fromProgress == 0))
			cosine = 0;
		cosHeight = ((cosine)* self.foldHeight); // range from 2*height to 0 along a cosine curve
		[arrayHeight addObject:[NSNumber numberWithFloat:cosHeight]];
		
		cosShadow = FOLD_SHADOW_OPACITY * (1 - cosine);
		[arrayShadow addObject:[NSNumber numberWithFloat:cosShadow]];
	}
	
	// resize height of the 2 folding panels along a cosine curve.  This is necessary to maintain the 2nd joint in the center
	// Since there's no built-in sine timing curve, we'll use CAKeyframeAnimation to achieve it
	CAKeyframeAnimation *keyAnimation;
    
    if (self.settings.foldComponents & FoldComponentBounds)
    {
        keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.height"];
        [keyAnimation setValues:[NSArray arrayWithArray:arrayHeight]];
        [keyAnimation setFillMode:kCAFillModeForwards];
        [keyAnimation setRemovedOnCompletion:NO];
        keyAnimation.speed = 1;
        [self.perspectiveLayer addAnimation:keyAnimation forKey:nil];
	}
    
    if (self.settings.foldComponents & FoldComponentOpacity)
    {
        // Dim the 2 folding panels as they fold away from us
        keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        [keyAnimation setValues:arrayShadow];
        [keyAnimation setFillMode:kCAFillModeForwards];
        [keyAnimation setRemovedOnCompletion:NO];
        keyAnimation.speed = 1;
        [self.upperFoldShadow addAnimation:keyAnimation forKey:nil];
        
        keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        [keyAnimation setValues:arrayShadow];
        [keyAnimation setFillMode:kCAFillModeForwards];
        [keyAnimation setRemovedOnCompletion:NO];
        keyAnimation.speed = 1;
        [self.lowerFoldShadow addAnimation:keyAnimation forKey:nil];
    }
				
	// commit the transaction
	[CATransaction commit];
}

- (CGPoint)anchorPoint
{
    CGPoint anchorPoint;
    
    switch (self.settings.anchorPoint) {
        case AnchorPointTopLeft:
            anchorPoint = CGPointMake(-0.25, -0.25);
            break;
            
        case AnchorPointTopCenter:
            anchorPoint = CGPointMake(0.5, -0.25);
            break;
            
        case AnchorPointTopRight:
            anchorPoint = CGPointMake(1.25, -0.25);
            break;
            
        case AnchorPointMiddleLeft:
            anchorPoint = CGPointMake(-0.25, 0.5);
            break;
            
        case AnchorPointCenter:
            anchorPoint = CGPointMake(0.5, 0.5);
            break;
            
        case AnchorPointMiddleRight:
            anchorPoint = CGPointMake(1.25, 0.5);
            break;
            
        case AnchorPointBottomLeft:
            anchorPoint = CGPointMake(-0.25, 1.25);
            break;
            
        case AnchorPointBottomCenter:
            anchorPoint = CGPointMake(0.5, 1.25);
            break;
            
        case AnchorPointBottomRight:
            anchorPoint = CGPointMake(1.25, 1.25);
            break;
    }

    return anchorPoint;
}

- (void)buildLayers
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];

	CGRect bounds = self.centerBar.bounds;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
    
	// we inset the folding panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets foldInsets = UIEdgeInsetsMake(0, 10, 0, 10);
	// insets on top/bottom are only needed if we're transforming the entire view (in which case these edges need
	// anti-aliasing as well)
	
	CGRect upperRect = bounds;
	upperRect.size.height = bounds.size.height / 2;
	CGRect lowerRect = upperRect;
	lowerRect.origin.y += upperRect.size.height;
		
	[self.centerBar setHidden:NO];
	
	UIView *actingSource = self.contentView;
	UIView *containerView = [actingSource superview];
	[actingSource setHidden:YES];
	
	CATransform3D transform = self.contentView.layer.transform;
	CALayer *upperFold;
	CALayer *lowerFold;
	
	CGFloat width = bounds.size.width;
	CGFloat height = bounds.size.height/2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	CGFloat lowerHeight = (height * 2) - upperHeight;

	// view to hold all our sublayers
	self.contentView.layer.transform = CATransform3DIdentity; // need to temporarily remove transform before calling convertRect
	CGRect mainRect = [containerView convertRect:self.centerBar.frame fromView:actingSource];
	self.contentView.layer.transform = transform; // put the transform back
	self.animationView = [[UIView alloc] initWithFrame:mainRect];
	self.animationView.backgroundColor = [UIColor clearColor];
	[containerView addSubview:self.animationView];
	[self setAnimationCenter:[self.animationView center]];
	
	// layer that covers the 2 folding panels in the middle
    CGPoint anchorPoint = [self anchorPoint];
	self.perspectiveLayer = [CALayer layer];
	self.perspectiveLayer.frame = CGRectMake(0 + ((anchorPoint.x - 0.5) * width), 0 + ((anchorPoint.y - 0.5) * height * 2), width, height * 2);
    self.perspectiveLayer.anchorPoint = anchorPoint;
	[self.animationView.layer addSublayer:self.perspectiveLayer];
	
	// layer that encapsulates the join between the top sleeve (remains flat) and upper folding panel
	self.firstJointLayer = [CATransformLayer layer];
	self.firstJointLayer.frame = self.animationView.bounds;
	[self.perspectiveLayer addSublayer:self.firstJointLayer];
	
	// This remains flat, and is the upper half of the destination view when moving forwards
	// It slides down to meet the bottom sleeve in the center
	self.topSleeve = [CALayer layer];
	self.topSleeve.frame = (CGRect){CGPointZero, self.slideUpperImage.size};
	self.topSleeve.anchorPoint = CGPointMake(0.5, 1);
	self.topSleeve.position = CGPointMake(width/2, 0);
	[self.topSleeve setContents:(id)[self.slideUpperImage CGImage]];
	[self.firstJointLayer addSublayer:self.topSleeve];
	
	// This piece folds away from user along top edge, and is the upper half of the source view when moving forwards
	upperFold = [CALayer layer];
	upperFold.frame = (CGRect){CGPointZero, self.foldUpperImage.size};
	upperFold.anchorPoint = CGPointMake(0.5, 0);
	upperFold.position = CGPointMake(width/2, 0);
	upperFold.contents = (id)[self.foldUpperImage CGImage];
	[self.firstJointLayer addSublayer:upperFold];
	
	// layer that encapsultates the join between the upper and lower folding panels (the V in the fold)
	self.secondJointLayer = [CATransformLayer layer];
	self.secondJointLayer.frame = self.animationView.bounds;
	self.secondJointLayer.frame = CGRectMake(0, 0, width, height*2);
	self.secondJointLayer.anchorPoint = CGPointMake(0.5, 0);
	self.secondJointLayer.position = CGPointMake(width/2, upperHeight);
	[self.firstJointLayer addSublayer:self.secondJointLayer];
	
	// This piece folds away from user along bottom edge, and is the lower half of the source view when moving forwards
	lowerFold = [CALayer layer];
	lowerFold.frame = (CGRect){CGPointZero, self.foldLowerImage.size};
	lowerFold.anchorPoint = CGPointMake(0.5, 0);
	lowerFold.position = CGPointMake(width/2, 0);
	lowerFold.contents = (id)[self.foldLowerImage CGImage];
	[self.secondJointLayer addSublayer:lowerFold];
	
	// This remains flat, and is the lower half of the destination view when moving forwards
	// It slides up to meet the top sleeve in the center
	self.bottomSleeve = [CALayer layer];
	self.bottomSleeve.frame = (CGRect){CGPointZero, self.slideLowerImage.size};
	self.bottomSleeve.anchorPoint = CGPointMake(0.5, 0);
	self.bottomSleeve.position = CGPointMake(width/2, lowerHeight);
	[self.bottomSleeve setContents:(id)[self.slideLowerImage CGImage]];
	[self.secondJointLayer addSublayer:self.bottomSleeve];
	
	self.firstJointLayer.anchorPoint = CGPointMake(0.5, 0);
	self.firstJointLayer.position = CGPointMake(width/2, 0);
	
	// Shadow layers to add shadowing to the 2 folding panels
    if (self.settings.foldComponents & FoldComponentOpacity)
    {
        self.upperFoldShadow = [CAGradientLayer layer];
        [upperFold addSublayer:self.upperFoldShadow];
        self.upperFoldShadow.frame = CGRectInset(upperFold.bounds, foldInsets.left, foldInsets.top);
        //self.upperFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
        self.upperFoldShadow.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];	
        self.upperFoldShadow.startPoint = CGPointMake(0.5, 0);
        self.upperFoldShadow.endPoint = CGPointMake(0.5, 1);
        self.upperFoldShadow.opacity = 0;
        
        self.lowerFoldShadow = [CAGradientLayer layer];
        [lowerFold addSublayer:self.lowerFoldShadow];
        self.lowerFoldShadow.frame = CGRectInset(lowerFold.bounds, foldInsets.left, foldInsets.top);
        //self.lowerFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
        self.lowerFoldShadow.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor, nil];	
        self.lowerFoldShadow.startPoint = CGPointMake(0.5, 0);
        self.lowerFoldShadow.endPoint = CGPointMake(0.5, 1);
        self.lowerFoldShadow.opacity = 0;
    }
			
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	transform.m34 = [self skew];
	self.perspectiveLayer.sublayerTransform = transform;
	
	[CATransaction commit];
}

@end
