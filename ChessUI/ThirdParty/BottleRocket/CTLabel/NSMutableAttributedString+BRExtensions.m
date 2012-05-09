//
//  NSMutableAttributedString+BRExtensions.m
//  UIPlayground
//
//  Created by Austen Green on 7/1/11.
//  Copyright (c) 2011 Bottle Rocket Apps. All rights reserved.
//

#import "NSMutableAttributedString+BRExtensions.h"
#import "BRFont.h"
#import <CoreText/CoreText.h>

NSString * const kBRAttributedStringStrikethroughStyle = @"kBRAttributedStringStrikethroughStyle";
NSString * const kBRAttributedStringStrikethroughColor = @"kBRAttributedStringStrikethroughColor";


CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment textAlignment)
{
    CTTextAlignment alignment;
    switch (textAlignment) {
        case UITextAlignmentCenter:
            alignment = kCTCenterTextAlignment;
            break;
        case UITextAlignmentLeft:
            alignment = kCTLeftTextAlignment;
            break;
        case UITextAlignmentRight:
            alignment = kCTRightTextAlignment;
            break;
        default:
            alignment = kCTJustifiedTextAlignment;
            break;
    }
    return alignment;
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode)
{
    CTLineBreakMode linebreak;
    switch (lineBreakMode) 
    {
        case UILineBreakModeClip:
            linebreak = kCTLineBreakByClipping;
            break;
        case UILineBreakModeCharacterWrap:
            linebreak = kCTLineBreakByCharWrapping;
            break;
        case UILineBreakModeHeadTruncation:
            linebreak = kCTLineBreakByTruncatingHead;
            break;
        case UILineBreakModeMiddleTruncation:
            linebreak = kCTLineBreakByTruncatingMiddle;
            break;
        case UILineBreakModeTailTruncation:
            linebreak = kCTLineBreakByTruncatingTail;
            break;
        case UILineBreakModeWordWrap:
            linebreak = kCTLineBreakByWordWrapping;
            break;
        default:
            break;
    }
    return linebreak;
}

@implementation NSMutableAttributedString (BRExtensions)

- (void)setFont:(UIFont *)font
{
    [self setFont:font forRange:NSMakeRange(0, [self length])];
}

- (void)setFont:(UIFont *)font forRange:(NSRange)range
{
    CTFontRef ctfont = CTFontCreateWithUIFont(font);
    [self addAttribute:(NSString *)kCTFontAttributeName value:(id)ctfont range:range];
    CFRelease(ctfont);
}

- (void)setColor:(UIColor *)color
{
    [self setColor:color forRange:NSMakeRange(0, [self length])];
}

- (void)setColor:(UIColor *)color forRange:(NSRange)range
{
    [self addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

- (void)setUnderline:(NSAttributedStringUnderlineStyle)underlineStyle
{
    [self setUnderline:underlineStyle forRange:NSMakeRange(0, [self length])];
}

- (void)setUnderline:(NSAttributedStringUnderlineStyle)underlineStyle forRange:(NSRange)range
{
    [self setUnderline:underlineStyle color:[UIColor blackColor] forRange:range];
}

- (void)setUnderline:(NSAttributedStringUnderlineStyle)underlineStyle color:(UIColor *)color forRange:(NSRange)range
{
    [self addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:underlineStyle], kCTUnderlineStyleAttributeName,
                         (id)color.CGColor, kCTUnderlineColorAttributeName, nil]
                  range:range];
}

- (void)setStrikethrough:(BRAttributedStringStrikethroughStyle)strikethroughStyle
{
    [self setStrikethrough:strikethroughStyle forRange:NSMakeRange(0, self.length)];
}

- (void)setStrikethrough:(BRAttributedStringStrikethroughStyle)strikethroughStyle forRange:(NSRange)range
{
    [self setStrikethrough:strikethroughStyle color:nil forRange:range];
}

- (void)setStrikethrough:(BRAttributedStringStrikethroughStyle)strikethroughStyle color:(UIColor *)color forRange:(NSRange)range
{
    [self addAttribute:kBRAttributedStringStrikethroughStyle value:[NSNumber numberWithInt:strikethroughStyle] range:range];
    if (color)
        [self addAttribute:kBRAttributedStringStrikethroughColor value:(id)color.CGColor range:range];
}

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode textAlignment:(UITextAlignment)textAlignment
{
    CTTextAlignment alignment = CTTextAlignmentFromUITextAlignment(textAlignment);
    CTLineBreakMode linebreak = CTLineBreakModeFromUILineBreakMode(lineBreakMode);
	CGFloat minimumLineSpacing = 2.0f;  // This seems to be the minimum line spacing for UILabel, so we go ahead and add it here.
	
    CTParagraphStyleSetting settings[] = {
		{kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(linebreak), &linebreak},
		{kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(minimumLineSpacing), &minimumLineSpacing},
	};
    
    CTParagraphStyleRef paragraph = CTParagraphStyleCreate(settings, 3);
    
    [self addAttribute:(NSString *)kCTParagraphStyleAttributeName value:(id)paragraph range:NSMakeRange(0, [self length])];
    
    CFRelease(paragraph);
}

- (void)setParagraphStyle:(BRParagraphStyle *)paragraphStyle
{
	[self setParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}

- (void)setParagraphStyle:(BRParagraphStyle *)paragraphStyle range:(NSRange)range
{
	CTParagraphStyleRef style = paragraphStyle.CTParagraphStyle;
	if (style)
		[self addAttribute:(NSString *)kCTParagraphStyleAttributeName value:(id)style range:range];
}

@end
