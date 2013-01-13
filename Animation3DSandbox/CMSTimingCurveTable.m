//
//  CMSTimingCurveTable.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSTimingCurveTable.h"

@interface CMSTimingCurveTable()

@end

@implementation CMSTimingCurveTable

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = (indexPath.row == self.timingCurve)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.timingCurve)
    {
        if (self.timingCurve != TimingCurveCustom)
        {
            NSIndexPath *oldPath = [NSIndexPath indexPathForRow:self.timingCurve inSection:0];
            self.timingCurve = indexPath.row;
            [tableView reloadRowsAtIndexPaths:@[indexPath, oldPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self.delegate timingCurveSelected:indexPath.row];
}

@end
