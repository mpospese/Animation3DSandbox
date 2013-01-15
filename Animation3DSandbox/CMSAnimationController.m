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
#import "CMSBallController.h"

@interface CMSAnimationController()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) CMSSettingsInfo *settings;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipe;
@property (nonatomic, strong) UITapGestureRecognizer *settingsTap;
@property (nonatomic, strong) UISwipeGestureRecognizer *settingsSwipe;
@property (nonatomic, strong) UIViewController *settingsController;

@end

@implementation CMSAnimationController

- (void)doInit
{
    _settings = [CMSSettingsInfo new];
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
    
    [self loadBallController];
    
	self.settingsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSettingsPanel:)];
    self.settingsSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeSettingsPanel:)];
    self.settingsSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	//[self.view addGestureRecognizer:self.settingsTap];
	    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    swipe.delegate = self;
    [self.mainView addGestureRecognizer:swipe];
    self.swipe = swipe;
}

- (void)loadFoldController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    FoldViewController *foldController = [storyboard instantiateViewControllerWithIdentifier:@"FoldID"];
    foldController.settings = self.settings;
    self.mainView = foldController.view;
    
    foldController.view.layer.shadowOpacity = 0.5;
    foldController.view.layer.shadowOffset = CGSizeMake(-3, 0);
    foldController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:foldController.view.bounds].CGPath;
    
    [self addChildViewController:foldController];
    foldController.view.frame = self.view.bounds;
    foldController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:foldController.view];
    [foldController didMoveToParentViewController:self];
}

- (void)loadBallController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CMSBallController *ballController = [storyboard instantiateViewControllerWithIdentifier:[CMSBallController storyboardID]];
    ballController.settings = self.settings;
    self.mainView = ballController.view;
    
    ballController.view.layer.shadowOpacity = 0.5;
    ballController.view.layer.shadowOffset = CGSizeMake(-3, 0);
    ballController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:ballController.view.bounds].CGPath;
    
    [self addChildViewController:ballController];
    ballController.view.frame = self.view.bounds;
    ballController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:ballController.view];
    [ballController didMoveToParentViewController:self];
}

#pragma mark - Gesture handlers

- (void)closeSettingsPanel:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] != UIGestureRecognizerStateEnded)
        return;
    
    [self.mainView removeGestureRecognizer:self.settingsTap];
    [self.mainView removeGestureRecognizer:self.settingsSwipe];
    
    [self showSettings:NO];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] != UIGestureRecognizerStateEnded)
        return;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CMSSettingsController *settings = [storyboard instantiateViewControllerWithIdentifier:@"SettingsID"];
    settings.settings = self.settings;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    navController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:navController];
    [navController.view setFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.bounds))];
    [self.view insertSubview:navController.view belowSubview:self.mainView];
    [navController didMoveToParentViewController:self];
    self.settingsController = navController;
    [self.mainView addGestureRecognizer:self.settingsTap];
    [self.view addGestureRecognizer:self.settingsSwipe];
    
    [self showSettings:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.swipe])
    {
        CGPoint point = [gestureRecognizer locationInView:self.view];
        if (point.x > 44)
            return NO;
    }
    
    return YES;
}

- (void)showSettings:(BOOL)show
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.3];//self.settings.duration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:self.settings.cp1.x :self.settings.cp1.y :self.settings.cp2.x :self.settings.cp2.y]];
    
    if (!show)
    {
        [CATransaction setCompletionBlock:^{
            [self.settingsController willMoveToParentViewController:nil];
            [self.settingsController.view removeFromSuperview];
            [self.settingsController removeFromParentViewController];
            self.settingsController = nil;
        }];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    CGPoint position = self.mainView.layer.position;
    position.x += (show? 1 : -1) * (CGRectGetWidth(self.settingsController.view.bounds));
    animation.fromValue = @([self.mainView.layer.presentationLayer position].x);
    animation.toValue = @(position.x);
    animation.fillMode = kCAFillModeForwards;
    self.mainView.layer.position = position;
    [self.mainView.layer addAnimation:animation forKey:@"position"];
    
    [CATransaction commit];
}



@end
