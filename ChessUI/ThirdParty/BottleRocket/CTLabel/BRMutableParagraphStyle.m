//
//  AGMutableParagraphStyle.m
//  CoreTextPlayground
//
//  Created by Austen Green on 2/9/12.
//  Copyright (c) 2012 Bottle Rocket Apps. All rights reserved.
//

#import "BRMutableParagraphStyle.h"
#import "NSMutableAttributedString+BRExtensions.h"

@interface BRMutableParagraphStyle()
{
    CTTextAlignment _aligment;
    CGFloat _firstLineHeadIndent;
    CGFloat _headIndent;
    CGFloat _tailIndent;
    NSArray *_tabStops;
    CGFloat _defaultTabInterval;
    CGFloat _lineHeightMultiple;
    CGFloat _maximumLineHeight;
    CGFloat _minimumLineHeight;
    CGFloat _paragraphSpacing;
    CGFloat _paragraphSpacingBefore;
    CGFloat _minimumLineSpacing;
    CGFloat _maximumLineSpacing;
    CTLineBreakMode _lineBreakMode;
    CTWritingDirection _baseWritingDirection;
    
    BOOL _isStyleDirty;
}
- (void)setNeedsStyleUpdate;

@end

@implementation BRMutableParagraphStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        CTParagraphStyleGetValueForSpecifier(_CTParagraphStyle, kCTParagraphStyleSpecifierLineBreakMode, sizeof(_aligment), &_aligment);
        _firstLineHeadIndent = self.firstLineHeadIndent;
        _headIndent = self.firstLineHeadIndent;
        _tailIndent = self.tailIndent;
        _tabStops = [self.tabStops retain];
        _defaultTabInterval = self.defaultTabInterval;
        _lineHeightMultiple = self.lineHeightMultiple;
        _maximumLineHeight = self.maximumLineHeight;
        _minimumLineHeight = self.minimumLineHeight;
        _paragraphSpacing = self.paragraphSpacing;
        _paragraphSpacingBefore = self.paragraphSpacingBefore;
        _minimumLineSpacing = self.minimumLineSpacing;
        _maximumLineSpacing = self.maximumLineSpacing;
        _lineBreakMode = self.lineBreakMode;
        _baseWritingDirection = self.baseWritingDirection;
    }
    return self;
}

- (void)setNeedsStyleUpdate
{
    _isStyleDirty = YES;
}

- (CTParagraphStyleRef)CTParagraphStyle
{
    if (_isStyleDirty)
    {
        _isStyleDirty = NO;
        
        if (_CTParagraphStyle)
            CFRelease(_CTParagraphStyle);
        
        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(_aligment), &_aligment},
            {kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(_firstLineHeadIndent), &_firstLineHeadIndent},
            {kCTParagraphStyleSpecifierHeadIndent, sizeof(_headIndent), &_headIndent},
            {kCTParagraphStyleSpecifierTailIndent, sizeof(_tailIndent), &_tailIndent},
            {kCTParagraphStyleSpecifierTabStops, sizeof(_tabStops), _tabStops},
            {kCTParagraphStyleSpecifierDefaultTabInterval, sizeof(_defaultTabInterval), &_defaultTabInterval},
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(_lineBreakMode), &_lineBreakMode},
            {kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(_lineHeightMultiple), &_lineHeightMultiple},
            {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(_maximumLineHeight), &_maximumLineHeight},
            {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(_minimumLineHeight), &_minimumLineHeight},
            {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(_paragraphSpacing), &_paragraphSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(_paragraphSpacingBefore), &_paragraphSpacingBefore},
            {kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(_baseWritingDirection), &_baseWritingDirection},
            {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(_maximumLineSpacing), &_maximumLineSpacing}, 
            {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(_minimumLineSpacing), &_minimumLineSpacing},
        };
        _CTParagraphStyle = CTParagraphStyleCreate(settings, 15);
    }
    
    return [super CTParagraphStyle];
}

- (void)setTextAlignment:(UITextAlignment)alignment
{
    _aligment = CTTextAlignmentFromUITextAlignment(alignment);
    [self setNeedsStyleUpdate];
}

- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent
{
    _firstLineHeadIndent = firstLineHeadIndent;
    [self setNeedsStyleUpdate];
}

- (void)setHeadIndent:(CGFloat)headIndent
{
    _headIndent = headIndent;
    [self setNeedsStyleUpdate];
}

- (void)setTailIndent:(CGFloat)tailIndent
{
    _tailIndent = tailIndent;
    [self setNeedsStyleUpdate];
}

- (void)setTabStops:(NSArray *)tabStops
{
    [_tabStops release];
    _tabStops = [tabStops retain];
    [self setNeedsStyleUpdate];
}
- (void)setDefaultTabInterval:(CGFloat)defaultTabInterval
{
    _defaultTabInterval = defaultTabInterval;
    [self setNeedsStyleUpdate];
}

- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple
{
    _lineHeightMultiple = lineHeightMultiple;
    [self setNeedsStyleUpdate];
}   

- (void)setMaximumLineHeight:(CGFloat)maximumLineHeight
{
    _maximumLineHeight = maximumLineHeight;
    [self setNeedsStyleUpdate];
}

- (void)setMinimumLineHeight:(CGFloat)minimumLineHeight
{
    _minimumLineHeight = minimumLineHeight;
    [self setNeedsStyleUpdate];
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing
{
    _paragraphSpacing = paragraphSpacing;
    [self setNeedsStyleUpdate];
}

- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore
{
    _paragraphSpacingBefore = paragraphSpacingBefore;
    [self setNeedsStyleUpdate];
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    _minimumLineSpacing = minimumLineSpacing;
    [self setNeedsStyleUpdate];
}

- (void)setMaximumLineSpacing:(CGFloat)maximumLineSpacing
{
    _maximumLineHeight = maximumLineSpacing;
    [self setNeedsStyleUpdate];
}

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode
{
    _lineBreakMode = lineBreakMode;
    [self setNeedsStyleUpdate];
}

- (void)setBaseWritingDirection:(UITextWritingDirection)baseWritingDirection
{
    _baseWritingDirection = baseWritingDirection;
    [self setNeedsStyleUpdate];
}


@end
