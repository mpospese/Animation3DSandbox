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
#import "CMSAnchorPointTable.h"
#import "CMSTimingCurveController.h"
#import "CMSAnimationTypeTableController.h"

@interface CMSAnimationController()<UISplitViewControllerDelegate>

@property (nonatomic, strong) CMSSettingsInfo *settings;

@end

@implementation CMSAnimationController

- (void)doInit
{
    _settings = [CMSSettingsInfo new];
    [_settings addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew context:nil];
    self.delegate = self;
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

- (void)dealloc
{
    [self.settings removeObserver:self forKeyPath:@"type"];
    _settings = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIViewController *primary = [self.viewControllers firstObject];
    CMSSettingsController *settingsController = [primary.childViewControllers firstObject];
    [settingsController setSettings:self.settings];

	// Do any additional setup after loading the view.
    
    // load controller
    [self loadController:self.settings.type];
}

- (void)didReceiveMemoryWarning
{
}

- (UIViewController *)primaryViewControllerForType:(AnimationType)type
{
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

    return controller;
}

- (void)loadController:(AnimationType)type
{
    UIViewController *controller = [self primaryViewControllerForType:type];
    [self showDetailViewController:controller sender:self];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"type"])
    {
        [self updateType:YES];
    }
}

- (void)updateType:(BOOL)animated
{
    [self loadController:self.settings.type];
}

#pragma mark - UISplitViewControllerDelegate

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController
{    
    return nil;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if (![primaryViewController isKindOfClass:[UINavigationController class]])
        return NO;
    
    UINavigationController *navController = (UINavigationController *)primaryViewController;
    if ([navController.viewControllers count] == 1)
        return NO;
    
    UIViewController *lastController = [navController.viewControllers lastObject];
    if ([lastController isKindOfClass:[CMSAnchorPointTable class]] || [lastController isKindOfClass:[CMSTimingCurveController class]])
    {
        // if we're drilled into Anchor Point table or Timing Curve Table,
        // don't collapse the animation view on top of it
        return YES;
    }
    else
    {
        // if we're drilled into the Animation Type Table, just get rid of it
        // so that animation view is collapsed directly on top of root
        [navController popToRootViewControllerAnimated:NO];
    }

    return NO;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    return nil;
}

- (UIViewController *)primaryViewControllerForExpandingSplitViewController:(UISplitViewController *)splitViewController
{
    NSArray *controllers = splitViewController.viewControllers;
    UINavigationController *navController = [controllers firstObject];
    UIViewController *lastController = [navController.viewControllers lastObject];
    
    if (![lastController isKindOfClass:[CMSBaseAnimationController class]])
    {
        // if there is no animation view, make one and put it on the end of the stack
        UIViewController *last = [self primaryViewControllerForType:self.settings.type];
        [navController pushViewController:last animated:NO];
    }
    else
    {
        NSArray *subControllers = [navController viewControllers];
        if ([subControllers count] == 3)
        {
            // when expanding back, pop to root in primary controller,
            // don't show the animation type picker on left
            if ([subControllers[1] isKindOfClass:[CMSAnimationTypeTableController class]])
            {
                [navController setViewControllers:@[subControllers[0], subControllers[2]]];
            }
        }
    }

    return nil;
}

@end
