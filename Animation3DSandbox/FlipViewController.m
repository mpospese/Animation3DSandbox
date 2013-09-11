//
//  FlipViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "FlipViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MPAnimation.h"
#import "Enumerations.h"

#define ANGLE	90
#define MARGIN	72

#define SWIPE_LEFT_THRESHOLD -100.0f
#define SWIPE_RIGHT_THRESHOLD 100.0f
#define SPINE_SHADOW_OFFSET 5.0f

typedef enum {
	FlipDirectionForward,
	FlipDirectionBackward
} FlipDirection;


@interface FlipViewController()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *contentView;

@property(assign, nonatomic) FlipDirection direction;
@property(assign, nonatomic, getter = isFlipFrontPage) BOOL flipFrontPage;
@property(assign, nonatomic, getter = isAnimating) BOOL animating;
@property(assign, nonatomic, getter = isPanning) BOOL panning;
@property(assign, nonatomic) CGPoint panStart;
@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) CALayer *layerFront;
@property (strong, nonatomic) CALayer *layerFacing;
@property (strong, nonatomic) CALayer *layerBack;
@property (strong, nonatomic) CALayer *layerReveal;
@property (strong, nonatomic) CALayer *layerFlipping;
@property (strong, nonatomic) CAGradientLayer *layerFrontShadow;
@property (strong, nonatomic) CAGradientLayer *layerBackShadow;
@property (strong, nonatomic) CAGradientLayer *layerFacingShadow;
@property (strong, nonatomic) CAGradientLayer *layerRevealShadow;

@property (strong, nonatomic) UIImage *leftImage;
@property (strong, nonatomic) UIImage *rightImage;

@end

@implementation FlipViewController

- (void)doInit
{
	_direction = FlipDirectionForward;
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
    
	UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	left.direction = UISwipeGestureRecognizerDirectionLeft;
	left.delegate = self;
	[self.contentView addGestureRecognizer:left];
	
	UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	right.direction = UISwipeGestureRecognizerDirectionRight;
	right.delegate = self;
	[self.contentView addGestureRecognizer:right];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
	[self.contentView addGestureRecognizer:tap];
	
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	pan.delegate = self;
	[self.contentView addGestureRecognizer:pan];
	
	// drop-shadow for content view
	[[self.contentView layer] setShadowOffset:CGSizeMake(0, 3)];
    [self updateDropShadow:NO];
    [self updateSetShadowPath:NO];
    [self updateTheme:NO];
    [self updateImages];
}

- (void)updateImages
{
	UIEdgeInsets insets = [self.settings antiAliase]? UIEdgeInsetsMake(1, 0, 1, 0) : UIEdgeInsetsZero;

	CGRect leftRect = self.contentView.bounds;
	leftRect.size.width = CGRectGetWidth(self.contentView.bounds) / 2;
	CGRect rightRect = leftRect;
	rightRect.origin.x += leftRect.size.width;
    
    self.leftImage = [MPAnimation renderImage:self.contentView.image withRect:leftRect transparentInsets:insets];
    self.rightImage = [MPAnimation renderImage:self.contentView.image withRect:rightRect transparentInsets:insets];
}

- (void)updateDropShadow:(BOOL)animated
{
    CGFloat shadowOpacity = self.settings.useDropShadows? 0.5 : 0;
    if (!animated)
    {
        [self.contentView.layer setShadowOpacity:shadowOpacity];
        return;
    }
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        [self.contentView.layer setShadowOpacity:shadowOpacity];
        [self updateImages];
        [self.contentView.layer removeAnimationForKey:@"shadowOpacity"];
    }];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    CALayer *presentationLayer = self.contentView.layer.presentationLayer;
    animation.fromValue = @(presentationLayer.shadowOpacity);
    animation.toValue = @(shadowOpacity);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.contentView.layer addAnimation:animation forKey:@"shadowOpacity"];
    
    [CATransaction commit];
}

- (void)updateSetShadowPath:(BOOL)animated
{
    if (self.settings.setShadowPath)
        [[self.contentView layer] setShadowPath:[[UIBezierPath bezierPathWithRect:[self.contentView bounds]] CGPath]];
    else
        [[self.contentView layer] setShadowPath:nil];
    
    if (animated)
        [self updateImages];
}

- (void)updateAntialiase:(BOOL)animated
{
    [self updateImages];
}

- (void)updateTheme:(BOOL)animated
{
    NSString *imageName = nil;
    switch (self.settings.theme)
    {
        case ThemeRenaissance:
            imageName = @"RenaissanceIcon";
            break;
            
        case ThemeCocoaConf:
            imageName = @"CocoaConfIcon";
            break;
            
        case Theme360iDev:
            imageName = @"logo360";
            break;
    }
    
    UIImage *flipImage = [UIImage imageNamed:imageName];
    
    if (!animated)
    {
        self.contentView.image = flipImage;
        return;
    }
    
    CALayer *layer = [CALayer layer];
    layer.contents = (id)[flipImage CGImage];
    layer.opacity = 0;
    layer.frame = self.contentView.frame;
    [[[self.contentView superview] layer] addSublayer:layer];
    
    [CATransaction begin];

    [CATransaction setCompletionBlock:^{
        self.contentView.image = flipImage;
        [self updateImages];
        [layer removeAnimationForKey:@"opacity"];
        [layer removeFromSuperlayer];
    }];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"opacity"];
    
    [CATransaction commit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Gesture handlers

- (void)handleSwipe:(UIGestureRecognizer *)gestureRecognizer
{
	if ([self isAnimating] || [self isPanning])
		return;
	
	UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gestureRecognizer;
	
    NSLog(@"Swipe!");
	if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft)
        [self performFlipWithDirection:FlipDirectionForward];
	else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight)
		[self performFlipWithDirection:FlipDirectionBackward];
}

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if ([self isAnimating] || [self isPanning])
		return;
	
	CGPoint tapPoint = [gestureRecognizer locationInView:self.contentView];
	if (tapPoint.x <= MARGIN)
		[self performFlipWithDirection:FlipDirectionBackward];
	else if (tapPoint.x >= self.contentView.bounds.size.width - MARGIN)
		[self performFlipWithDirection:FlipDirectionForward];
}
	
- (CGFloat)progressFromPosition:(CGPoint)position
{
	// Determine where we are in our page turn animation
	// 0 - 1 means flipping the front-side of the page
	// 1 - 2 means flipping the back-side of the page
	BOOL isForward = (self.direction == FlipDirectionForward);
	
	CGFloat difference = position.x - self.panStart.x;
	CGFloat halfWidth = (self.contentView.frame.size.width / 2);
	CGFloat progress = difference / halfWidth * (isForward? - 1 : 1);
	if (progress < 0)
		progress = 0;
	if (progress > 2)
		progress = 2;
	return progress;
}

// switching between the 2 halves of the animation - between front and back sides of the page we're turning
- (void)switchToStage:(int)stageIndex
{
	// 0 = stage 1, 1 = stage 2
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	if (stageIndex == 0)
	{
		[self doFlip2:0];
		[self.layerFlipping addSublayer:self.layerFront];
		[self.layerReveal addSublayer:self.layerRevealShadow];
		[self.layerBack removeFromSuperlayer];
		[self.layerFacingShadow removeFromSuperlayer];
	}
	else
	{
		[self doFlip1:1];
		[self.layerFlipping addSublayer:self.layerBack];
		[self.layerFacing addSublayer:self.layerFacingShadow];
		[self.layerFront removeFromSuperlayer];
		[self.layerRevealShadow removeFromSuperlayer];
	}
	
	[CATransaction commit];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = [gestureRecognizer state];
	CGPoint currentPosition = [gestureRecognizer locationInView:self.contentView];
	
	if (state == UIGestureRecognizerStateBegan)
	{
		if ([self isAnimating])
			return;
		
		// See if touch started near one of the edges, in which case we'll pan a page turn
		if (currentPosition.x <= MARGIN)
			[self startFlipWithDirection:FlipDirectionBackward];
		else if (currentPosition.x >= self.contentView.bounds.size.width - MARGIN)
			[self startFlipWithDirection:FlipDirectionForward];
		else
		{
			// Do nothing for now, but it might become a swipe later
			return;
		}
		
		[self setAnimating:YES];
		[self setPanning:YES];
		self.panStart = currentPosition;
	}
	
	if ([self isPanning] && state == UIGestureRecognizerStateChanged)
	{
		CGFloat progress = [self progressFromPosition:currentPosition];
		BOOL wasFlipFrontPage = [self isFlipFrontPage];
		[self setFlipFrontPage:progress < 1];
		if (wasFlipFrontPage != [self isFlipFrontPage])
		{
			// switching between the 2 halves of the animation - between front and back sides of the page we're turning
			[self switchToStage:[self isFlipFrontPage]? 0 : 1];
		}
		if ([self isFlipFrontPage])
			[self doFlip1:progress];
		else
			[self doFlip2:progress - 1];
	}
	
	if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
	{
		CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
		
		if ([self isPanning])
        {
			// If moving slowly, let page fall either forward or back depending on where we were
			BOOL shouldFallBack = [self isFlipFrontPage];
			
			// But, if user was swiping in an appropriate direction, go ahead and honor that
            if (vel.x < SWIPE_LEFT_THRESHOLD)
            {
                // Detected a swipe to the left
                shouldFallBack = self.direction != FlipDirectionForward;
            }
            else if (vel.x > SWIPE_RIGHT_THRESHOLD)
            {
                // Detected a swipe to the right
                shouldFallBack = self.direction == FlipDirectionForward;
            }				
			
			// finishAnimation
			if (shouldFallBack != [self isFlipFrontPage])
			{
				// 2-stage animation (we're swiping either forward or back)
				CGFloat progress = [self progressFromPosition:currentPosition];
				if (([self isFlipFrontPage] && progress > 1) || (![self isFlipFrontPage] && progress < 1))
					progress = 1;
				if (progress > 1)
					progress -= 1;
				[self animateFlip1:shouldFallBack fromProgress:progress];
			}
			else
			{
				// 1-stage animation
				CGFloat fromProgress = [self progressFromPosition:currentPosition];
				if (!shouldFallBack)
					fromProgress -= 1;
				[self animateFlip2:shouldFallBack fromProgress:fromProgress];
			}
        }
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// don't recognize any further gestures if we're in the middle of animating a page-turn
	if ([self isAnimating])
		return NO;
	
	CGPoint currentPosition = [touch locationInView:self.contentView];
    BOOL nearEdge = currentPosition.x <= MARGIN || currentPosition.x >= (CGRectGetWidth(self.contentView.bounds) - MARGIN);
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return nearEdge;
    else
        return YES;//!nearEdge;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	// Allow simultanoues pan & swipe recognizers
	return NO;
}

#pragma mark - Animation

- (void)performFlipWithDirection:(FlipDirection)aDirection
{
	[self setAnimating:YES];
	[self startFlipWithDirection:aDirection];
	
	[self animateFlip1:NO fromProgress:0];
}

- (void)animateFlip1:(BOOL)shouldFallBack fromProgress:(CGFloat)fromProgress
{
	// 2-stage animation
	CALayer *layer = shouldFallBack? self.layerBack : self.layerFront;
	CALayer *flippingShadow = shouldFallBack? self.layerBackShadow : self.layerFrontShadow;
	CALayer *coveredShadow = shouldFallBack? self.layerFacingShadow : self.layerRevealShadow;
	
	if (shouldFallBack)
		fromProgress = 1 - fromProgress;
	CGFloat toProgress = 1;

	// Figure out how many frames we want
	CGFloat duration = (self.settings.duration / 2) * (toProgress - fromProgress);
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
	
	// Create a transaction
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:self.settings.cp1.x :self.settings.cp1.y :1 :1]];
	[CATransaction setCompletionBlock:^{
		// 2nd half of animation, once 1st half completes
		[self setFlipFrontPage:shouldFallBack];
		[self switchToStage:shouldFallBack? 0 : 1];
		
		[self animateFlip2:shouldFallBack fromProgress:shouldFallBack? 1 : 0];
	}];
	
	// Create the animation
	BOOL forwards = [self direction] == FlipDirectionForward;
	BOOL inward = NO;
	NSString *rotationKey = @"transform.rotation.y";
	double factor = (shouldFallBack? -1 : 1) * (forwards? -1 : 1) * M_PI / 180;

	// Flip front page from flat up to vertical
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:[NSNumber numberWithDouble:90 * factor * fromProgress]];
	[animation setToValue:[NSNumber numberWithDouble:90*factor]];
	[layer addAnimation:animation forKey:nil];
	[layer setTransform:CATransform3DMakeRotation(90*factor, 0, 1, 0)];

	// Shadows
	
	// darken front page just slightly as we flip (just to give it a crease where it touches facing page)
    if (self.settings.flipComponents & FlipComponentFacingShadow)
    {
        animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setFromValue:[NSNumber numberWithDouble:0.1 * fromProgress]];
        [animation setToValue:[NSNumber numberWithDouble:0.1]];
        [flippingShadow addAnimation:animation forKey:nil];
        [flippingShadow setOpacity:0.1];
    }
	
	if ((self.settings.flipComponents & FlipComponentRevealShadow) && !inward)
	{
		// lighten the page that is revealed by front page flipping up (along a cosine curve)
		// TODO: consider FROM value
		NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
		CGFloat progress;
		CGFloat cosOpacity;
		for (int frame = 0; frame <= frameCount; frame++)
		{
			progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
			//progress = (((float)frame) / frameCount);
			cosOpacity = cos(radians(90 * progress)) * (1./3);
			if (frame == frameCount)
				cosOpacity = 0;
			[arrayOpacity addObject:[NSNumber numberWithFloat:cosOpacity]];
		}
		
		CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		[keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
		[coveredShadow addAnimation:keyAnimation forKey:nil];
		[coveredShadow setOpacity:[[arrayOpacity lastObject] floatValue]];
	}
	
    if (self.settings.useDropShadows)
    {
        // shadow opacity should fade up from 0 to 0.5 at 12.5% progress then remain there through 100%
        NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
        CGFloat progress;
        CGFloat shadowProgress;
        for (int frame = 0; frame <= frameCount; frame++)
        {
            progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
            shadowProgress = progress * 8;
            if (shadowProgress > 1)
                shadowProgress = 1;
            
            [arrayOpacity addObject:[NSNumber numberWithFloat:0.25 * shadowProgress]];
        }
        
        CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
        [keyAnimation setCalculationMode:kCAAnimationLinear];
        [keyAnimation setValues:arrayOpacity];
        [layer addAnimation:keyAnimation forKey:nil];
        [layer setShadowOpacity:[[arrayOpacity lastObject] floatValue]];
    }
	
	// Commit the transaction for 1st half
	[CATransaction commit];
}

- (void)animateFlip2:(BOOL)shouldFallBack fromProgress:(CGFloat)fromProgress
{
	// 1-stage animation
	CALayer *layer = shouldFallBack? self.layerFront : self.layerBack;
	CALayer *flippingShadow = shouldFallBack? self.layerFrontShadow : self.layerBackShadow;
	CALayer *coveredShadow = shouldFallBack? self.layerRevealShadow : self.layerFacingShadow;
	
	// Figure out how many frames we want
	CGFloat duration = (self.settings.duration) / 2;
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
	
	// Build an array of keyframes (each a single transform)
	if (shouldFallBack)
		fromProgress = 1 - fromProgress;
	CGFloat toProgress = 1;
	
	// Create a transaction
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0 :0 :self.settings.cp2.x :self.settings.cp2.y]];
	[CATransaction setCompletionBlock:^{
		// once 2nd half completes
		[self endFlip:!shouldFallBack];
		
		// Clear flags
		[self setAnimating:NO];
		[self setPanning:NO];
	}];
	
	// Create the animation
	BOOL forwards = [self direction] == FlipDirectionForward;
	BOOL inward = NO;
	NSString *rotationKey = @"transform.rotation.y";
	double factor = (shouldFallBack? -1 : 1) * (forwards? -1 : 1) * M_PI / 180;
	
	// Flip back page from vertical down to flat
	CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation2 setFromValue:[NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
	[animation2 setToValue:[NSNumber numberWithDouble:0]];
	[animation2 setFillMode:kCAFillModeForwards];
	[animation2 setRemovedOnCompletion:NO];
	[layer addAnimation:animation2 forKey:nil];
	[layer setTransform:CATransform3DIdentity];
	
	// Shadows
	
	// Lighten back page just slightly as we flip (just to give it a crease where it touches reveal page)
    if (self.settings.flipComponents & FlipComponentFacingShadow)
    {
        animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation2 setFromValue:[NSNumber numberWithDouble:0.1 * (1-fromProgress)]];
        [animation2 setToValue:[NSNumber numberWithDouble:0]];
        [animation2 setFillMode:kCAFillModeForwards];
        [animation2 setRemovedOnCompletion:NO];
        [flippingShadow addAnimation:animation2 forKey:nil];
        [flippingShadow setOpacity:0];
    }
	
	if ((self.settings.flipComponents & FlipComponentRevealShadow) && !inward)
	{
		// Darken facing page as it gets covered by back page flipping down (along a sine curve)
		NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
		CGFloat progress;
		CGFloat sinOpacity;
		for (int frame = 0; frame <= frameCount; frame++)
		{
			progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
			sinOpacity = (sin(radians(90 * progress))* (1./3));
			if (frame == 0)
				sinOpacity = 0;
			[arrayOpacity addObject:[NSNumber numberWithFloat:sinOpacity]];
		}
		
		CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		[keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
		[coveredShadow addAnimation:keyAnimation forKey:nil];
		[coveredShadow setOpacity:[[arrayOpacity lastObject] floatValue]];
	}
	
    if (self.settings.useDropShadows)
    {
        // shadow opacity on flipping page should be 0.5 through 87.5% progress then fade to 0 at 100%
        NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
        CGFloat progress;
        CGFloat shadowProgress;
        for (int frame = 0; frame <= frameCount; frame++)
        {
            progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
            shadowProgress = (1 - progress) * 8;
            if (shadowProgress > 1)
                shadowProgress = 1;
            
            [arrayOpacity addObject:[NSNumber numberWithFloat:0.25 * shadowProgress]];
        }
        
        CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
        [keyAnimation setCalculationMode:kCAAnimationLinear];
        [keyAnimation setValues:arrayOpacity];
        [layer addAnimation:keyAnimation forKey:nil];
        [layer setShadowOpacity:[[arrayOpacity lastObject] floatValue]];
	}
    
	// Commit the transaction
	[CATransaction commit];
}

- (void)startFlipWithDirection:(FlipDirection)aDirection
{
	self.direction = aDirection;
	[self setFlipFrontPage:YES];
	
	[self buildLayers:aDirection];

	// set the back page in the vertical position (midpoint of animation)
	[self doFlip2:0];
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

- (void)buildLayers:(FlipDirection)aDirection
{
    CGPoint anchorPoint = [self anchorPoint];
	BOOL forwards = aDirection == FlipDirectionForward;
	BOOL inward = (self.settings.skewMode == SkewModeInverse);
	
	CGRect bounds = self.contentView.bounds;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	// we inset the panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets insets = [self.settings antiAliase]? UIEdgeInsetsMake(1, 0, 1, 0) : UIEdgeInsetsZero;
	
	CGRect leftRect = bounds;
	leftRect.size.width = bounds.size.width / 2;
	CGRect rightRect = leftRect;
	rightRect.origin.x += leftRect.size.width;
	
	// Create 4 images to represent 2 halves of the 2 views
	
	// The page flip animation is broken into 2 halves
	// 1. Flip old page up to vertical
	// 2. Flip new page from vertical down to flat
	// as we pass the halfway point of the animation, the "page" switches from old to new
	
	// front Page  = the half of current view we are flipping during 1st half
	// facing Page = the other half of the current view (doesn't move, gets covered by back page during 2nd half)
	// back Page   = the half of the next view that appears on the flipping page during 2nd half
	// reveal Page = the other half of the next view (doesn't move, gets revealed by front page during 1st half)
	UIImage *pageFrontImage = forwards? self.rightImage : self.leftImage;
	UIImage *pageFacingImage = forwards? self.leftImage : self.rightImage;
	
	UIImage *pageBackImage = forwards? self.leftImage : self.rightImage;
	UIImage *pageRevealImage = forwards? self.rightImage : self.leftImage;
	
	UIView *containerView = [self.contentView superview];
	//[self.contentView setHidden:YES];
	
	CATransform3D transform = CATransform3DIdentity;
	
	CGFloat width = bounds.size.height;
	CGFloat height = bounds.size.width/2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	
	// view to hold all our sublayers
	self.animationView = [[UIView alloc] initWithFrame:self.contentView.frame];
	self.animationView.backgroundColor = [UIColor clearColor];
	[containerView insertSubview:self.animationView aboveSubview:self.contentView];
	
    self.layerFlipping = [CALayer layer];
    self.layerFlipping.anchorPoint = anchorPoint;
    self.layerFlipping.zPosition = 256;
    self.layerFlipping.frame = self.animationView.bounds;
    self.layerFlipping.masksToBounds = NO;
    [self.animationView.layer addSublayer:self.layerFlipping];
    
	self.layerReveal = [CALayer layer];
	self.layerReveal.frame = (CGRect){CGPointZero, pageRevealImage.size};
	self.layerReveal.anchorPoint = CGPointMake(forwards? 0 : 1, 0.5);
	self.layerReveal.position = CGPointMake(upperHeight, width/2);
	[self.layerReveal setContents:(id)[pageRevealImage CGImage]];
	[self.animationView.layer addSublayer:self.layerReveal];
	
	self.layerFacing = [CALayer layer];
	self.layerFacing.frame = (CGRect){CGPointZero, pageFacingImage.size};
	self.layerFacing.anchorPoint = CGPointMake(forwards? 1 : 0, 0.5);
	self.layerFacing.position = CGPointMake(upperHeight, width/2);
	[self.layerFacing setContents:(id)[pageFacingImage CGImage]];
	[self.animationView.layer addSublayer:self.layerFacing];
	
	self.layerFront = [CALayer layer];
    self.layerFront.doubleSided = YES;
	self.layerFront.frame = (CGRect){CGPointZero, pageFrontImage.size};
	self.layerFront.anchorPoint = CGPointMake(forwards? 0 : 1, 0.5);
	self.layerFront.position = CGPointMake(upperHeight, width/2);
	[self.layerFront setContents:(id)[pageFrontImage CGImage]];
	[self.layerFlipping addSublayer:self.layerFront];
	
	self.layerBack = [CALayer layer];
	self.layerBack.frame = (CGRect){CGPointZero, pageBackImage.size};
	self.layerBack.anchorPoint = CGPointMake(forwards? 1 : 0, 0.5);
	self.layerBack.position = CGPointMake(upperHeight, width/2);
	[self.layerBack setContents:(id)[pageBackImage CGImage]];
	
	// Create shadow layers
    if (self.settings.flipComponents & FlipComponentFacingShadow)
    {
        self.layerFrontShadow = [CAGradientLayer layer];
        [self.layerFront addSublayer:self.layerFrontShadow];
        self.layerFrontShadow.frame = CGRectInset(self.layerFront.bounds, insets.left, insets.top);
        self.layerFrontShadow.opacity = 0.0;
        if (forwards)
            self.layerFrontShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], (id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
        else
            self.layerFrontShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[UIColor blackColor].CGColor, (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], nil];
        self.layerFrontShadow.startPoint = CGPointMake(forwards? 0 : 0.5, 0.5);
        self.layerFrontShadow.endPoint = CGPointMake(forwards? 0.5 : 1, 0.5);
        self.layerFrontShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:forwards? 0.1 : 0.9], [NSNumber numberWithDouble:1], nil];
        
        self.layerBackShadow = [CAGradientLayer layer];
        [self.layerBack addSublayer:self.layerBackShadow];
        self.layerBackShadow.frame = CGRectInset(self.layerBack.bounds, insets.left, insets.top);
        self.layerBackShadow.opacity = 0.1;
        if (forwards)
            self.layerBackShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[UIColor blackColor].CGColor, (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], nil];
        else
            self.layerBackShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], (id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
        self.layerBackShadow.startPoint = CGPointMake(forwards? 0.5 : 0, 0.5);
        self.layerBackShadow.endPoint = CGPointMake(forwards? 1 : 0.5, 0.5);
        self.layerBackShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:forwards? 0.9 : 0.1], [NSNumber numberWithDouble:1], nil];
	}
    
	if ((self.settings.flipComponents & FlipComponentRevealShadow) && !inward)
	{
        // gradient shadows going from black at center (spine) to 50% black at outer edges (margins)
		self.layerRevealShadow = [CAGradientLayer layer];
		[self.layerReveal addSublayer:self.layerRevealShadow];
		self.layerRevealShadow.frame = CGRectInset(self.layerReveal.bounds, insets.left, insets.top);
		self.layerRevealShadow.opacity = 0.5;
        self.layerRevealShadow.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor];
        self.layerRevealShadow.startPoint = CGPointMake(forwards? 0 : 1, 0.5);
        self.layerRevealShadow.endPoint = CGPointMake(forwards? 1 : 0, 0.5);
		
		self.layerFacingShadow = [CAGradientLayer layer];
		//[self.layerFacing addSublayer:self.layerFacingShadow];
		self.layerFacingShadow.frame = CGRectInset(self.layerFacing.bounds, insets.left, insets.top);
		self.layerFacingShadow.opacity = 0.0;
        self.layerFacingShadow.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor];
        self.layerFacingShadow.startPoint = CGPointMake(forwards? 1 : 0, 0.5);
        self.layerFacingShadow.endPoint = CGPointMake(forwards? 0 : 1, 0.5);
	}
	
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	if (self.settings.skewMode == SkewModeNone)
		transform.m34 = 0;
	else
		transform.m34 = 1 / (height * self.settings.skewMultiplier);
	self.layerFlipping.sublayerTransform = transform;
	
    if (self.settings.useDropShadows)
    {
        // set drop shadows on the 2 pages we'll be animating
        self.layerFront.shadowOffset = CGSizeMake(0,3);
        CGRect pathRect = CGRectInset([self.layerFront bounds], insets.left, insets.top);
        // reduce shadow path near center (spine) to (a) prevent bleed-over onto facing page,
        // and (b) reduce artifacts from double shadows (turning page + page below) where they join at spine
        if (forwards)
            pathRect.origin.x += SPINE_SHADOW_OFFSET;
        else
            pathRect.size.width -= SPINE_SHADOW_OFFSET;
        
        if ([self.settings setShadowPath])
            [self.layerFront setShadowPath:[[UIBezierPath bezierPathWithRect:pathRect] CGPath]];
        self.layerBack.shadowOpacity = 0.25;
        self.layerBack.shadowOffset = CGSizeMake(0,3);
        pathRect = CGRectInset([self.layerBack bounds], insets.left, insets.top);
        if (forwards)
            pathRect.size.width -= SPINE_SHADOW_OFFSET;
        else
            pathRect.origin.x += SPINE_SHADOW_OFFSET;
        if ([self.settings setShadowPath])
            [self.layerBack setShadowPath:[[UIBezierPath bezierPathWithRect:pathRect] CGPath]];
    }
}

 - (void)doFlip1:(CGFloat)progress
{
	[CATransaction begin];
    [CATransaction setAnimationDuration:0.1];
	//[CATransaction setDisableActions:YES];

	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;

	[self.layerFront setTransform:[self flipTransform1:progress]];
    if (self.settings.flipComponents & FlipComponentFacingShadow)
        [self.layerFrontShadow setOpacity:0.1 * progress];
    if (self.settings.flipComponents & FlipComponentRevealShadow)
    {
        CGFloat cosOpacity = cos(radians(90 * progress)) * (1./3);
        [self.layerRevealShadow setOpacity:cosOpacity];
	}
    
    if (self.settings.useDropShadows)
    {
        // shadow opacity should fade up from 0 to 0.5 at 12.5% progress then remain there through 100%
        CGFloat shadowProgress = progress * 8;
        if (shadowProgress > 1)
            shadowProgress = 1;
        [self.layerFront setShadowOpacity:0.25 * shadowProgress];
    }
    
	[CATransaction commit];
}
 
 - (void)doFlip2:(CGFloat)progress
{
	[CATransaction begin];
    [CATransaction setAnimationDuration:0.1];
	//[CATransaction setDisableActions:YES];

	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;
	
	[self.layerBack setTransform:[self flipTransform2:progress]];
    if (self.settings.flipComponents & FlipComponentFacingShadow)
        [self.layerBackShadow setOpacity:0.1 * (1- progress)];
    if (self.settings.flipComponents & FlipComponentRevealShadow)
    {
        CGFloat sinOpacity = sin(radians(90 * progress)) * (1./3);
        [self.layerFacingShadow setOpacity:sinOpacity];
	}
    
    if (self.settings.useDropShadows)
    {
        // shadow opacity on flipping page should be 0.5 through 87.5% progress then fade to 0 at 100%
        CGFloat shadowProgress = (1 - progress) * 8;
        if (shadowProgress > 1)
            shadowProgress = 1;
        [self.layerBack setShadowOpacity:0.25 * shadowProgress];
    }
    
	[CATransaction commit];
}
	 
- (CATransform3D)flipTransform1:(CGFloat)progress
{
	CATransform3D tHalf1 = CATransform3DIdentity;

	// rotate away from viewer
	BOOL isForward = (self.direction == FlipDirectionForward);
	tHalf1 = CATransform3DRotate(tHalf1, radians(ANGLE * progress * (isForward? -1 : 1)), 0, 1, 0);
	
	return tHalf1;
}

- (CATransform3D)flipTransform2:(CGFloat)progress
{
	CATransform3D tHalf2 = CATransform3DIdentity;

	// rotate away from viewer
	BOOL isForward = (self.direction == FlipDirectionForward);
	tHalf2 = CATransform3DRotate(tHalf2, radians(ANGLE * (1 - progress)) * (isForward? 1 : -1), 0, 1, 0);

	return tHalf2;
}

- (void)endFlip:(BOOL)completed
{
	// cleanup	
	[self.animationView removeFromSuperview];
	self.animationView = nil;
	self.layerFront = nil;
	self.layerBack = nil;
	self.layerFacing = nil;
	self.layerReveal = nil;
	self.layerFrontShadow = nil;
	self.layerBackShadow = nil;
	self.layerFacingShadow = nil;
	self.layerRevealShadow = nil;
    self.layerFlipping = nil;
	
	[self.contentView setHidden:NO];
}

#pragma mark - Class Methods

+ (NSString *)storyboardID
{
    return @"FlipID";
}

@end
