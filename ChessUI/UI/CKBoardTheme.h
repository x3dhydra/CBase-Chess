//
//  CKBoardTheme.h
//  CBase Chess
//
//  Created by Austen Green on 9/3/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreChess.h"

@interface CKBoardTheme : NSObject

+ (id)defaultTheme;
+ (void)setDefaultTheme:(CKBoardTheme *)theme;

@property (nonatomic, strong) UIImage *lightSquareImage;
@property (nonatomic, strong) UIImage *darkSquareImage;

@property (nonatomic, strong) UIColor *lightSquareColor;
@property (nonatomic, strong) UIColor *darkSquareColor;

- (void)setImage:(UIImage *)image forPiece:(CCColoredPiece)piece;
- (UIImage *)imageForPiece:(CCColoredPiece)piece;

// Specify a prefix in order to simplify the loading of images with a naming scheme.
// The scheme expects a format of "[prefix][Color][Piece name].[extension]
// where Color is either "W" or "B" for White and Black respectively, and Piece name
// is an English piece name beginning with a capital letter (e.x. "Bishop").
// You do not have to provide an extension if the image set is composed of PNGs.
- (id)initWithPiecePrefix:(NSString *)prefix extension:(NSString *)extension;

@end

extern NSString * const CKBoardThemeDidChangeNotification;  // Posted when +setDefaultTheme: is called - userInfo contains the new theme for key "boardTheme"
