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
    
    self.redBall.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, CGRectGetHeight(self.redBall.bounds) - 13, CGRectGetWidth(self.redBall.bounds) - 40, 25)].CGPath;
    self.redBall.layer.shadowOffset = CGSizeMake(0, 0);
    self.redBall.layer.shadowRadius = 10;
    [self updateDropShadow:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.redBall addGestureRecognizer:tap];
}

- (void)updateDropShadow:(BOOL)animated
{
    CGFloat shadowOpacity = self.settings.useDropShadows? 0.5 : 0;
    if (!animated)
    {
        [self.redBall.layer setShadowOpacity:shadowOpacity];
        return;
    }
    
    [CATransaction begin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    CALayer *presentationLayer = self.redBall.layer.presentationLayer;
    animation.fromValue = @(presentationLayer.shadowOpacity);
    animation.toValue = @(shadowOpacity);
    [self.redBall.layer addAnimation:animation forKey:@"shadowOpacity"];
    
    [CATransaction setCompletionBlock:^{
        [self.redBall.layer setShadowOpacity:shadowOpacity];
    }];
    
    [CATransaction commit];
}

#pragma mark - Settings

- (void)setSettings:(CMSSettingsInfo *)settings
{
    if ([self.settings isEqual:settings])
        return;
    
    if (self.settings)
    {
        [self.settings removeObserver:self forKeyPath:@"anchorPoint"];
        [self.settings removeObserver:self forKeyPath:@"useDropShadows"];
    }
    
    [super setSettings:settings];
    
    if (settings)
    {
        [settings addObserver:self forKeyPath:@"anchorPoint" options:NSKeyValueObservingOptionNew context:nil];
        [settings addObserver:self forKeyPath:@"useDropShadows" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (CGPoint)anchorPoint
{
    CGPoint anchorPoint;
    
    switch (self.settings.anchorPoint) {
        case AnchorPointTopLeft:
            anchorPoint = CGPointMake(0, 0);
            break;
            
        case AnchorPointTopCenter:
            anchorPoint = CGPointMake(0.5, 0);
            break;
            
        case AnchorPointTopRight:
            anchorPoint = CGPointMake(1, 0);
            break;
            
        case AnchorPointMiddleLeft:
            anchorPoint = CGPointMake(0, 0.5);
            break;
            
        case AnchorPointCenter:
            anchorPoint = CGPointMake(0.5, 0.5);
            break;
            
        case AnchorPointMiddleRight:
            anchorPoint = CGPointMake(1, 0.5);
            break;
            
        case AnchorPointBottomLeft:
            anchorPoint = CGPointMake(0, 1);
            break;
            
        case AnchorPointBottomCenter:
            anchorPoint = CGPointMake(0.5, 1);
            break;
            
        case AnchorPointBottomRight:
            anchorPoint = CGPointMake(1, 1);
            break;
    }
    
    return anchorPoint;
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"anchorPoint"])
    {
        [CATransaction begin];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
        CALayer *presentationLayer = self.redBall.layer.presentationLayer;
        animation.fromValue = [NSValue valueWithCGPoint:presentationLayer.anchorPoint];
        animation.toValue = [NSValue valueWithCGPoint:[self anchorPoint]];
        [self.redBall.layer addAnimation:animation forKey:@"anchorPoint"];
        
        [CATransaction setCompletionBlock:^{
            self.redBall.layer.anchorPoint = [self anchorPoint];
        }];
        
        [CATransaction commit];
    }
    else if ([keyPath isEqualToString:@"useDropShadows"])
    {
        [self updateDropShadow:YES];
    }
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
    //CALayer *presentationLayer = self.redBall.layer.presentationLayer;
    //CATransform3D targetTransform = self.isLeft? CATransform3DMakeScale(0.50, 0.50, 0) : CATransform3DIdentity;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = @(self.redBall.layer.position.x);
    animation.toValue = @(targetX);
    animation.fillMode = kCAFillModeForwards;
    [self.redBall.layer addAnimation:animation forKey:@"position"];
    
    /*animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:targetTransform];
    animation.fillMode = kCAFillModeForwards;
    [self.redBall.layer addAnimation:animation forKey:@"transform"];*/
    
	[CATransaction setCompletionBlock:^{
        self.redBall.center = CGPointMake(targetX, self.redBall.center.y);
        //self.redBall.transform = CATransform3DGetAffineTransform(targetTransform);
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
