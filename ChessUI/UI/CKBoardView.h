//
//  CKBoardView.h
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSquare.h"

@interface CKBoardView : UIView

// Default square colors if there are none set
+ (UIColor *)lightSquareColor;
+ (UIColor *)darkSquareColor;

@property (nonatomic, strong) UIColor *lightSquareColor;
@property (nonatomic, strong) UIColor *darkSquareColor;

// Setting an image for light / dark squares takes precedence over color
@property (nonatomic, strong) UIImage *lightSquareImage;
@property (nonatomic, strong) UIImage *darkSquareImage;

@property (nonatomic, assign, getter = isFlipped) BOOL flipped;
- (void)setFlipped:(BOOL)flipped animated:(BOOL)animated;

- (NSIndexSet *)squaresInRect:(CGRect)rect;
- (CGRect)rectForSquare:(CCSquare)square;

@end
