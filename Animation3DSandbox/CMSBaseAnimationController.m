//
//  CMSBaseAnimationController.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/13/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSBaseAnimationController.h"

@interface CMSBaseAnimationController()

@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation CMSBaseAnimationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    self.backgroundView.frame = self.view.bounds;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    [self updateBackground:NO];
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
        [self.settings removeObserver:self forKeyPath:@"useBackground"];
        [self.settings removeObserver:self forKeyPath:@"theme"];
    }
    
    _settings = settings;
    
    if (settings)
    {
        [settings addObserver:self forKeyPath:@"anchorPoint" options:NSKeyValueObservingOptionNew context:nil];
        [settings addObserver:self forKeyPath:@"useDropShadows" options:NSKeyValueObservingOptionNew context:nil];
        [settings addObserver:self forKeyPath:@"useBackground" options:NSKeyValueObservingOptionNew context:nil];
        [settings addObserver:self forKeyPath:@"theme" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"anchorPoint"])
    {
        [self updateAnchorPoint:YES];
    }
    else if ([keyPath isEqualToString:@"useDropShadows"])
    {
        [self updateDropShadow:YES];
    }
    else if ([keyPath isEqualToString:@"useBackground"])
    {
        [self updateBackground:YES];
    }
    else if ([keyPath isEqualToString:@"theme"])
    {
        [self updateTheme:YES];
    }
}

- (void)updateAnchorPoint:(BOOL)animated
{
    
}

- (void)updateDropShadow:(BOOL)animated
{
    
}

- (void)updateBackground:(BOOL)animated
{
    CGFloat opacity = self.settings.useBackground? 1 : 0;
    if (!animated)
    {
        [self.backgroundView setAlpha: opacity];
        return;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.backgroundView setAlpha: opacity];
    } completion:nil];
}

- (void)updateTheme:(BOOL)animated
{
    
}


@end
