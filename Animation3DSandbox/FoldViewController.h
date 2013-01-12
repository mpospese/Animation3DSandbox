//
//  FoldViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enumerations.h"

@interface FoldViewController : UIViewController

@property (nonatomic, assign) FoldComponent foldComponents;
@property (nonatomic, assign) BOOL useDropShadow;
@property (nonatomic, assign) AnchorPointLocation anchorPointType;

@end
