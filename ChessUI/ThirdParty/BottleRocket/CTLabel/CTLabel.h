//
//  CTLabel.h
//  UIPlayground
//
//  Created by Austen Green on 12/22/11.
//  Copyright (c) 2011 Bottle Rocket Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "NSMutableAttributedString+BRExtensions.h"

@interface CTLabel : UIView
{
	CGPathRef _path;
}
@property (nonatomic, assign) NSTextCheckingTypes textCheckingTypes;
@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic)        UITextAlignment textAlignment;
@property (nonatomic)        UILineBreakMode lineBreakMode;

@property (nonatomic,retain) UIFont         *font;
@property (nonatomic,retain) UIColor        *textColor;  // Default [UIColor blackColor]
@property (nonatomic, assign) BRAttributedStringStrikethroughStyle strikethroughStyle;

@property (nonatomic, assign) BOOL ignoreParagraphStyle;  // Defaults to YES.  If YES, the receiver ignores any paragraph style applied to an NSAttributedString and replaces it with its own.

- (void)setText:(id)text; // Can be either NSString or NSAttributedString
- (NSString *)text;
- (NSString *)string;
- (NSAttributedString *)attributedString; // For performance reasons, returns a direct reference to the receiver's backing store.  You must not modify this string if it is mutable.

// Text selection
@property (nonatomic) BOOL allowsSelection; // Default YES
@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;  // Disabled by default
@property (nonatomic) BOOL highlightsLinks; // Default NO

- (NSRange)rangeOfStringAtPoint:(CGPoint)point;

- (CGRect)trackingRectForBounds:(CGRect)bounds;

// Override points
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;

- (void)drawTextInRect:(CGRect)rect;
- (void)drawFrame:(CTFrameRef)frame inRect:(CGRect)rect;
- (void)drawLine:(CTLineRef)line inRect:(CGRect)rect;
- (void)drawRun:(CTRunRef)run inRect:(CGRect)rect;

// Called before the glyphs for the run are drawn.
- (void)drawBackgroundHighlightForRun:(CTRunRef)run inRect:(CGRect)rect;

// If the attributed string has a value set fo kCTUnderlineStyleAttributeName, the attributes dictionary will be that
// of the run.  If the underline is applied for some other reason, such as for selected text, attributes will
// contain default attributes for the selection
- (void)drawUnderlineForRun:(CTRunRef)run inRect:(CGRect)rect attributes:(CFDictionaryRef)attributes;
- (void)drawStrikethroughForRun:(CTRunRef)run inRect:(CGRect)rect attributes:(CFDictionaryRef)attributes;

// Called before drawRun:inRect:
- (void)configureContext:(CGContextRef)context forAttributes:(CFDictionaryRef)attributes run:(CTRunRef)run;

// Default implementation returns YES if the frame's visible string range is smaller than it's range.
- (BOOL)shouldTruncateForFrame:(CTFrameRef)frame;

- (void)sizeToFitCurrentWidth;

- (void)setPath:(CGPathRef)path;
- (CGPathRef)path;

- (CGRect)boundingBoxForRange:(NSRange)range;

@end

@interface CTLabel (Subclasses)
@property (nonatomic, readonly) CTFramesetterRef framesetter;
@property (nonatomic, readonly) CTFrameRef textFrame;

// Returns NO if the receiver's text content was set using an NSString instead of an NSAttributedString
@property (nonatomic, assign) BOOL textIsAttributed;

@end

// NSMutableAttributedString + CTLabel

typedef enum
{
	CTLinkBlockSelectionTap,
	CTLinkBlockSelectionLongPress,
} CTLinkBlockSelectionType;

typedef void (^CTLinkBlock)(CTLabel *button, NSRange range, CTLinkBlockSelectionType selectionType);
extern NSString *const kCTLabelLinkKey;
extern NSString *const kCTLabelLinkHighlightedForegroundColorKey;

@interface NSMutableAttributedString (CTLabel)

- (void)setLink:(CTLinkBlock)block;
- (void)setLink:(CTLinkBlock)block range:(NSRange)range;
- (void)setLink:(CTLinkBlock)block range:(NSRange)range selectedColor:(UIColor *)selectedColor;

@end