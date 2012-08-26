//
//  CTLabel.m
//  UIPlayground
//
//  Created by Austen Green on 12/22/11.
//  Copyright (c) 2011 Bottle Rocket Apps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CTLabel.h"
#import "NSMutableAttributedString+BRExtensions.h"
#import "CTFrameWrapper.h"

static BOOL NSRangeIntersectsRange(NSRange range1, NSRange range2)
{
    NSRange intersection = NSIntersectionRange(range1, range2);
    return intersection.length > 0;
}

@interface CTLabel()
{
    BOOL _track;
    NSRange _selectedRange;
    CGRect _selectionBounds;
    NSMutableAttributedString *_text;
	CGSize _textSize;
	BOOL _hasLinks;
}
@property (nonatomic, readonly) CTFramesetterRef framesetter;
@property (nonatomic, readonly) CTFrameRef textFrame;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL textIsAttributed;

- (void)clearSelection;
- (CGRect)boundingBoxForRange:(NSRange)range;
- (CGRect)boundingBoxForRange:(NSRange)range line:(CTLineRef)line;
- (BOOL)hasSelection;
- (void)didSelectTextAtIndex:(NSUInteger)index;

- (void)invalidateTextSize;

- (void)bindTouchToRange:(NSRange)range;

// Text Checking
- (NSMutableAttributedString *)attributedStringForDetectedDataInString:(NSMutableAttributedString *)text;

// Truncation
- (CTLineRef)copyTruncatedLine:(CTLineRef)originalLine width:(CGFloat)maxWidth;

// Accessibility
@property (nonatomic, strong) NSMutableArray *accessibilityElements;
- (CTLabelAccessibilityType)resolvedAccessibilityType;

@end

@implementation CTLabel
@synthesize framesetter = _framesetter;
@synthesize textFrame = _frame;
@synthesize highlighted = _highlighted;
@synthesize longPressGestureRecognizer = _longPressGestureRecognizer;
@synthesize textCheckingTypes = _textCheckingTypes;
@synthesize numberOfLines = _numberOfLines;
@synthesize textIsAttributed = _textIsAttributed;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize strikethroughStyle = _strikethroughStyle;
@synthesize lineBreakMode = _lineBreakMode;
@synthesize textAlignment = _textAlignment;
@synthesize ignoreParagraphStyle = _ignoreParagraphStyle;

// Selection
@synthesize highlightsLinks = _highlightsLinks;
@synthesize allowsSelection = _allowsSelection;

// Accessibility
@synthesize accessibilityType = _accessibilityType;
@synthesize accessibilityElements = _accessibilityElements;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self CTLabelCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self CTLabelCommonInit];
	}
	return self;
}

- (void)CTLabelCommonInit
{
	self.layer.geometryFlipped = YES;  // Flipped for CoreText drawing
	self.backgroundColor = [UIColor clearColor];
	self.isAccessibilityElement = YES; // Support basic accessibility
	
	_allowsSelection = YES;
	_highlightsLinks = NO;
	_ignoreParagraphStyle = YES;
}

- (void)dealloc
{
    [_longPressGestureRecognizer release];
    [_text release];
    [_font release];
    [_textColor release];
	[_accessibilityElements release];
    
    if (_frame)
        CFRelease(_frame);
    if (_framesetter)
        CFRelease(_framesetter);
    
	CGPathRelease(_path);
	
    [super dealloc];
}

- (void)setFrame:(CGRect)frame
{
	CGRect oldFrame = self.frame;
	[super setFrame:frame];
	[self invalidateAccessibilityElements];
	
	if (!CGSizeEqualToSize(oldFrame.size, frame.size))
	{
		[self invalidateTextSize];
	}
}

#pragma mark - Drawing

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return bounds;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextSaveGState(context);
    [self.backgroundColor set];
    UIRectFill(rect);

    // DEBUG
//    if ([self hasSelection])
//    {
//        [[UIColor greenColor] set];
//        UIRectFill([self boundingBoxForRange:_selectedRange]);
//    }
    
    CGContextRestoreGState(context);
    
    rect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [self drawTextInRect:rect];
}

- (void)drawTextInRect:(CGRect)rect
{
	CTFrameRef frame = self.textFrame;
	if (frame)
		[self drawFrame:self.textFrame inRect:rect];
}

- (void)drawFrame:(CTFrameRef)frame inRect:(CGRect)rect;
{
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint *origins = calloc(lineCount, sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
	
	// Allow for vertical centering like UILabel does
    CGFloat yOffset = [self textOriginVerticalOffset];	
    CGFloat ascent, descent, leading;
    
    // Reduce the lineCount if the number of lines is restricted
    if (self.numberOfLines > 0)
        lineCount = MIN(self.numberOfLines, lineCount);
    
    BOOL needsTruncation = [self shouldTruncateForFrame:frame];
    
    // Iterate over each line in the frame and draw it
    for (unsigned int i = 0; i < lineCount; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        if ((i == lineCount - 1) && needsTruncation)
            line = [self copyTruncatedLine:line width:(CGRectGetWidth(rect))];
        else
            CFRetain(line);
        
        double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGRect bounds = CGRectMake(origins[i].x, origins[i].y - yOffset, width, ascent + descent);
        
        [self drawLine:line inRect:bounds];
        
        CFRelease(line);
    }
    
    free(origins);
}

- (void)drawLine:(CTLineRef)line inRect:(CGRect)rect
{
    NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextPosition(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    // Iterate over each run in the line and draw it
    for (unsigned int i = 0; i < runs.count; i++)
    {
        CTRunRef run = (CTRunRef)[runs objectAtIndex:i];
        [self drawRun:run inRect:rect];
    }
    
    CGContextRestoreGState(context);
}

- (void)drawRun:(CTRunRef)run inRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSaveGState(context);
    
    // TODO: Allocate memory for glyphs/positions if they return NULL
    const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
    const CGPoint *positions = CTRunGetPositionsPtr(run);
    CFIndex count = CTRunGetGlyphCount(run);
    
    // Set text position and text matrix appropriately
    CGAffineTransform transfom = CTRunGetTextMatrix(run);
    CGContextSetTextMatrix(context, transfom);
    CGContextSetTextPosition(context, transfom.tx + CGRectGetMinX(rect), transfom.ty + CGRectGetMinY(rect));
    
    // Configure the context with the run's attributes
    CFDictionaryRef attributes = CTRunGetAttributes(run);
    [self configureContext:context forAttributes:attributes run:run];
    
    // Get typographic bounds for underline drawing
    CGFloat ascent, descent, leading;
    double width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);        
    CGRect bounds = CGRectMake(CGRectGetMinX(rect) + roundf(positions[0].x), roundf(transfom.ty + CGRectGetMinY(rect)), width, ascent + descent);
   
    // Allow for any background highlighting
    CFRange cfRange = CTRunGetStringRange(run);
    NSRange range = NSMakeRange(cfRange.location, cfRange.length);
    if (self.highlightsLinks && self.highlighted && NSRangeIntersectsRange(_selectedRange, range))
    {
        [self drawBackgroundHighlightForRun:run inRect:bounds];
    }
    
    // Draw the glyphs
    CGContextShowGlyphsAtPositions(context, glyphs, positions, count);
    
    // Check for underline mode and draw if appropriate
    NSNumber *underlineMode = (NSNumber *)CFDictionaryGetValue(attributes, kCTUnderlineStyleAttributeName);
    if ([underlineMode integerValue] != kCTUnderlineStyleNone)
    {        
        // Draw underline
        [self drawUnderlineForRun:run inRect:bounds attributes:attributes];
    }
    
    // Check for strikethrough and draw if appropriate
    BRAttributedStringStrikethroughStyle strikethroughStyle = [(NSNumber *)CFDictionaryGetValue(attributes, kBRAttributedStringStrikethroughStyle) integerValue];
    if (strikethroughStyle == BRAttributedStringStrikethroughStyleSingle)
    {
        // Draw striketrhough
        [self drawStrikethroughForRun:run inRect:bounds attributes:attributes];
    }
        
    CGContextRestoreGState(context);
}

- (void)drawBackgroundHighlightForRun:(CTRunRef)run inRect:(CGRect)rect
{
    //CGRect rrect = CGRectInset(rect, -2.0f, -2.0f); // Expand the rect.  Can't expand the rect for now, since it would draw over any previously rendered text that extended below the baseline.
    CGRect rrect = rect;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Configure background color
    CGColorRef color = [[UIColor lightGrayColor] CGColor];  // TODO: Should this background color be configurable?
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetFillColorWithColor(context, color);
    
    // The following code/comments taken from Apple's QuartzDemo in order to draw a rounded rect:
    
    // BEGIN Apple code
    
    CGFloat radius = 1.0;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);

    // END Apple code
    
    CGContextRestoreGState(context);
}

- (void)configureContext:(CGContextRef)context forAttributes:(CFDictionaryRef)attributes run:(CTRunRef)run
{
    // Font
    CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
    CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
    CGContextSetFont(context, cgFont);
    CGContextSetFontSize(context, CTFontGetSize(runFont));

    // Text color
    CGColorRef color = (CGColorRef)CFDictionaryGetValue(attributes, kCTForegroundColorAttributeName);
	if (!color)
		color = self.textColor.CGColor; // Use textColor if the run doesn't explicitly have one set.
	
    CGContextSetFillColorWithColor(context, color);
    CGContextSetStrokeColorWithColor(context, color);
    
    // Selected range
    CFRange cfRange = CTRunGetStringRange(run);
    NSRange range = NSMakeRange(cfRange.location, cfRange.length);
    if (self.highlighted && NSRangeIntersectsRange(_selectedRange, range))
    {
        CGColorRef highlightColor = (CGColorRef)CFDictionaryGetValue(attributes, kCTLabelLinkHighlightedForegroundColorKey);
        if (highlightColor)
        {
            CGContextSetFillColorWithColor(context, highlightColor);
            CGContextSetStrokeColorWithColor(context, highlightColor);
        }
    }
    
    CGFontRelease(cgFont);
}

- (void)drawUnderlineForRun:(CTRunRef)run inRect:(CGRect)rect attributes:(CFDictionaryRef)attributes
{
    rect = CGRectIntegral(rect);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Underline position gathered from font
    CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
    CGFloat underlinePosition = roundf(CTFontGetUnderlinePosition(runFont));
    
    // Underline color
    CGColorRef color = (CGColorRef)CFDictionaryGetValue(attributes, kCTForegroundColorAttributeName);
    CGContextSetFillColorWithColor(context, color);
    CGContextSetStrokeColorWithColor(context, color);
    
    // Increase line width for thick underlines
    NSNumber *number = (NSNumber *)CFDictionaryGetValue(attributes, kCTUnderlineStyleAttributeName);
    if ([number integerValue] == kCTUnderlineStyleThick)
        CGContextSetLineWidth(context, 2.0f);
    
    // Draw the underline
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + underlinePosition);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + underlinePosition);
    CGContextStrokePath(context);
    
    
    CGContextRestoreGState(context);
}

- (void)drawStrikethroughForRun:(CTRunRef)run inRect:(CGRect)rect attributes:(CFDictionaryRef)attributes
{
    CGFloat y = roundf(rect.origin.y + CGRectGetHeight(rect) / 2.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    NSDictionary *dictionary = (NSDictionary *)attributes;
    if ([[dictionary objectForKey:kBRAttributedStringStrikethroughStyle] integerValue] == BRAttributedStringStrikethroughStyleSingle)
    {
        // Use strikethrough color if available
        CGColorRef color = (CGColorRef)[dictionary objectForKey:kBRAttributedStringStrikethroughColor];
        
        // Otherwise use the foreground color
        if (!color)
            color = (CGColorRef)[dictionary objectForKey:(NSString *)kCTForegroundColorAttributeName];
        
        // And default to black otherwise
        if (!color)
            color = [[UIColor blackColor] CGColor];
        
        CGContextSetFillColorWithColor(context, color);
        CGContextSetStrokeColorWithColor(context, color);
        
        CGContextMoveToPoint(context, rect.origin.x, y);
        CGContextAddLineToPoint(context, rect.origin.x + CGRectGetWidth(rect), y);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
}

- (BOOL)shouldTruncateForFrame:(CTFrameRef)frame
{
	CFRange visibleRange = CTFrameGetVisibleStringRange(frame);
	CFRange textRange = CTFrameGetStringRange(frame);
	return (visibleRange.location != textRange.location) || (visibleRange.length != textRange.length);
}

- (CGFloat)textOriginVerticalOffset
{
	CGFloat yOffset = 0.0f;
	if (!CGSizeEqualToSize(_textSize, CGSizeZero))
		yOffset = roundf((CGRectGetHeight([self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines]) - _textSize.height) / 2.0f);  //  The vertical offset will be half the difference between the text rect height and the actual text height
	
	return yOffset;
}

#pragma mark - Accessor

- (void)updateFramesetter
{
    if (_framesetter)
        CFRelease(_framesetter);
    
    _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    
    if (_frame)
    {
        CFRelease(_frame);
        _frame = nil;
		_textSize = CGSizeZero;
    }
}

- (void)invalidateTextSize
{
    [self updateFramesetter];
    [self setNeedsDisplay];
	[self invalidateAccessibilityElements];
}

- (void)setNeedsLayout
{
	[super setNeedsLayout];
	[self invalidateAccessibilityElements];
}


- (CTFrameRef)textFrame
{
    // Lazily load the frame but hold onto it for dear life
    if (!_frame)
    {
		CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
		//CGPathRef path = CGPathCreateWithRect(textRect, NULL);
		CGPathRef path = CGPathRetain([self path]);
		if (!path)
		{
			path = CGPathCreateWithRect([self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines], NULL);
		}
        
        _frame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, 0), path, NULL);
		_textSize = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, CFRangeMake(0, 0), NULL, textRect.size, NULL);
        
        CGPathRelease(path);
    }
    return _frame;
}

#pragma mark - Setting Text

- (void)setText:(id)text
{
    NSMutableAttributedString *mutableText = nil;
	
	BOOL shouldApplyParagraphStyle = NO;
	
	if ([text isKindOfClass:[NSString class]])
	{
		self.textIsAttributed = NO;
		mutableText = [[NSMutableAttributedString alloc] initWithString:text];
		[mutableText setFont:self.font];
		[mutableText setColor:self.textColor];
		[mutableText setStrikethrough:self.strikethroughStyle];
		shouldApplyParagraphStyle = YES;
	}
    else
	{
		self.textIsAttributed = YES;
		mutableText = [text mutableCopy];
		shouldApplyParagraphStyle = self.ignoreParagraphStyle;
	}
     
    // Set the text alignment and line break mode
	if (shouldApplyParagraphStyle)
		[mutableText setLineBreakMode:UILineBreakModeWordWrap textAlignment:self.textAlignment];
    
    // Apply data detectors to the new text
    NSMutableAttributedString *matchedString = [self attributedStringForDetectedDataInString:mutableText];
    
    [_text release];
    
    // If there were no modifications to the original set text we don't need to retain the matchedString 
    if (matchedString == mutableText)
        _text = mutableText;
    
    // If we did modify, then we already own matchedString so just make sure to retain it.
    else
	{
        _text = [matchedString retain];
		[mutableText release];
	}
	
	// Determine if we have links (used for default accessibility type)
	_hasLinks = NO;
	[_text enumerateAttribute:kCTLabelLinkKey inRange:NSMakeRange(0, _text.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		if (value)
		{
			_hasLinks = YES;
			*stop = YES;
		}
	}];
    
    [self invalidateTextSize];
}

- (NSString *)text
{
    return self.attributedString.string;
}

- (NSString *)string
{
    return self.attributedString.string;
}

- (NSAttributedString *)attributedString
{
    return _text;
}

#pragma mark - Selection

- (BOOL)hasSelection
{
    return _selectedRange.location != NSNotFound && _selectedRange.length > 0;
}

- (void)clearSelection
{
    _track = NO;
    _selectedRange = NSMakeRange(NSNotFound, 0);
    _selectionBounds = CGRectNull;
    self.highlighted = NO;
    [self setNeedsDisplay];
}

- (CGRect)boundingBoxForRange:(NSRange)range
{
    if (range.location == NSNotFound || range.length == 0)
        return CGRectNull;
    
    CGRect bounds = CGRectNull;
    
    CFArrayRef lines = CTFrameGetLines(self.textFrame);
    CFIndex count = CFArrayGetCount(lines);
    CGPoint *origins = calloc(count, sizeof(CGPoint));
    CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), origins);
    
    for (CFIndex idx = 0; idx < count; idx++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
        
        // Calculate line bounds then adjugst the origin to get the bounds in the view's coordinate space
        CGRect lineBounds = [self boundingBoxForRange:range line:line];
        if (!CGRectIsNull(lineBounds))
            lineBounds.origin.y = origins[idx].y;
        
        bounds = CGRectUnion(bounds, lineBounds);
    }
    
    return bounds;
}

- (CGRect)boundingBoxForRange:(NSRange)range line:(CTLineRef)line
{
    CFRange cfRange = CTLineGetStringRange(line);
    NSRange lineRange = NSMakeRange(cfRange.location, cfRange.length);
    
    if (!NSRangeIntersectsRange(lineRange, range))
        return CGRectNull;
    
    // TODO: For now just grab the whole line bounds
    CGFloat ascent, descent, leading;
    
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex count = CFArrayGetCount(runs);
    CGRect bounds = CGRectNull;
    
    double x = 0.0;
    
    for (CFIndex idx = 0; idx < count; idx++)
    {
        CTRunRef run = CFArrayGetValueAtIndex(runs, idx);
        
        cfRange = CTRunGetStringRange(run);
        lineRange = NSMakeRange(cfRange.location, cfRange.length);
            
        // Calculate run bounds
        double width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
        CGRect runBounds = CGRectMake(x, 0.0f, width, ascent + descent);
        x += width;
        
        if (!NSRangeIntersectsRange(lineRange, range))
            continue;
        
        bounds = CGRectUnion(bounds, runBounds);
    }
    
    return bounds;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted == _highlighted)
        return;
    
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (!_longPressGestureRecognizer)
    {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveLongPress:)];
        _longPressGestureRecognizer.delaysTouchesBegan = NO;
        _longPressGestureRecognizer.delaysTouchesEnded = YES;
        _longPressGestureRecognizer.cancelsTouchesInView = YES;
        _longPressGestureRecognizer.enabled = NO;
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
    return _longPressGestureRecognizer;
}
 
- (void)didSelectTextAtIndex:(NSUInteger)index
{
    NSRange range;
    CTLinkBlock block = [[self.attributedString attributesAtIndex:_selectedRange.location effectiveRange:&range] objectForKey:kCTLabelLinkKey];
    if (block)
        block(self, range, CTLinkBlockSelectionTap);
}

#pragma mark - Hit Testing

- (CGRect)trackingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, -44.0f, -44.0f);
}

- (void)bindTouchToRange:(NSRange)range
{
    _selectedRange = range;
    _track = YES;
    _selectionBounds = [self boundingBoxForRange:_selectedRange];
}

- (NSRange)rangeOfStringAtPoint:(CGPoint)point
{
    NSArray *lines = (NSArray *)CTFrameGetLines(self.textFrame);    
    CGPoint *origins = calloc(lines.count, sizeof(CGPoint));
    CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), origins);
    
	// Allow for vertical centering like UILabel does
	CGRect rect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    CGFloat yOffset = 0.0f;
	if (!CGSizeEqualToSize(_textSize, CGSizeZero))
		yOffset = roundf((CGRectGetHeight(rect) - _textSize.height) / 2.0f);  //  The vertical offset will be half the difference between the text rect height and the actual text height
	
    CGFloat ascent, descent, leading;
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    for (unsigned int i = 0; i < lines.count; i++)
    {
        CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
        double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGRect bounds = CGRectMake(origins[i].x, origins[i].y - yOffset, width, ascent + descent);
        
        // Locate the line containing the point
        if (point.y <= CGRectGetMaxY(bounds) && point.y >= CGRectGetMinY(bounds))
        {
            CFIndex index = CTLineGetStringIndexForPosition(line, CGPointMake(point.x - origins[i].x, point.y - origins[i].y));
            
            if (index < self.text.length)
            {
                range.location = index;
                range.length = 1;
            }
            break;
        }
    }
    
    free(origins);
    return range;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.allowsSelection)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSRange range = [self rangeOfStringAtPoint:point];
    //NSLog(@"%@", NSStringFromRange(range));
    
    if (range.location != NSNotFound)
    {
        NSRange effectiveRange;
        NSDictionary *dictionary = [self.attributedString attributesAtIndex:range.location effectiveRange:&effectiveRange];
        
        // Bind touch if the attributes for the range are a link
        if ([dictionary objectForKey:kCTLabelLinkKey])
        {
            [self bindTouchToRange:effectiveRange];
            self.highlighted = YES;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (_track)
    {
        // Change highlighting state based on the location of the touch.
        self.highlighted = CGRectContainsPoint([self trackingRectForBounds:_selectionBounds], point);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_track)
    {   
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        if (CGRectContainsPoint([self trackingRectForBounds:_selectionBounds], point))
        {
            [self didSelectTextAtIndex:_selectedRange.location];
        }
    }    
    
    [self clearSelection];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self clearSelection];
}


- (void)didReceiveLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{   
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        // TODO: Notify a delegate if there's no link block at the selected index.
		
		NSRange range = [self rangeOfStringAtPoint:[gestureRecognizer locationInView:self]];
		if (range.location != NSNotFound)
		{
			NSDictionary *attributes = [self.attributedString attributesAtIndex:range.location effectiveRange:NULL];
			CTLinkBlock link = [attributes objectForKey:kCTLabelLinkKey];
			if (link)
			{
				link(self, range, CTLinkBlockSelectionLongPress);
			}
		}
    }
}

#pragma mark - Data Detection

- (NSMutableAttributedString *)attributedStringForDetectedDataInString:(NSMutableAttributedString *)text
{
    // Don't check if we don't have text checking types
    if (!self.textCheckingTypes)
        return text;
    
    NSString *string = text.string;
    NSRange range = NSMakeRange(0, string.length);
    
    // Detect data types in the text
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:self.textCheckingTypes error:nil];
    
    // Return early if there were no matches
    NSUInteger numberOfMatches = [detector numberOfMatchesInString:string options:0 range:range];
    if (!numberOfMatches)
        return text;
    

    NSMutableAttributedString *matchedString = [[text mutableCopy] autorelease];
    
    // Iterate over all the matches in the string and add appropriate handler blocks
    NSArray *matches = [detector matchesInString:string options:0 range:range];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        
        void (^block)(void) = nil;
        
        switch (match.resultType) {
            
            case NSTextCheckingTypeLink:
            {
                NSURL *url = [match URL];
                
                // TODO: apparently text checking links can also have the  'tel' URL scheme
                if (![url.scheme isEqualToString:@"http"])
                    continue;
                
                block = [[^{
                    NSLog(@"Matched result: %@", url);
                    // TODO: Do something useful here
                } copy] autorelease];
            }
                break;
            
            case NSTextCheckingTypePhoneNumber:
            {
                block = [[^{
                    NSLog(@"Phone Number: %@", match.phoneNumber);
                } copy] autorelease];
            }
                break;
            
            case NSTextCheckingTypeAddress:
            {
                block = [[^{
                    NSLog(@"Address: %@", match.addressComponents);
                } copy] autorelease];
            }
                
            default:
                break;
        }
        
        // Add the touch handling block as a link
        if (block)
            [matchedString addAttribute:kCTLabelLinkKey value:block range:matchRange];
    }
    
    return matchedString;
}

#pragma mark - Size adjustment

- (CGSize)sizeThatFits:(CGSize)size
{
    if (!self.framesetter)
        return [super sizeThatFits:size];
    
    if (CGSizeEqualToSize(size, CGSizeZero))
        size = self.bounds.size;
    
    // We really only care about the width - height we leave unbounded.
    size.height = CGFLOAT_MAX;
    
    NSRange range = NSMakeRange(0, 0);
	
	CGPathRef path = CGPathRetain([self path]);
	
	// If there is a path, we assume that it's complex
	BOOL useSimplePath = path == nil;
	
	if (!path)
		path = CGPathCreateWithRect([self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines], NULL);
    
	CGSize fitSize = CGSizeMake(size.width, size.height);
	
    // If we're restricted to a certain number of lines, return a smaller height
    if (self.numberOfLines > 0 || !useSimplePath)
    {
        // TODO: This is probably really expensive to create the frame every single time sizeThatFits: is called
		
        CTFrameRef frame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, 0), path, NULL);
        
        CFArrayRef lines = CTFrameGetLines(frame);
		unsigned int lineCount = CFArrayGetCount(lines);
		if (self.numberOfLines)
			lineCount = MIN(lineCount, self.numberOfLines);
        
        // Calculate the visible range for a given number of lines
        for (CFIndex idx = 0; idx < lineCount; idx++)
        {
            CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
            CFRange lineRange = CTLineGetStringRange(line);
            
            range = NSUnionRange(range, NSMakeRange(lineRange.location, lineRange.length));
        }
		
		if (!useSimplePath)
		{
			// Get the last visible line from the frame and the line origins
			CGPoint origins[CFArrayGetCount(lines)];
			CTFrameGetLineOrigins(frame, CFRangeMake(range.location, range.length), origins);

            if (lineCount > 0)
            {
                CTLineRef line = CFArrayGetValueAtIndex(lines, lineCount - 1);
        
                // Origins should start at (0,0), so the height should be the lastLineOrigin.y + lastLineHeight
                CGFloat ascent, descent;
                CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
                fitSize.height = origins[lineCount - 1].y + ascent + descent;
            }
		}
        
        CFRelease(frame);
    }
	CGPathRelease(path);
    
    CFRange cfRange = CFRangeMake(range.location, range.length);
	
	if (useSimplePath)
		fitSize = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, cfRange, NULL, size, NULL);
    
	// Make sure we have integral sizes for our view.
	fitSize = CGSizeMake(ceilf(fitSize.width), ceilf(fitSize.height));
	
    return fitSize;
}

- (void)sizeToFitCurrentWidth
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGSize size = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGRect frame = self.frame;
    frame.size = CGSizeMake(width, size.height);
    self.frame = frame;
}

#pragma mark - Truncation


- (CTLineRef)copyTruncatedLine:(CTLineRef)originalLine width:(CGFloat)maxWidth
{    
    double width = CTLineGetTypographicBounds(originalLine, NULL, NULL, NULL);
    CTLineRef line = NULL;
    
    CFRange cfrange = CTLineGetStringRange(originalLine);
    NSRange range = NSMakeRange(cfrange.location, cfrange.length);
    NSDictionary * attributes = [self.attributedString attributesAtIndex:range.location + range.length - 1 effectiveRange:NULL];
    NSAttributedString *token = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:attributes]; // Ellipse
    
    // Here the width of the line actually exceeds the width of the rect it's being drawn in, so the truncation token is needed to replace text in the line
    if (width > maxWidth)
    {
        // Get the attributes of the last character in the original line so that we can match attributes
        CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)token);
        
        // We definitely want a truncated line, so set the width to be the original width minus the width of the truncation token
        //double width = CTLineGetTypographicBounds(originalLine, NULL, NULL, NULL) - CTLineGetTypographicBounds(truncationToken, NULL, NULL, NULL);
        
        line = CTLineCreateTruncatedLine(originalLine, width, kCTLineTruncationEnd, truncationToken);
        
        [token release];
        CFRelease(truncationToken);
    }
    
    // Here the line can be drawn anyway, but there is additional text so we append the truncation token at the end of the string.
    else
    {
        NSMutableAttributedString *string = [[[self.attributedString attributedSubstringFromRange:range] mutableCopy] autorelease];
        
        // The string can have whitespace / newline characters at the end.  Remove them
        NSString *lineText = string.string;
        NSUInteger end, contentsEnd;
        // Calculate the range of trailing whitespace / newline characters
        [lineText getLineStart:NULL end:&end contentsEnd:&contentsEnd forRange:NSMakeRange(0, lineText.length)];
        NSRange lineRange = NSMakeRange(contentsEnd, end - contentsEnd);
        
        // Remove extraneous characters and append the truncation token
        [string deleteCharactersInRange:lineRange];
        [string appendAttributedString:token];
		
		[token release];
        
        line = CTLineCreateWithAttributedString((CFAttributedStringRef)string);
    }
    
    return line;
}

#pragma mark - Defaults for NSString

- (UIFont *)font
{
	if (!_font)
	{
		_font = [[UIFont systemFontOfSize:[UIFont systemFontSize]] retain];
	}
	return _font;
}

- (UIColor *)textColor
{
	if (!_textColor)
	{
		_textColor = [[UIColor blackColor] retain];
	}
	return _textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
	if (textColor == _textColor)
		return;
	
	[_textColor release];
	_textColor = [textColor retain];
	
	if (!self.textIsAttributed)
	{
		[_text setColor:_textColor];
		[self updateFramesetter];
	}
}

- (void)setFont:(UIFont *)font
{
	if (font == _font)
		return;
	
	[_font release];
	_font = [font retain];
	
	if (!self.textIsAttributed)
	{
		[_text setFont:_font];
		[self updateFramesetter];
	}
}

- (void)setStrikethroughStyle:(BRAttributedStringStrikethroughStyle)strikethroughStyle
{
	if (strikethroughStyle == _strikethroughStyle)
		return;
	
	_strikethroughStyle = strikethroughStyle;
	
	if (!self.textIsAttributed)
	{
		[_text setStrikethrough:_strikethroughStyle];
		[self updateFramesetter];
	}
}

#pragma mark - Path

- (CGPathRef)path
{
	return _path;
}

- (void)setPath:(CGPathRef)path
{
	if (CGPathEqualToPath(path, _path))
		return;
	
	CGPathRelease(_path);
	_path = CGPathCreateCopy(path);
	[self invalidateTextSize];
}


#pragma mark - UIAccessibility

- (NSString *)accessibilityLabel
{
	CFRange range = CTFrameGetVisibleStringRange(self.textFrame);
    return [self.text substringWithRange:NSMakeRange(range.location, range.length)];
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitStaticText;
}

- (BOOL)isAccessibilityElement
{
	switch ([self resolvedAccessibilityType])
	{
		case CTLabelAccessibilityLabel:
			return YES;
			break;
		case CTLabelAccessibilityByLine:
		case CTLabelAccessibilityByParagraph:
			return NO;  // NO because it will be an accessibility container
		default:
			return [super isAccessibilityElement];
			break;
	}
}

- (NSInteger)accessibilityElementCount
{
	if ([self isAccessibilityElement])
		return 0;
	else
		return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
	return [self.accessibilityElements objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
	return [self.accessibilityElements indexOfObject:element];
}

- (NSMutableArray *)accessibilityElements
{
	if ([self isAccessibilityElement])
		return nil;
	
	if (!_accessibilityElements)
	{
		_accessibilityElements = [[NSMutableArray alloc] init];
		
		CTLabelAccessibilityType accessibilityType = [self resolvedAccessibilityType];
		
		if (accessibilityType == CTLabelAccessibilityByLine)
		{
			[self enumerateLinesInFrame:self.textFrame usingBlock:^(CTLineRef line, NSUInteger idx, CGRect frame, BOOL *stop) {
				UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
				
				CGFloat yOffset = [self textOriginVerticalOffset];
				frame.origin.y -= yOffset;

				CGRect accessibilityFrame = [self.window convertRect:frame fromView:self];				
				element.accessibilityFrame = accessibilityFrame;
				
				CFRange range = CTLineGetStringRange(line);
				NSString *lineText = [self.text substringWithRange:NSMakeRange(range.location, range.length)];
				element.accessibilityLabel = lineText;
				
				[_accessibilityElements addObject:element];
			}];
		}
		else if (accessibilityType == CTLabelAccessibilityByParagraph)
		{
			_accessibilityElements = [[NSMutableArray alloc] init];
			
			CTFrameWrapper *wrapper = [[[CTFrameWrapper alloc] initWithFrame:self.textFrame attributedString:self.attributedString] autorelease];
			
			CFRange range = CTFrameGetVisibleStringRange(self.textFrame);
			
			[wrapper enumerateLinesInRange:NSMakeRange(range.location, range.length) options:NSStringEnumerationByParagraphs usingBlock:^(NSArray *lines, CGRect frame, NSRange substringRange, BOOL *stop) {
				
				[self.attributedString enumerateAttribute:kCTLabelLinkKey inRange:substringRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
					CGRect frame = [self boundingBoxForRange:range];
					
					UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
					
					CGFloat yOffset = [self textOriginVerticalOffset];
					
					frame.origin.y -= yOffset;
					
					CGRect accessibilityFrame = [self.window convertRect:frame fromView:self];
					//accessibilityFrame.origin.y += yOffset;
					element.accessibilityFrame = accessibilityFrame;
					
					NSString *lineText = [self.text substringWithRange:NSMakeRange(range.location, range.length)];
					element.accessibilityLabel = lineText;
					
					element.accessibilityTraits = UIAccessibilityTraitStaticText;
					if (value)
					{
						// Need a link trait.  Also need to adjust the touch point
						element.accessibilityTraits |= UIAccessibilityTraitLink;
						if ([element respondsToSelector:@selector(setAccessibilityActivationPoint:)])
						{
							CGRect firstCharacterFrame = [self boundingBoxForRange:NSMakeRange(range.location, 1)];
							element.accessibilityActivationPoint = [self.window convertPoint:firstCharacterFrame.origin fromView:nil];
						}
					}
					
					[_accessibilityElements addObject:element];

				}];

//				UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
//				
//				CGFloat yOffset = [self textOriginVerticalOffset];
//
//				frame.origin.y -= yOffset;
//				
//				CGRect accessibilityFrame = [self.window convertRect:frame fromView:self];
//				//accessibilityFrame.origin.y += yOffset;
//				element.accessibilityFrame = accessibilityFrame;
//				
//				NSString *lineText = [self.text substringWithRange:NSMakeRange(substringRange.location, substringRange.length)];
//				element.accessibilityLabel = lineText;
//				
//				[_accessibilityElements addObject:element];
								
			}];
		}
	}
	return _accessibilityElements;
}

- (void)setAccessibilityType:(CTLabelAccessibilityType)accessibilityType
{
	if (accessibilityType == _accessibilityType)
		return;
	
	_accessibilityType = accessibilityType;
	[self invalidateAccessibilityElements];
}

- (void)invalidateAccessibilityElements
{
	if (_accessibilityElements)
		self.accessibilityElements = nil;
	
	// Post notification so thtat the screen will be updated
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (CTLabelAccessibilityType)resolvedAccessibilityType
{
	if (self.accessibilityType == CTLabelAccessibilityDefault)
	{
		if (_hasLinks)
			return CTLabelAccessibilityByParagraph;
		else
			return CTLabelAccessibilityLabel;
	}
	else
		return self.accessibilityType;
}

#pragma mark - enumeration

- (void)enumerateLinesInFrame:(CTFrameRef)frame usingBlock:(void(^)(CTLineRef line, NSUInteger idx, CGRect frame, BOOL *stop))block
{
	if (!frame || !block)
		return;
	
	NSArray *lines = (NSArray *)CTFrameGetLines(frame);
	
	CGPoint *origins = malloc(sizeof(CGPoint) * lines.count);
	CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
	
	[lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CTLineRef line = (CTLineRef)obj;
		
		CGFloat ascent, descent, leading;
		double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
		
		CGRect textFrame = CGRectMake(origins[idx].x, origins[idx].y, width, ascent + descent);
		
		block(line, idx, textFrame, stop);
	}];
	
	free(origins);
}

@end


#pragma mark - NSMutableAttributedString

NSString *const kCTLabelLinkKey = @"kCTLabelLinkKey";
NSString *const kCTLabelLinkHighlightedForegroundColorKey = @"kCTLabelLinkHighlightedForegroundColorKey";

@implementation NSMutableAttributedString (CTLabel)

- (void)setLink:(CTLinkBlock)block
{
    [self setLink:block range:NSMakeRange(0, self.length)];
}

- (void)setLink:(CTLinkBlock)block range:(NSRange)range
{
    [self setLink:block range:range selectedColor:nil];
}

- (void)setLink:(CTLinkBlock)block range:(NSRange)range selectedColor:(UIColor *)selectedColor
{
    CTLinkBlock linkBlock = [block copy];
    [self addAttribute:kCTLabelLinkKey value:linkBlock range:range];
    [linkBlock release];
    
    if (selectedColor)
        [self addAttribute:kCTLabelLinkHighlightedForegroundColorKey value:(id)selectedColor.CGColor range:range];
}

@end