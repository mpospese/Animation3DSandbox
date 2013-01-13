//
//  CMSTimingCurveTable.h
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enumerations.h"

@protocol CMSTimingCurveDelegate<NSObject>

- (void)timingCurveSelected:(TimingCurve)timingCurve;

@end

@interface CMSTimingCurveTable : UITableViewController

@property (nonatomic, weak) id<CMSTimingCurveDelegate> delegate;
@property (nonatomic, assign) TimingCurve timingCurve;

@end
