//
//  UIView+LayoutConstraints.m
//
//  Created by Mark Pospesel on 5/1/14.
//  Copyright (c) 2014 Ubiquiti Networks. All rights reserved.
//

#import "UIView+LayoutConstraints.h"

@implementation UIView(LayoutConstraints)

- (NSLayoutConstraint *)pinWidth:(CGFloat)width
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:width];
    
    [[self superview] addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinHeight:(CGFloat)height;
{
    return [self pinHeight:height relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinHeight:(CGFloat)height priority:(UILayoutPriority)priority;
{
    return [self pinHeight:height relatedBy:NSLayoutRelationEqual priority:priority];
}

- (NSLayoutConstraint *)pinHeight:(CGFloat)height relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:height];
    constraint.priority = priority;
    
    [[self superview] addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinMinimumHeight:(CGFloat)height;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:height];
    
    [[self superview] addConstraint:constraint];
    
    return constraint;
}

- (NSArray *)pinSize:(CGSize)size
{
    NSLayoutConstraint *widthConstraint = [self pinWidth:size.width];
    NSLayoutConstraint *heightConstraint = [self pinHeight:size.height];

    return @[widthConstraint, heightConstraint];
}

- (NSLayoutConstraint *)pinCenterX:(CGFloat)centerX
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeCenterX multiplier:0 constant:centerX];
    
    [[self superview] addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinCenterY:(CGFloat)centerY
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeCenterY multiplier:0 constant:centerY];
    
    [[self superview] addConstraint:constraint];
    
    return constraint;
}

- (NSArray *)pinCenter:(UIOffset)offset
{
    NSLayoutConstraint *centerXConstraint = [self pinCenterX:offset.horizontal];
    NSLayoutConstraint *centerYConstraint = [self pinCenterY:offset.vertical];
    
    return @[centerXConstraint, centerYConstraint];
}

- (NSLayoutConstraint *)pinLeadingSpaceToSuperviewWithInset:(CGFloat)leftInset;
{
    return [self pinLeadingSpaceToSuperviewWithInset:leftInset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinLeadingSpaceToSuperviewWithInset:(CGFloat)leftInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:relation toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:leftInset];
    constraint.priority = priority;
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinTrailingSpaceToSuperviewWithInset:(CGFloat)rightInset;
{
    return [self pinTrailingSpaceToSuperviewWithInset:rightInset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinTrailingSpaceToSuperviewWithInset:(CGFloat)rightInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:relation toItem:superview attribute:NSLayoutAttributeRight multiplier:1 constant:-rightInset];
    constraint.priority = priority;
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSArray *)pinWidthToSuperviewWithLeftInset:(CGFloat)leftInset rightInset:(CGFloat)rightInset;
{
    NSLayoutConstraint *leadingConstraint = [self pinLeadingSpaceToSuperviewWithInset:leftInset];
    NSLayoutConstraint *trailingConstraint = [self pinTrailingSpaceToSuperviewWithInset:rightInset relatedBy:NSLayoutRelationEqual priority:(UILayoutPriorityRequired - 1)];
    
    return @[leadingConstraint, trailingConstraint];
}

- (NSLayoutConstraint *)pinTopSpaceToSuperviewWithInset:(CGFloat)topInset;
{
    return [self pinTopSpaceToSuperviewWithInset:topInset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinTopSpaceToSuperviewWithInset:(CGFloat)topInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:relation toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:topInset];
    constraint.priority = priority;
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinBottomSpaceToSuperviewWithInset:(CGFloat)bottomInset;
{
    return [self pinBottomSpaceToSuperviewWithInset:bottomInset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinBottomSpaceToSuperviewWithInset:(CGFloat)bottomInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:relation toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomInset];
    constraint.priority = priority;
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinBaselineToSuperviewBottomWithInset:(CGFloat)bottomInset;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomInset];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSArray *)pinHeightToSuperviewWithTopInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset;
{
    NSLayoutConstraint *topConstraint = [self pinTopSpaceToSuperviewWithInset:topInset];
    NSLayoutConstraint *bottomConstraint = [self pinBottomSpaceToSuperviewWithInset:bottomInset relatedBy:NSLayoutRelationEqual priority:(UILayoutPriorityRequired - 1)];
    
    return @[topConstraint, bottomConstraint];
}

- (NSArray *)pinSizeToSuperviewWithInsets:(UIEdgeInsets)insets;
{
    NSLayoutConstraint *topConstraint = [self pinTopSpaceToSuperviewWithInset:insets.top];
    NSLayoutConstraint *leadingConstraint = [self pinLeadingSpaceToSuperviewWithInset:insets.left];
    NSLayoutConstraint *bottomConstraint = [self pinBottomSpaceToSuperviewWithInset:insets.bottom relatedBy:NSLayoutRelationEqual priority:(UILayoutPriorityRequired - 1)];
    NSLayoutConstraint *trailingConstraint = [self pinTrailingSpaceToSuperviewWithInset:insets.right relatedBy:NSLayoutRelationEqual priority:(UILayoutPriorityRequired - 1)];
    
    return @[topConstraint, leadingConstraint, bottomConstraint, trailingConstraint];
}

- (NSLayoutConstraint *)pinCenterXToSuperview;
{
    return [self pinCenterXToSuperviewWithOffset:0];
}

- (NSLayoutConstraint *)pinCenterXToSuperviewWithOffset:(CGFloat)offset;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:offset];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinCenterXToSiblingView:(UIView *)siblingView;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:siblingView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinCenterYToSuperview;
{
    return [self pinCenterYToSuperviewWithOffset:0];
}

- (NSLayoutConstraint *)pinCenterYToSuperviewWithOffset:(CGFloat)offset;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:offset];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinCenterYToSiblingView:(UIView *)siblingView;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:siblingView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSArray *)pinCenterToSuperview
{
    NSLayoutConstraint *centerXContstraint = [self pinCenterXToSuperview];
    NSLayoutConstraint *centerYContstraint = [self pinCenterYToSuperview];
    
    return @[centerXContstraint, centerYContstraint];
}

- (NSLayoutConstraint *)pinTopToBottomOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
{
    return [self pinTopToBottomOfSiblingView:siblingView withOffset:offset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinTopToBottomOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:relation toItem:siblingView attribute:NSLayoutAttributeBottom multiplier:1 constant:offset];
    constraint.priority = priority;
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinCenterYToBottomOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:siblingView attribute:NSLayoutAttributeBottom multiplier:1 constant:offset];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

- (NSLayoutConstraint *)pinBottomToTopOfSiblingView:(UIView *)siblingView withInset:(CGFloat)inset;
{
    return [self pinBottomToTopOfSiblingView:siblingView withInset:inset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)pinBottomToTopOfSiblingView:(UIView *)siblingView withInset:(CGFloat)inset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:relation toItem:siblingView attribute:NSLayoutAttributeTop multiplier:1 constant:-inset];
    constraint.priority = priority;

    [superview addConstraint:constraint];
    
    return constraint;
}

// pin left side relative to right

- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
{
    return [self pinLeftToRightOfSiblingView:siblingView withOffset:offset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired commonAncestor:[self superview]];
}

- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    return [self pinLeftToRightOfSiblingView:siblingView withOffset:offset relatedBy:relation priority:priority commonAncestor:[self superview]];
}

- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset commonAncestor:(UIView *)ancestorView;
{
    return [self pinLeftToRightOfSiblingView:siblingView withOffset:offset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired commonAncestor:ancestorView];
}

- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority commonAncestor:(UIView *)ancestorView;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:relation toItem:siblingView attribute:NSLayoutAttributeRight multiplier:1 constant:offset];
    constraint.priority = priority;
    
    [ancestorView addConstraint:constraint];
    
    return constraint;
}

// pin right side relative to left

- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset;
{
    return [self pinRightToLeftOfSiblingView:siblingView withInset:rightInset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired commonAncestor:[self superview]];
}

- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
{
    return [self pinRightToLeftOfSiblingView:siblingView withInset:rightInset relatedBy:relation priority:priority commonAncestor:[self superview]];
}

- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset commonAncestor:(UIView *)ancestorView;
{
    return [self pinRightToLeftOfSiblingView:siblingView withInset:rightInset relatedBy:NSLayoutRelationEqual priority:UILayoutPriorityRequired commonAncestor:ancestorView];
}

- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority commonAncestor:(UIView *)ancestorView;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:relation toItem:siblingView attribute:NSLayoutAttributeLeft multiplier:1 constant:-rightInset];
    constraint.priority = priority;
    
    [ancestorView addConstraint:constraint];
    
    return constraint;
}

// pin baselines

- (NSLayoutConstraint *)pinBaselineToBaselineOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *superview = [self superview];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:siblingView attribute:NSLayoutAttributeBaseline multiplier:1 constant:offset];
    
    [superview addConstraint:constraint];
    
    return constraint;
}

@end
