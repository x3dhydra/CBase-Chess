//
//  AGMutableParagraphStyle.h
//  CoreTextPlayground
//
//  Created by Austen Green on 2/9/12.
//  Copyright (c) 2012 Bottle Rocket Apps. All rights reserved.
//

#import "BRParagraphStyle.h"

@interface BRMutableParagraphStyle : BRParagraphStyle

- (void)setTextAlignment:(UITextAlignment)alignment;
- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent;
- (void)setHeadIndent:(CGFloat)headIndent;
- (void)setTailIndent:(CGFloat)tailIndent;
- (void)setTabStops:(NSArray *)tabStops;
- (void)setDefaultTabInterval:(CGFloat)defaultTabInterval;
- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple;
- (void)setMaximumLineHeight:(CGFloat)maximumLineHeight;
- (void)setMinimumLineHeight:(CGFloat)minimumLineHeight;
- (void)setParagraphSpacing:(CGFloat)paragraphSpacing;
- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore;
- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing;
- (void)setMaximumLineSpacing:(CGFloat)maximumLineSpacing;

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode;
- (void)setBaseWritingDirection:(UITextWritingDirection)baseWritingDirection;

@end
