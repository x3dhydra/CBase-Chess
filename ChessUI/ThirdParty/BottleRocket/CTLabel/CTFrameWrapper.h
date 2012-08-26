//
//  CTFrameWrapper.h
//  CoreTextPlayground
//
//  Created by Austen Green on 6/11/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CTFrameWrapper : NSObject
@property (nonatomic, readonly) CTFrameRef frame;
@property (nonatomic, readonly) NSAttributedString *attributedString;

- (id)initWithFrame:(CTFrameRef)frame attributedString:(NSAttributedString *)string;;

- (void)enumerateLinesUsingBlock:(void(^)(CTLineRef line, CGRect frame, NSUInteger index, BOOL *stop))block;
- (void)enumerateLinesInRange:(NSRange)range options:(NSStringEnumerationOptions)options usingBlock:(void(^)(NSArray *lines, CGRect frame, NSRange substringRange, BOOL *stop))block;

@end
