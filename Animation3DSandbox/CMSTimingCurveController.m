//
//  CMSTimingCurveController.m
//  Animation3DSandbox
//
//  Created by Crazy Milk Software on 1/12/13.
//  Copyright (c) 2013 Crazy Milk Software. All rights reserved.
//

#import "CMSTimingCurveController.h"
#import <QuartzCore/QuartzCore.h>
#import "CMSTimingCurveTable.h"

@interface CMSTimingCurveController()<CMSTimingCurveDelegate>

@property (nonatomic, strong) CAShapeLayer *curve;
@property (nonatomic, strong) CAShapeLayer *graphInner;
@property (nonatomic, strong) CAShapeLayer *graphOuter;
@property (nonatomic, strong) CAShapeLayer *line1;
@property (nonatomic, strong) CAShapeLayer *line2;
@property (nonatomic, strong) UIView *pointView1;
@property (nonatomic, strong) UIView *pointView2;
@property (weak, nonatomic) IBOutlet UIView *curveContainer;
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) UIPopoverController *resetPopover;

@end

@implementation CMSTimingCurveController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *darkBrown = [UIColor colorWithRed:72./255 green:52./255 blue:37./255 alpha:1];
    UIColor *brown = [UIColor colorWithRed:160./255 green:110./255 blue:75./255 alpha:1];
    UIColor *green = [UIColor colorWithRed:39./255 green:126./255 blue:66./255 alpha:1];
    
    self.graphInner = [CAShapeLayer layer];
    self.graphInner.strokeColor = darkBrown.CGColor;
    self.graphInner.fillColor = [UIColor clearColor].CGColor;
    self.graphInner.lineWidth = 2;
    [self.view.layer addSublayer:self.graphInner];
    
    self.graphOuter = [CAShapeLayer layer];
    self.graphOuter.strokeColor = [darkBrown colorWithAlphaComponent:0.5].CGColor;
    self.graphOuter.fillColor = [UIColor clearColor].CGColor;
    self.graphOuter.lineWidth = 1;
    self.graphOuter.lineDashPattern = @[@6, @5];
    [self.view.layer addSublayer:self.graphOuter];
    
    self.line1 = [CAShapeLayer layer];
    self.line1.strokeColor = green.CGColor;
    self.line1.fillColor = [UIColor clearColor].CGColor;
    self.line1.lineWidth = 2;
    self.line1.lineDashPattern = @[@3, @3];
    [self.view.layer addSublayer:self.line1];
    
    self.line2 = [CAShapeLayer layer];
    self.line2.strokeColor = green.CGColor;
    self.line2.fillColor = [UIColor clearColor].CGColor;
    self.line2.lineWidth = 2;
    self.line2.lineDashPattern = @[@3, @3];
    [self.view.layer addSublayer:self.line2];
    
    _curve = [CAShapeLayer layer];
    _curve.strokeColor = brown.CGColor;
    _curve.fillColor = [UIColor clearColor].CGColor;
    _curve.lineWidth = 4;
    [self.view.layer addSublayer:_curve];
    
    _pointView1 = [self makePointView:@"1"];
    [self.view addSubview:self.pointView1];
    _pointView2 = [self makePointView:@"2"];
    [self.view addSubview:self.pointView2];
    
    [self.propertyLabel sizeToFit];
    [self.timeLabel sizeToFit];
    self.propertyLabel.transform = CGAffineTransformMakeRotation(-M_PI/2);
}

- (UIView *)makePointView:(NSString *)title
{
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    pointView.backgroundColor = [UIColor clearColor];
    pointView.alpha = 0.80;
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(8, 8, 28, 28)].CGPath;
    circle.fillColor = self.line1.strokeColor;
    circle.strokeColor = [UIColor colorWithRed:227./255 green:228./255 blue:190./255 alpha:1].CGColor;
    circle.lineWidth = 2;
    [pointView.layer addSublayer:circle];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.text = title;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [pointView addSubview:label];
    
    pointView.layer.shadowOpacity = 0.625;
    pointView.layer.shadowOffset = CGSizeMake(0,1);
    pointView.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(11, 11, 22, 22)].CGPath;
    
    UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [pointView addGestureRecognizer:pan1];
    
    return pointView;
}

- (CGRect)curveRect
{
    return self.curveContainer.frame;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect rect = [self curveRect];

    UIBezierPath *pathInner = [UIBezierPath bezierPath];
    [pathInner moveToPoint:rect.origin];
    [pathInner addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    [pathInner addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    self.graphInner.path = pathInner.CGPath;
    
    UIBezierPath *pathOuter = [UIBezierPath bezierPath];
    [pathOuter moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + 0.5)];
    [pathOuter addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - 0.5, CGRectGetMinY(rect) + 0.5)];
    [pathOuter addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - 0.5, CGRectGetMaxY(rect))];
    self.graphOuter.path = pathOuter.CGPath;
    
    self.propertyLabel.center = CGPointMake(CGRectGetMinX(rect) / 2 - 3, CGRectGetMidY(rect));
    self.timeLabel.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect) + 8 + CGRectGetHeight(self.timeLabel.bounds)/2);
    
    [self updatePaths:0.1 animateLines:NO];
}

- (void)updatePaths:(CGFloat)duration animateLines:(BOOL)animateLines
{
    CGRect rect = [self curveRect];
    UIBezierPath *pathCurve = [UIBezierPath bezierPath];
    [pathCurve moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    
    CGPoint cp1 = CGPointMake(CGRectGetMinX(rect) + self.settings.cp1.x * CGRectGetWidth(rect), CGRectGetMaxY(rect) - (self.settings.cp1.y * CGRectGetHeight(rect)));
    CGPoint cp2 = CGPointMake(CGRectGetMinX(rect) + self.settings.cp2.x * CGRectGetWidth(rect), CGRectGetMaxY(rect) - (self.settings.cp2.y * CGRectGetHeight(rect)));
    
    [pathCurve addCurveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)) controlPoint1:cp1 controlPoint2:cp2];
    
    UIBezierPath *pathLine1 = [UIBezierPath bezierPath];
    [pathLine1 moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    [pathLine1 addLineToPoint:cp1];
    
    UIBezierPath *pathLine2 = [UIBezierPath bezierPath];
    [pathLine2 moveToPoint:cp2];
    [pathLine2 addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    
    CABasicAnimation *animation;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    
    animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = [self.curve.presentationLayer path];
    animation.toValue = (id)pathCurve.CGPath;
    self.curve.path = pathCurve.CGPath;
    [self.curve addAnimation:animation forKey:@"path"];
    
    if (animateLines)
    {
        animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.fromValue = [self.line1.presentationLayer path];
        animation.toValue = (id)pathLine1.CGPath;
        [self.line1 addAnimation:animation forKey:@"path"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.fromValue = [self.line2.presentationLayer path];
        animation.toValue = (id)pathLine2.CGPath;
        [self.line2 addAnimation:animation forKey:@"path"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:self.pointView1.layer.position];
        animation.toValue = [NSValue valueWithCGPoint:cp1];
        animation.fillMode = kCAFillModeForwards;
        [self.pointView1.layer addAnimation:animation forKey:@"position"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:self.pointView2.layer.position];
        animation.toValue = [NSValue valueWithCGPoint:cp2];
        animation.fillMode = kCAFillModeForwards;
        [self.pointView2.layer addAnimation:animation forKey:@"position"];
        
        [CATransaction setCompletionBlock:^{
            self.pointView1.center = cp1;
            self.pointView2.center = cp2;
        }];
    }
    else
    {
        self.pointView1.center = cp1;
        self.pointView2.center = cp2;
    }

    self.line1.path = pathLine1.CGPath;
    self.line2.path = pathLine2.CGPath;
    
    [CATransaction commit];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed)
        return;
    
    BOOL isPoint1 = [gestureRecognizer.view isEqual:self.pointView1];
    CGRect rect = [self curveRect];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    if (touchPoint.x < CGRectGetMinX(rect))
        touchPoint.x = CGRectGetMinX(rect);
    else if (touchPoint.x > CGRectGetMaxX(rect))
        touchPoint.x = CGRectGetMaxX(rect);
    
    CGPoint cp;
    cp.x = (touchPoint.x - CGRectGetMinX(rect)) / CGRectGetWidth(rect);
    cp.y = (CGRectGetMaxY(rect) - touchPoint.y) / CGRectGetHeight(rect);
    if (isPoint1)
        self.settings.cp1 = cp;
    else
        self.settings.cp2 = cp;

    [self.view setNeedsLayout];
}

- (IBAction)resetTimingCurve:(id)sender {
    if (self.resetPopover)
    {
        [self.resetPopover dismissPopoverAnimated:YES];
        self.resetPopover = nil;
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    CMSTimingCurveTable *resetTable = [storyboard instantiateViewControllerWithIdentifier:@"TimingCurveDefaults"];
    resetTable.timingCurve = self.settings.timingCurve;
    resetTable.delegate = self;
    
    self.resetPopover = [[UIPopoverController alloc] initWithContentViewController:resetTable];
    [self.resetPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - CMSTimingCurveDelegate

- (void)timingCurveSelected:(TimingCurve)timingCurve
{
    self.settings.timingCurve = timingCurve;
    [self updatePaths:0.25 animateLines:YES];
    if (self.resetPopover)
    {
        [self.resetPopover dismissPopoverAnimated:YES];
        self.resetPopover = nil;
    }
}

@end
