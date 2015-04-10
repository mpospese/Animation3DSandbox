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
#import "CMSAnimationTypeTableController.h"

@interface CMSSettingsController()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timingCurveLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *ballComponentMoveCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ballComponentScaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ballComponentOpacityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *foldComponentBoundsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *foldComponentOpacityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *flipComponentFacingShadowCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *flipComponentRevealShadowCell;
@property (weak, nonatomic) IBOutlet UILabel *anchorPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropShadowsLabel;
@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UILabel *skewModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *setShadowPathLabel;
@property (weak, nonatomic) IBOutlet UILabel *antiAliaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;

@end

@implementation CMSSettingsController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.settings = [CMSSettingsInfo new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateData];
}

- (void)reloadData
{
    [self.tableView reloadData];
    [self updateData];
}

- (void)updateData
{
    [self updateTypeLabel];
    [self updateDurationLabel];
    [self updateTimingCurveLabel];
    
    [self updateBallComponents];
    [self updateFoldComponents];
    [self updateFlipComponents];
    
    [self updateDropShadowsLabel];
    [self updateAnchorPointLabel];
    [self updateBackgroundLabel];
    [self updateSkewModeLabel];
    [self updateSetShadowPathLabel];
    [self updateAntiAliaseLabel];
    [self updateThemeLabel];
}

- (void)setSettings:(CMSSettingsInfo *)settings
{
    if ([self.settings isEqual:settings])
        return;
    
    if (self.settings)
    {
        [self.settings removeObserver:self forKeyPath:@"type"];
    }
    
    _settings = settings;
    
    if (settings)
    {
       [settings addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[CMSTimingCurveController class]])
    {
        CMSTimingCurveController *curveController = (CMSTimingCurveController *)segue.destinationViewController;
        curveController.settings = self.settings;
    }
    else if ([segue.destinationViewController isKindOfClass:[CMSAnchorPointTable class]])
    {
        CMSAnchorPointTable *anchorTable = (CMSAnchorPointTable *)segue.destinationViewController;
        anchorTable.settings = self.settings;
    }
    else if ([segue.destinationViewController isKindOfClass:[CMSAnimationTypeTableController class]])
    {
        CMSAnimationTypeTableController *typeController = (CMSAnimationTypeTableController *)segue.destinationViewController;
        typeController.settings = self.settings;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case CMSSettingsSectionBallComponents:
            return self.settings.type == AnimationTypeBall? self.tableView.sectionHeaderHeight : 0;
            
        case CMSSettingsSectionFoldComponents:
            return self.settings.type == AnimationTypeFold? self.tableView.sectionHeaderHeight : 0;
            
        case CMSSettingsSectionFlipComponents:
            return self.settings.type == AnimationTypeFlip? self.tableView.sectionHeaderHeight : 0;
            
        default:
            return self.tableView.sectionHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CMSSettingsSectionBallComponents:
            return self.settings.type == AnimationTypeBall? self.tableView.rowHeight : 0;
            
        case CMSSettingsSectionFoldComponents:
            return self.settings.type == AnimationTypeFold? self.tableView.rowHeight : 0;
            
        case CMSSettingsSectionFlipComponents:
            return self.settings.type == AnimationTypeFlip? self.tableView.rowHeight : 0;
            
        default:
            return self.tableView.rowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForSelectedRow]])
    {
        switch (indexPath.section) {
            case CMSSettingsSectionAnimation:
                switch (indexPath.row) {
                    case CMSSettingsAnimationRowType:
                        break;
                        
                    case CMSSettingsAnimationRowDuration:
                        [self setNextDuration];
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
                        
                    case CMSSettingsViewRowBackground:
                        self.settings.useBackground = !self.settings.useBackground;
                        [self updateBackgroundLabel];
                        break;
                        
                    case CMSSettingsViewRowSkew:
                        self.settings.skewMode = (self.settings.skewMode + 1) % (SkewModeHigh + 1);
                        [self updateSkewModeLabel];
                        break;
                        
                    case CMSSettingsViewRowSetShadowPath:
                        self.settings.setShadowPath = !self.settings.setShadowPath;
                        [self updateSetShadowPathLabel];
                        break;
                        
                    case CMSSettingsViewRowAntiAliase:
                        self.settings.antiAliase = !self.settings.antiAliase;
                        [self updateAntiAliaseLabel];
                       break;
                        
                    case CMSSettingsViewRowTheme:
                        self.settings.theme = (self.settings.theme + 1) % (Theme360iDev + 1);
                        [self updateThemeLabel];
                        break;
               }
                break;
        }        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CMSSettingsSectionBallComponents:
            if (self.settings.ballComponents & (1 << indexPath.row))
                self.settings.ballComponents &= ~(1 << indexPath.row);
            else
                self.settings.ballComponents |= (1 << indexPath.row);
            [self updateBallComponents];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case CMSSettingsSectionFoldComponents:
            if (self.settings.foldComponents & (1 << indexPath.row))
                self.settings.foldComponents &= ~(1 << indexPath.row);
            else
                self.settings.foldComponents |= (1 << indexPath.row);
            [self updateFoldComponents];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case CMSSettingsSectionFlipComponents:
            if (self.settings.flipComponents & (1 << indexPath.row))
                self.settings.flipComponents &= ~(1 << indexPath.row);
            else
                self.settings.flipComponents |= (1 << indexPath.row);
            [self updateFlipComponents];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        default:
            break;
    }
}

#pragma mark - Animation section

- (void)setNextDuration
{
    if (self.settings.duration <= 0.01)
        self.settings.duration = 0.1;
    else if (self.settings.duration <= 0.1)
        self.settings.duration = 0.2;
    else if (self.settings.duration <= 0.2)
        self.settings.duration = 0.25;
    else if (self.settings.duration <= 0.25)
        self.settings.duration = 0.3;
    else if (self.settings.duration <= 0.3)
        self.settings.duration = 0.5;
    else if (self.settings.duration <= 0.5)
        self.settings.duration = 0.75;
    else if (self.settings.duration <= 0.75)
        self.settings.duration = 1;
    else if (self.settings.duration <= 1)
        self.settings.duration = 1.5;
    else if (self.settings.duration <= 1.5)
        self.settings.duration = 2;
    else if (self.settings.duration <= 2)
        self.settings.duration = 2.5;
    else if (self.settings.duration <= 2.5)
        self.settings.duration = 3;
    else if (self.settings.duration <= 3)
        self.settings.duration = 5;
    else if (self.settings.duration <= 5)
        self.settings.duration = 7.5;
    else if (self.settings.duration <= 7.5)
        self.settings.duration = 10;
    else if (self.settings.duration <= 10)
        self.settings.duration = 0.01;
    [self updateDurationLabel];
}

- (void)updateDurationLabel
{
    [self.durationLabel setText:[NSString stringWithFormat:@"%.2f sec", self.settings.duration]];
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

- (void)updateTypeLabel
{
    NSString *text = nil;
    switch ([self.settings type]) {
        case AnimationTypeBall:
            text = @"Ball";
            break;
            
        case AnimationTypeFlip:
            text = @"Flip";
            break;
            
        case AnimationTypeFold:
            text = @"Fold";
            break;
    }
    
    self.typeLabel.text = text;
}

#pragma mark - Components section

- (void)updateBallComponents
{
    self.ballComponentMoveCell.accessoryType = (self.settings.ballComponents & BallComponentMove)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.ballComponentScaleCell.accessoryType = (self.settings.ballComponents & BallComponentScale)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.ballComponentOpacityCell.accessoryType = (self.settings.ballComponents & BallComponentOpacity)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)updateFoldComponents
{
    self.foldComponentBoundsCell.accessoryType = (self.settings.foldComponents & FoldComponentBounds)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.foldComponentOpacityCell.accessoryType = (self.settings.foldComponents & FoldComponentOpacity)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)updateFlipComponents
{
    self.flipComponentFacingShadowCell.accessoryType = (self.settings.flipComponents & FlipComponentFacingShadow)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.flipComponentRevealShadowCell.accessoryType = (self.settings.flipComponents & FlipComponentRevealShadow)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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

- (void)updateBackgroundLabel
{
    [self.backgroundLabel setText:self.settings.useBackground? @"Yes" : @"No"];
}

- (void)updateSkewModeLabel
{
    switch (self.settings.skewMode) {
        case SkewModeInverse:
            self.skewModeLabel.text = @"Inverse";
            break;
            
        case SkewModeNone:
            self.skewModeLabel.text = @"None";
            break;
            
        case SkewModeLow:
            self.skewModeLabel.text = @"Low";
            break;
            
        case SkewModeNormal:
            self.skewModeLabel.text = @"Normal";
            break;
            
        case SkewModeHigh:
            self.skewModeLabel.text = @"High";
            break;
    }
}

- (void)updateSetShadowPathLabel
{
    [self.setShadowPathLabel setText:self.settings.setShadowPath? @"Yes" : @"No"];
}

- (void)updateAntiAliaseLabel
{
    [self.antiAliaseLabel setText:self.settings.antiAliase? @"Yes" : @"No"];
}

- (void)updateThemeLabel
{
    switch (self.settings.theme) {
        case ThemeRenaissance:
            self.themeLabel.text = @"Renaissance";
            break;
            
        case ThemeCocoaConf:
            self.themeLabel.text = @"CocoaConf";
            break;
            
        case Theme360iDev:
            self.themeLabel.text = @"360iDev";
            break;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"type"])
    {
        [self reloadData];
    }
}

@end
