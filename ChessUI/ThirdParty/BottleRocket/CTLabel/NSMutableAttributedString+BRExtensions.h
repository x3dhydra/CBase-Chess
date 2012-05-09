//
//  NSMutableAttributedString+BRExtensions.h
//  UIPlayground
//
//  Created by Austen Green on 7/1/11.
//  Copyright (c) 2011 Bottle Rocket Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "BRParagraphStyle.h"

enum NSAttributedStringUnderlineStyle
{
  NSAttributedStringUnderlineStyleNone   = kCTUnderlineStyleNone,
  NSAttributedStringUnderlineStyleSingle = kCTUnderlineStyleSingle,
  NSAttributedStringUnderlineStyleThick  = kCTUnderlineStyleThick,
  NSAttributedStringUnderlineStyleDouble = kCTUnderlineStyleDouble
};
typedef enum NSAttributedStringUnderlineStyle NSAttributedStringUnderlineStyle;

// Strikethrough constants
typedef enum BRAttributedStringStrikethroughStyle
{
    BRAttributedStringStrikethroughStyleNone   = 0,
    BRAttributedStringStrikethroughStyleSingle = 1
} BRAttributedStringStrikethroughStyle;

extern NSString * const kBRAttributedStringStrikethroughStyle;
extern NSString * const kBRAttributedStringStrikethroughColor;

extern CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment textAlignment);
extern CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode);

@interface NSMutableAttributedString (BRExtensions)

- (void)setFont:(UIFont *)font;
- (void)setFont:(UIFont *)font forRange:(NSRange)range;

- (void)setColor:(UIColor *)color;
- (void)setColor:(UIColor *)color forRange:(NSRange)range;

- (void)setUnderline:(NSAttributedStringUnderlineStyle)underlineStyle;
- (void)setUnderline:(NSAttributedStringUnderlineStyle)underlineStyle forRange:(NSRange)range;
- (void)setUnderline:(NSAttributedStringUnderlineStyle)underlineStyle color:(UIColor *)color forRange:(NSRange)range;

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode textAlignment:(UITextAlignment)textAlignment;

- (void)setStrikethrough:(BRAttributedStringStrikethroughStyle)strikethroughStyle;
- (void)setStrikethrough:(BRAttributedStringStrikethroughStyle)strikethroughStyle forRange:(NSRange)range;
- (void)setStrikethrough:(BRAttributedStringStrikethroughStyle)strikethroughStyle color:(UIColor *)color forRange:(NSRange)range;

- (void)setParagraphStyle:(BRParagraphStyle *)paragraphStyle;
- (void)setParagraphStyle:(BRParagraphStyle *)paragraphStyle range:(NSRange)range;

@end
