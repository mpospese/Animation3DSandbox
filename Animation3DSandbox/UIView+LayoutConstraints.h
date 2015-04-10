//
//  UIView+LayoutConstraints.h
//
//  Created by Mark Pospesel on 5/1/14.
//  Copyright (c) 2014 Ubiquiti Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(LayoutConstraints)

- (NSLayoutConstraint *)pinWidth:(CGFloat)width;
- (NSLayoutConstraint *)pinHeight:(CGFloat)height;
- (NSLayoutConstraint *)pinHeight:(CGFloat)height priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)pinHeight:(CGFloat)height relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)pinMinimumHeight:(CGFloat)height;
- (NSArray *)pinSize:(CGSize)size;

- (NSLayoutConstraint *)pinCenterX:(CGFloat)centerX;
- (NSLayoutConstraint *)pinCenterY:(CGFloat)centerY;
- (NSArray *)pinCenter:(UIOffset)offset;

- (NSLayoutConstraint *)pinLeadingSpaceToSuperviewWithInset:(CGFloat)leftInset;
- (NSLayoutConstraint *)pinLeadingSpaceToSuperviewWithInset:(CGFloat)leftInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;

- (NSLayoutConstraint *)pinTrailingSpaceToSuperviewWithInset:(CGFloat)rightInset;
- (NSLayoutConstraint *)pinTrailingSpaceToSuperviewWithInset:(CGFloat)rightInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;

- (NSArray *)pinWidthToSuperviewWithLeftInset:(CGFloat)leftInset rightInset:(CGFloat)rightInset;
- (NSLayoutConstraint *)pinTopSpaceToSuperviewWithInset:(CGFloat)bottomInset;
- (NSLayoutConstraint *)pinTopSpaceToSuperviewWithInset:(CGFloat)topInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)pinBottomSpaceToSuperviewWithInset:(CGFloat)bottomInset;
- (NSLayoutConstraint *)pinBottomSpaceToSuperviewWithInset:(CGFloat)bottomInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
- (NSArray *)pinHeightToSuperviewWithTopInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset;
- (NSArray *)pinSizeToSuperviewWithInsets:(UIEdgeInsets)insets;
- (NSLayoutConstraint *)pinBaselineToSuperviewBottomWithInset:(CGFloat)bottomInset;

- (NSLayoutConstraint *)pinCenterXToSuperview;
- (NSLayoutConstraint *)pinCenterXToSuperviewWithOffset:(CGFloat)offset;
- (NSLayoutConstraint *)pinCenterXToSiblingView:(UIView *)siblingView;
- (NSLayoutConstraint *)pinCenterYToSuperview;
- (NSLayoutConstraint *)pinCenterYToSuperviewWithOffset:(CGFloat)offset;
- (NSLayoutConstraint *)pinCenterYToSiblingView:(UIView *)siblingView;
- (NSArray *)pinCenterToSuperview;

- (NSLayoutConstraint *)pinTopToBottomOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
- (NSLayoutConstraint *)pinCenterYToBottomOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
- (NSLayoutConstraint *)pinTopToBottomOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)pinBottomToTopOfSiblingView:(UIView *)siblingView withInset:(CGFloat)inset;
- (NSLayoutConstraint *)pinBottomToTopOfSiblingView:(UIView *)siblingView withInset:(CGFloat)inset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;

// pin left side relative to right
- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;
- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset commonAncestor:(UIView *)ancestorView;
- (NSLayoutConstraint *)pinLeftToRightOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority commonAncestor:(UIView *)ancestorView;

// pin right side relative to left
- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset;
- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority;
- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset commonAncestor:(UIView *)ancestorView;
- (NSLayoutConstraint *)pinRightToLeftOfSiblingView:(UIView *)siblingView withInset:(CGFloat)rightInset relatedBy:(NSLayoutRelation)relation priority:(UILayoutPriority)priority commonAncestor:(UIView *)ancestorView;

// pin baselines
- (NSLayoutConstraint *)pinBaselineToBaselineOfSiblingView:(UIView *)siblingView withOffset:(CGFloat)offset;

@end
