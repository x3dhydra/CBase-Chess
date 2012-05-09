//
//  AGParagraphStyle.m
//  CoreTextPlayground
//
//  Created by Austen Green on 2/9/12.
//  Copyright (c) 2012 Bottle Rocket Apps. All rights reserved.
//

#import "BRParagraphStyle.h"

@implementation BRParagraphStyle

+ (id)defaultParagraphStyle
{
    return [[[[self class] alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        CGFloat minimumLineSpacing = 2.0f; // This seems to be the minimum line spacing for UILabel, so make it the default for our iOS paragaph style
        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(minimumLineSpacing), &minimumLineSpacing},
        };
        _CTParagraphStyle = CTParagraphStyleCreate(settings, 1);
    }
    return self;
}

- (void)dealloc
{
    if (_CTParagraphStyle)
        CFRelease(_CTParagraphStyle);
    [super dealloc];
}

- (UITextAlignment)alignment
{
    CTTextAlignment alignment;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment);
    
    switch (alignment) {
        case kCTLeftTextAlignment:
            return UITextAlignmentLeft;
            break;
        case kCTNaturalTextAlignment:
            return UITextAlignmentLeft;
            break;
        case kCTCenterTextAlignment:
            return UITextAlignmentCenter;
            break;
        case kCTRightTextAlignment:
            return UITextAlignmentRight;
            break;
        default:
            return UITextAlignmentLeft;
            break;
    }
}

- (CGFloat)firstLineHeadIndent
{
    CGFloat firstLineHeadIndent;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(firstLineHeadIndent), &firstLineHeadIndent);
    return firstLineHeadIndent;
}

- (CGFloat)headIndent
{
    CGFloat headIndent;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(headIndent), &headIndent);
    return headIndent;
}

- (CGFloat)tailIndent
{
    CGFloat tailIndent;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierTailIndent, sizeof(tailIndent), &tailIndent);
    return tailIndent;
}

- (NSArray *)tabStops
{
    NSArray *tabStops;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierTabStops, sizeof(tabStops), &tabStops);
    return tabStops;
}

- (CGFloat)defaultTabInterval
{
    CGFloat defaultTabInterval;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierDefaultTabInterval, sizeof(defaultTabInterval), &defaultTabInterval);
    return defaultTabInterval;
}

- (CGFloat)lineHeightMultiple
{
    CGFloat lineHeightMultiple;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(lineHeightMultiple), &lineHeightMultiple);
    return lineHeightMultiple;
}

- (CGFloat)maximumLineHeight
{
    CGFloat maximumLineHeight;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maximumLineHeight), &maximumLineHeight);
    return maximumLineHeight;
}

- (CGFloat)minimumLineHeight
{    
    CGFloat minimumLineHeight;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minimumLineHeight), &minimumLineHeight);
    return minimumLineHeight;
}

- (CGFloat)lineSpacing
{
    CGFloat lineSpacing;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing);
    return lineSpacing;
}

- (CGFloat)paragraphSpacing
{
    CGFloat paragraphSpacing;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paragraphSpacing), &paragraphSpacing);
    return paragraphSpacing;
}

- (CGFloat)paragraphSpacingBefore
{
    CGFloat paragraphSpacingBefore;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(paragraphSpacingBefore), &paragraphSpacingBefore);
    return paragraphSpacingBefore;
}

- (CGFloat)minimumLineSpacing
{
    CGFloat minimumLineSpacing;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(minimumLineSpacing), &minimumLineSpacing);
    return minimumLineSpacing;
}

- (CGFloat)maximumLineSpacing
{
    CGFloat maximumLineSpacing;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(maximumLineSpacing), &maximumLineSpacing);
    return maximumLineSpacing;    
}

- (UILineBreakMode)lineBreakMode
{
    CTLineBreakMode lineBreakMode;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode);
    
    switch (lineBreakMode) {
        case kCTLineBreakByCharWrapping:
            return UILineBreakModeCharacterWrap;
            break;
        case kCTLineBreakByClipping:
            return UILineBreakModeClip;
            break;
        case kCTLineBreakByTruncatingHead:
            return UILineBreakModeHeadTruncation;
            break;
        case kCTLineBreakByTruncatingMiddle:
            return UILineBreakModeMiddleTruncation;
            break;
        case kCTLineBreakByTruncatingTail:
            return UILineBreakModeTailTruncation;
            break;
        case kCTLineBreakByWordWrapping:
        default:
            return UILineBreakModeWordWrap;
            break;
    }
}

- (UITextWritingDirection)baseWritingDirection
{
    CTWritingDirection baseWritingDirection;
    CTParagraphStyleGetValueForSpecifier(self.CTParagraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(baseWritingDirection), &baseWritingDirection);

    switch (baseWritingDirection) {
        case kCTWritingDirectionNatural:
            return UITextWritingDirectionNatural;
            break;
        case kCTWritingDirectionRightToLeft:
            return UITextWritingDirectionRightToLeft;
            break;
        case kCTWritingDirectionLeftToRight:
        default:
            return UITextWritingDirectionLeftToRight;
            break;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    if ([self isMemberOfClass:[BRParagraphStyle class]])
        return [self retain];
    
    BRParagraphStyle *style = [[[self class] alloc] init];
    if (style->_CTParagraphStyle)
    {
        CFRelease(style->_CTParagraphStyle);
        style->_CTParagraphStyle = CTParagraphStyleCreateCopy(self.CTParagraphStyle);
    }
    
    return style;
}

- (CTParagraphStyleRef)CTParagraphStyle
{
    return _CTParagraphStyle;
}

@end