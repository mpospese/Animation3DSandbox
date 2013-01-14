//
//  CMSBallController.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/13/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSBallController.h"
#import <QuartzCore/QuartzCore.h>

@interface CMSBallController()

@property (weak, nonatomic) IBOutlet UIImageView *redBall;
@property (nonatomic, assign, getter = isLeft) BOOL left;

@end

@implementation CMSBallController

- (void)doInit
{
    _left = YES;
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
    
    self.redBall.layer.shadowOpacity = 0.5;
    self.redBall.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, CGRectGetHeight(self.redBall.bounds) - 13, CGRectGetWidth(self.redBall.bounds), 25)].CGPath;
    self.redBall.layer.shadowOffset = CGSizeMake(0, 0);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.redBall addGestureRecognizer:tap];
}

#pragma mark - Gesture recognizers

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if ([gesture state] != UIGestureRecognizerStateEnded)
        return;
    
    [self move];
}

- (void)move
{
    [self.redBall setUserInteractionEnabled:NO];
    
	[CATransaction begin];
	[CATransaction setAnimationDuration:self.settings.duration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:self.settings.cp1.x :self.settings.cp1.y :self.settings.cp2.x :self.settings.cp2.y]];
    
    CGFloat targetX = self.isLeft? CGRectGetWidth(self.view.bounds) - 50 - (CGRectGetWidth(self.redBall.bounds)/2) : 50 + (CGRectGetWidth(self.redBall.bounds)/2);
    CALayer *presentationLayer = self.redBall.layer.presentationLayer;
    CATransform3D targetTransform = self.isLeft? CATransform3DMakeScale(0.50, 0.50, 0) : CATransform3DIdentity;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = @(self.redBall.layer.position.x);
    animation.toValue = @(targetX);
    animation.fillMode = kCAFillModeForwards;
    [self.redBall.layer addAnimation:animation forKey:@"position"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:targetTransform];
    animation.fillMode = kCAFillModeForwards;
    [self.redBall.layer addAnimation:animation forKey:@"transform"];
    
	[CATransaction setCompletionBlock:^{
        self.redBall.center = CGPointMake(targetX, self.redBall.center.y);
        self.redBall.transform = CATransform3DGetAffineTransform(targetTransform);
		self.left = !self.isLeft;
        [self.redBall setUserInteractionEnabled:YES];
	}];
    
    [CATransaction commit];
}

#pragma mark - Class Methods

+ (NSString *)storyboardID
{
    return @"BallID";
}

@end
