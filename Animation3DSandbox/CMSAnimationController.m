//
//  CMSAnimationController.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/13/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSAnimationController.h"
#import "CMSSettingsController.h"
#import <QuartzCore/QuartzCore.h>
#import "FoldViewController.h"
#import "FlipViewController.h"
#import "CMSBallController.h"

@interface CMSAnimationController()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) CMSSettingsInfo *settings;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UISwipeGestureRecognizer *settingsOpenSwipe;
@property (nonatomic, strong) UITapGestureRecognizer *settingsDismissTap;
@property (nonatomic, strong) UISwipeGestureRecognizer *settingsCloseSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipePreviousAnimation;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeNextAnimation;
@property (nonatomic, strong) UIViewController *settingsPane;
@property (nonatomic, strong) CMSSettingsController *settingsController;
@property (nonatomic, assign) AnimationType currentAnimation;
@property (nonatomic, strong) CMSBaseAnimationController *selectedController;
@property (nonatomic, assign, getter = isSettingsOpen) BOOL settingsOpen;

@end

@implementation CMSAnimationController

- (void)doInit
{
    _settings = [CMSSettingsInfo new];
    _currentAnimation = AnimationTypeFold;
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
    
    // Gestures
    self.settingsOpenSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    self.settingsOpenSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    self.settingsOpenSwipe.delegate = self;

	self.settingsDismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSettingsPanel:)];
    self.settingsCloseSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeSettingsPanel:)];
    self.settingsCloseSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.swipePreviousAnimation = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handle2FingerSwipe:)];
    self.swipePreviousAnimation.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipePreviousAnimation.numberOfTouchesRequired = 2;
    self.swipePreviousAnimation.delegate = self;
    
    self.swipeNextAnimation = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handle2FingerSwipe:)];
    self.swipeNextAnimation.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeNextAnimation.numberOfTouchesRequired = 2;
    self.swipeNextAnimation.delegate = self;
    
    // load controller
    [self loadController:self.currentAnimation offset:0];
}

- (void)didReceiveMemoryWarning
{
    if (!self.settingsPane.parentViewController)
    {
        self.settingsController = nil;
        self.settingsPane = nil;
    }
}

- (void)loadController:(AnimationType)type offset:(NSInteger)offset
{
    CMSBaseAnimationController *oldController = self.selectedController;
    
    NSString *storyboardIdentifier = nil;
    switch (type)
    {
        case AnimationTypeBall:
            storyboardIdentifier = [CMSBallController storyboardID];
            break;
            
        case AnimationTypeFold:
            storyboardIdentifier = [FoldViewController storyboardID];
            break;
            
        case AnimationTypeFlip:
            storyboardIdentifier = [FlipViewController storyboardID];
            break;
            
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CMSBaseAnimationController *controller = [storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier];
    controller.settings = self.settings;
    
    controller.view.layer.shadowOpacity = 0.5;
    controller.view.layer.shadowOffset = CGSizeMake(-3, 0);
    controller.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:controller.view.bounds].CGPath;
    
    [self addChildViewController:controller];
    controller.view.frame = CGRectOffset(self.view.bounds, offset * CGRectGetWidth(self.view.bounds), 0);
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (oldController && offset != 0)
            [[oldController view] setFrame:CGRectOffset(self.view.bounds, -1 * offset * CGRectGetWidth(self.view.bounds), 0)];
        controller.view.frame = self.view.bounds;
        
    } completion:^(BOOL finished) {
        [oldController willMoveToParentViewController:nil];
        [[oldController view] removeFromSuperview];
        [oldController removeFromParentViewController];
        [oldController setSettings:nil];
        
        self.selectedController = controller;
        self.mainView = controller.view;
        [self.mainView addGestureRecognizer:self.settingsOpenSwipe];
        [self.mainView addGestureRecognizer:self.swipePreviousAnimation];
        [self.mainView addGestureRecognizer:self.swipeNextAnimation];
        
        if (!self.settingsPane.parentViewController)
        {
            self.settingsController = nil;
            self.settingsPane = nil;
        }
    }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.settingsOpenSwipe])
    {
        CGPoint point = [gestureRecognizer locationInView:self.view];
        if (point.x > 44)
            return NO;
    }
    
    if ([gestureRecognizer isEqual:self.swipePreviousAnimation] || [gestureRecognizer isEqual:self.swipeNextAnimation])
        return !self.isSettingsOpen;
    
    return YES;
}

#pragma mark - Gesture handlers

- (void)closeSettingsPanel:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] != UIGestureRecognizerStateEnded)
        return;
    
    [self.mainView removeGestureRecognizer:self.settingsDismissTap];
    [self.view removeGestureRecognizer:self.settingsCloseSwipe];
    
    [self showSettings:NO];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] != UIGestureRecognizerStateEnded)
        return;
    
    [self initSettingsPane];
    [self showSettings:YES];
}

- (void)handle2FingerSwipe:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateEnded)
        return;
    
    int offset = (gesture.direction == UISwipeGestureRecognizerDirectionLeft)? 1 : -1;
    int type = ((int)self.currentAnimation + offset) % 3;
    if (type < 0)
        type += 3;
    self.currentAnimation = type;
    [self loadController:self.currentAnimation offset:offset];
}

- (void)initSettingsPane
{
    if (!self.settingsPane)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        self.settingsController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsID"];
        self.settingsController.settings = self.settings;
        self.settingsController.type = AnimationTypeBall;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.settingsController];
        navController.navigationBar.barStyle = UIBarStyleBlack;
        
        navController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.settingsPane = navController;
    }
    
    [self addChildViewController:self.settingsPane];
    [self.settingsPane.view setFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.bounds))];
    [self.view insertSubview:self.settingsPane.view belowSubview:self.mainView];
    [self.settingsPane didMoveToParentViewController:self];
    [self.mainView addGestureRecognizer:self.settingsDismissTap];
    [self.view addGestureRecognizer:self.settingsCloseSwipe];
    
    [self.settingsController setType:self.currentAnimation];
}

- (void)showSettings:(BOOL)show
{
    self.settingsOpen = show;
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.3];//self.settings.duration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:self.settings.cp1.x :self.settings.cp1.y :self.settings.cp2.x :self.settings.cp2.y]];
    
    if (!show)
    {
        [CATransaction setCompletionBlock:^{
            [self.settingsPane willMoveToParentViewController:nil];
            [self.settingsPane.view removeFromSuperview];
            [self.settingsPane removeFromParentViewController];
        }];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    CGPoint position = self.mainView.layer.position;
    position.x += (show? 1 : -1) * (CGRectGetWidth(self.settingsPane.view.bounds));
    animation.fromValue = @([self.mainView.layer.presentationLayer position].x);
    animation.toValue = @(position.x);
    animation.fillMode = kCAFillModeForwards;
    self.mainView.layer.position = position;
    [self.mainView.layer addAnimation:animation forKey:@"position"];
    
    [CATransaction commit];
}



@end
