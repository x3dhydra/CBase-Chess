//
//  CKBoardTheme.m
//  CBase Chess
//
//  Created by Austen Green on 9/3/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKBoardTheme.h"

NSString * const CKBoardThemeDidChangeNotification = @"CKBoardThemeDidChangeNotification";
static CKBoardTheme *_defaultTheme;

@interface CKBoardTheme()
{
	NSMutableDictionary *_imageMap;
}
@end

@implementation CKBoardTheme

+ (id)defaultTheme
{
	return _defaultTheme;
}

+ (void)setDefaultTheme:(CKBoardTheme *)theme
{
	if (theme && theme != _defaultTheme)
	{
		_defaultTheme = theme;
		[[NSNotificationCenter defaultCenter] postNotificationName:CKBoardThemeDidChangeNotification object:nil userInfo:@{ @"boardTheme" : theme }];
	}
}

- (id)init
{
	return [self initWithPiecePrefix:nil extension:nil];
}

- (id)initWithPiecePrefix:(NSString *)prefix extension:(NSString *)extension
{
	self = [super init];
	if (self)
	{
		_imageMap = [[NSMutableDictionary alloc] init];
		if (prefix)
			[self loadImagesForPrefix:prefix extension:extension];
	}
	return self;
}

- (void)loadImagesForPrefix:(NSString *)prefix extension:(NSString *)extension
{
	NSArray *pieceNames = @[@"WBishop", @"BBishop", @"WKing", @"BKing", @"WRook", @"BRook", @"WPawn", @"BPawn", @"WQueen", @"BQueen", @"WKnight", @"BKnight"];
	NSArray *pieces = @[ @(WB), @(BB), @(WK), @(BK), @(WR), @(BR), @(WP), @(BP), @(WQ), @(BQ), @(WN), @(BN) ];
	
	[pieceNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop)
	{
		CCColoredPiece piece = [[pieces objectAtIndex:idx] integerValue];
		NSString *imageName;
		if (extension)
			imageName = [NSString stringWithFormat:@"%@%@.%@", prefix, name, extension];
		else
			imageName = [NSString stringWithFormat:@"%@%@", prefix, name];
		
		UIImage *image = [UIImage imageNamed:imageName];
		[self setImage:image forPiece:piece];
	}];
}

- (void)setImage:(UIImage *)image forPiece:(CCColoredPiece)piece
{
	id key = @(piece);
	if (image)
		[_imageMap setObject:image forKey:key];
	else
		[_imageMap removeObjectForKey:key];
}

- (UIImage *)imageForPiece:(CCColoredPiece)piece
{
	id key = @(piece);
	return [_imageMap objectForKey:key];
}

@end
