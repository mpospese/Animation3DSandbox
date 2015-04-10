//
//  CMSAnimationTypeTableController.m
//  Animation3DSandbox
//
//  Created by Mark Pospesel on 4/10/15.
//  Copyright (c) 2015 Crazy Milk Software. All rights reserved.
//

#import "CMSAnimationTypeTableController.h"

@interface CMSAnimationTypeTableController ()

@end

@implementation CMSAnimationTypeTableController

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = (indexPath.row == self.settings.type)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.settings.type)
    {
        NSIndexPath *oldPath = [NSIndexPath indexPathForRow:self.settings.type inSection:0];
        self.settings.type = indexPath.row;
        [tableView reloadRowsAtIndexPaths:@[indexPath, oldPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
