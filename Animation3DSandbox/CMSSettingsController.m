//
//  CMSSettingsController.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSSettingsController.h"
#import "CMSTimingCurveController.h"

@implementation CMSSettingsController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _settings = [CMSSettingsInfo new];
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CMSTimingCurveController class]])
    {
        CMSTimingCurveController *curveController = (CMSTimingCurveController *)segue.destinationViewController;
        curveController.settings = self.settings;
    }
}

@end
