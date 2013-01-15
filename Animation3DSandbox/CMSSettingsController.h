//
//  CMSSettingsController.h
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMSSettingsInfo.h"

typedef enum 
{
    CMSSettingsSectionAnimation,
    CMSSettingsSectionComponents,
    CMSSettingsSectionView
} CMSSettingsSection;

typedef enum
{
    CMSSettingsAnimationRowDuration,
    CMSSettingsAnimationRowTimingCurve
} CMSSettingsAnimationRow;

typedef enum
{
    CMSSettingsComponentRowTransform,
    CMSSettingsComponentRowBounds,
    CMSSettingsComponentRowOpacity
} CMSSettingsComponentRow;

typedef enum
{
    CMSSettingsViewRowDropShadow,
    CMSSettingsViewRowAnchorPoint
} CMSSettingsViewRow;

@interface CMSSettingsController : UITableViewController

@property (nonatomic, strong) CMSSettingsInfo *settings;

@end
