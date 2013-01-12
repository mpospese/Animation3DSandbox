//
//  CMSAnchorPointTable.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSAnchorPointTable.h"

@implementation CMSAnchorPointTable

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = (indexPath.row == self.settings.anchorPoint)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.settings.anchorPoint)
    {
        NSIndexPath *oldPath = [NSIndexPath indexPathForRow:self.settings.anchorPoint inSection:0];
        self.settings.anchorPoint = indexPath.row;
        [tableView reloadRowsAtIndexPaths:@[indexPath, oldPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
