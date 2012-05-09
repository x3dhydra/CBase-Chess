//
//  AGParagraphStyle.h
//  CoreTextPlayground
//
//  Created by Austen Green on 2/9/12.
//  Copyright (c) 2012 Bottle Rocket Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface BRParagraphStyle : NSObject <NSCopying>
{
    @protected
    CTParagraphStyleRef _CTParagraphStyle;
}
@property (nonatomic, readonly) CTParagraphStyleRef CTParagraphStyle;

+ (id)defaultParagraphStyle;

- (UITextAlignment)alignment;
- (CGFloat)firstLineHeadIndent;
- (CGFloat)headIndent;
- (CGFloat)tailIndent;
- (NSArray *)tabStops;
- (CGFloat)defaultTabInterval;
- (CGFloat)lineHeightMultiple;
- (CGFloat)maximumLineHeight;
- (CGFloat)minimumLineHeight;
- (CGFloat)lineSpacing;  // Deprecated
- (CGFloat)paragraphSpacing;
- (CGFloat)paragraphSpacingBefore;
- (CGFloat)minimumLineSpacing;
- (CGFloat)maximumLineSpacing;

- (UILineBreakMode)lineBreakMode;
- (UITextWritingDirection)baseWritingDirection;

@end
