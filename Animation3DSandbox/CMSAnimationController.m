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

@end

@implementation CMSAnimationController

- (void)doInit
{
    _settings = [CMSSettingsInfo new];
    [_settings addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew context:nil];
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

- (void)loadController:(AnimationType)type
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

@end
