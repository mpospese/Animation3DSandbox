//
//  CMSSettingsController.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSSettingsController.h"
#import "CMSTimingCurveController.h"
#import "CMSAnchorPointTable.h"

@interface CMSSettingsController()
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timingCurveLabel;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *componentTransformCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *componentBoundsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *componentOpacityCell;
@property (weak, nonatomic) IBOutlet UILabel *anchorPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropShadowsLabel;

@end

@implementation CMSSettingsController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _settings = [CMSSettingsInfo new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateDurationLabel];
    [self updateDelayLabel];
    [self updateTimingCurveLabel];
    
    [self updateComponents];

    [self updateDropShadowsLabel];
    [self updateAnchorPointLabel];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CMSTimingCurveController class]])
    {
        CMSTimingCurveController *curveController = (CMSTimingCurveController *)segue.destinationViewController;
        curveController.settings = self.settings;
    }
    if ([segue.destinationViewController isKindOfClass:[CMSAnchorPointTable class]])
    {
        CMSAnchorPointTable *anchorTable = (CMSAnchorPointTable *)segue.destinationViewController;
        anchorTable.settings = self.settings;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForSelectedRow]])
    {
        switch (indexPath.section) {
            case CMSSettingsSectionAnimation:
                switch (indexPath.row) {
                    case CMSSettingsAnimationRowDuration:
                        break;
                        
                    case CMSSettingsAnimationRowDelay:
                        break;
                        
                    case CMSSettingsAnimationRowTimingCurve:
                        break;
                }
                break;
                            
            case CMSSettingsSectionView:
                switch (indexPath.row) {
                    case CMSSettingsViewRowDropShadow:
                        self.settings.useDropShadows = !self.settings.useDropShadows;
                        [self updateDropShadowsLabel];
                        break;
                        
                    case CMSSettingsViewRowAnchorPoint:
                        break;
                }
                break;
        }        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CMSSettingsSectionComponents:
            if (self.settings.components & (1 << indexPath.row))
                self.settings.components &= ~(1 << indexPath.row);
            else
                self.settings.components |= (1 << indexPath.row);
            [self updateComponents];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CMSSettingsSectionAnimation:
            switch (indexPath.row) {
                /*case CMSSettingsAnimationRowDuration:
                    break;
                    
                case CMSSettingsAnimationRowDelay:
                    break;*/
                    
                case CMSSettingsAnimationRowTimingCurve:
                    [self updateTimingCurveLabel];
                    break;
            }
            break;
            
        case CMSSettingsSectionView:
            switch (indexPath.row) {
                case CMSSettingsViewRowDropShadow:
                    break;
                    
                case CMSSettingsViewRowAnchorPoint:
                    [self updateAnchorPointLabel];
                    break;
            }
            break;
    }
}

#pragma mark - Animation section

- (void)updateDurationLabel
{
    [self.durationLabel setText:[NSString stringWithFormat:@"%.3f sec", self.settings.duration]];
}

- (void)updateDelayLabel
{
    [self.delayLabel setText:[NSString stringWithFormat:@"%.3f sec", self.settings.delay]];
}

- (void)updateTimingCurveLabel
{
    NSString *text = nil;
    switch ([self.settings timingCurve]) {
        case TimingCurveLinear:
            text = @"Linear";
            break;
            
        case TimingCurveEaseIn:
            text = @"Ease-In";
            break;
            
        case TimingCurveEaseOut:
            text = @"Ease-Out";
            break;
            
        case TimingCurveEaseInOut:
            text = @"Ease-In Ease-Out";
            break;
            
        case TimingCurveDefault:
            text = @"Default";
            break;
           
        case TimingCurveCustom:
        default:
            text = @"Custom";
            break;
    }
    
    self.timingCurveLabel.text = text;
}

#pragma mark - Components section

- (void)updateComponents
{
    self.componentTransformCell.accessoryType = (self.settings.components & FoldComponentTransform)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.componentBoundsCell.accessoryType = (self.settings.components & FoldComponentBounds)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.componentOpacityCell.accessoryType = (self.settings.components & FoldComponentOpacity)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - View section

- (void)updateDropShadowsLabel
{
    [self.dropShadowsLabel setText:self.settings.useDropShadows? @"Yes" : @"No"];
}

- (void)updateAnchorPointLabel
{
    switch (self.settings.anchorPoint) {
        case AnchorPointTopLeft:
            self.anchorPointLabel.text = @"Top Left";
            break;
            
        case AnchorPointTopCenter:
            self.anchorPointLabel.text = @"Top Center";
            break;
            
        case AnchorPointTopRight:
            self.anchorPointLabel.text = @"Top Right";
            break;
            
        case AnchorPointMiddleLeft:
            self.anchorPointLabel.text = @"Middle Left";
            break;
            
        case AnchorPointCenter:
            self.anchorPointLabel.text = @"Center";
            break;
            
        case AnchorPointMiddleRight:
            self.anchorPointLabel.text = @"Middle Right";
            break;
            
        case AnchorPointBottomLeft:
            self.anchorPointLabel.text = @"Bottom Left";
            break;
            
        case AnchorPointBottomCenter:
            self.anchorPointLabel.text = @"Bottom Center";
            break;
            
        case AnchorPointBottomRight:
            self.anchorPointLabel.text = @"Bottom Right";
            break;
   }
}

@end
