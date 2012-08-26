//
//  CTFrameWrapper.m
//  CoreTextPlayground
//
//  Created by Austen Green on 6/11/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CTFrameWrapper.h"

@implementation CTFrameWrapper
@synthesize frame = _frame;
@synthesize attributedString = _attributedString;

- (id)initWithFrame:(CTFrameRef)frame attributedString:(NSAttributedString *)string
{
	self = [super init];
	if (self)
	{
		if (frame)
			_frame = CFRetain(frame);
		_attributedString = string;
	}
	return self;
}

- (void)dealloc
{
	if (_frame)
		CFRelease(_frame);
}

- (void)enumerateLinesUsingBlock:(void(^)(CTLineRef line, CGRect frame, NSUInteger index, BOOL *stop))block
{	
	NSArray *lines = (__bridge NSArray *)CTFrameGetLines(self.frame);
	
	CGPoint *origins = malloc(sizeof(CGPoint) * lines.count);
	CTFrameGetLineOrigins(self.frame, CFRangeMake(0, 0), origins);
	
	[lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CTLineRef line = (__bridge CTLineRef)obj;
		
		CGFloat ascent, descent, leading;
		double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
		
		CGRect textFrame = CGRectMake(origins[idx].x, origins[idx].y, width, ascent + descent);
		
		block(line, textFrame, idx, stop);
	}];
	
	free(origins);

}

- (void)enumerateLinesInRange:(NSRange)range options:(NSStringEnumerationOptions)options usingBlock:(void(^)(NSArray *lines, CGRect frame, NSRange substringRange, BOOL *stop))block
{
	if (!block)
		return;
	
	NSMutableArray *ranges = [NSMutableArray array];
	
	[self.attributedString.string enumerateSubstringsInRange:range options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		[ranges addObject:[NSValue valueWithRange:substringRange]];
	}];
	
	if (!ranges.count)
		return;
	
	NSMutableArray *lines = [NSMutableArray array];
	__block CGRect rect = CGRectNull;
	
	[ranges enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
		NSRange range = [value rangeValue];
		[self enumerateLinesUsingBlock:^(CTLineRef line, CGRect frame, NSUInteger index, BOOL *stop) {
			CFRange aRange = CTLineGetStringRange(line);
			NSRange lineRange = NSMakeRange(aRange.location, aRange.length);
			
			if (NSIntersectionRange(range, lineRange).length)
			{
				[lines addObject:(__bridge id)line];
				rect = CGRectUnion(rect, frame);
			}
		}];
		
		block(lines, rect, range, stop);
		
		[lines removeAllObjects];
		rect = CGRectNull;
	}];
}


@end
