//
//  CKBoardView.m
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKBoardView.h"

@implementation CKBoardView
@synthesize lightSquareColor = _lightSquareColor;
@synthesize darkSquareColor = _darkSquareColor;
@synthesize lightSquareImage = _lightSquareImage;
@synthesize darkSquareImage = _darkSquareImage;
@synthesize flipped = _flipped;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    for (CCSquare square = a1; square <= h8; square++) 
    {
        CGRect squareRect = [self rectForSquare:square];
        id squareBackground = nil;
        
        if (CCSquareIsLightSquare(square))
            squareBackground = self.lightSquareImage ?: self.lightSquareColor;
        else 
            squareBackground = self.darkSquareImage ?: self.darkSquareColor;
        
        if ([squareBackground isKindOfClass:[UIImage class]])
        {
            [(UIImage *)squareBackground drawInRect:squareRect];
        }
        else
        {
            [(UIColor *)squareBackground set];
            UIRectFill(squareRect);
        }
        
        NSString *name = (__bridge NSString *)CCSquareName(square);
        [[UIColor blackColor] set];
        [name drawInRect:squareRect withFont:[UIFont systemFontOfSize:14.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    // Since this is a chessboard, we want sizeToFit to be a square.
    // Returns the largest square that fits within the constraints of size
    CGFloat length = MIN(size.width, size.height);
    return CGSizeMake(length, length);
}

- (UIColor *)lightSquareColor
{
    if (!_lightSquareColor)
    {
        _lightSquareColor = [[self class] lightSquareColor];
    }
    return _lightSquareColor;
}

- (UIColor *)darkSquareColor
{
    if (!_darkSquareColor)
    {
        _darkSquareColor = [[self class] darkSquareColor];
    }
    return _darkSquareColor;
}

- (CGRect)rectForSquare:(CCSquare)square
{
    int rank = CCSquareRank(square);
    int file = CCSquareFile(square);
    
    if (self.isFlipped)
    {
        rank = 7 - rank;
        file = 7 - file;
    }
    
    // Only draw inside of a square
    CGSize size = [self sizeThatFits:self.bounds.size];
    CGFloat squareLength = size.width / 8.0f;
    
    CGRect rect = CGRectIntegral(CGRectMake(file * squareLength, (7 - rank) * squareLength, squareLength, squareLength));
    
    // Don't exceed the constraints given by size
    if (CGRectGetMaxX(rect) > size.width)
        rect.size.width -= (CGRectGetMaxX(rect) - size.width);
    if (CGRectGetMaxY(rect) > size.height)
        rect.size.height -= (CGRectGetMaxY(rect) - size.height);
    
    return rect;
}

- (void)setFlipped:(BOOL)flipped
{
    [self setFlipped:flipped animated:NO];
}

- (void)setFlipped:(BOOL)flipped animated:(BOOL)animated
{
    if (flipped == _flipped)
        return;
    
    _flipped = flipped;
    [self setNeedsDisplay];
    [self setNeedsLayout];
    // TODO: Animate
}

#pragma mark - Class Methods

+ (UIColor *)lightSquareColor
{
    return [UIColor colorWithRed: 218.0/255.0 green: 218.0/255.0 blue: 218.0/255.0 alpha: 1.0];
}

+ (UIColor *)darkSquareColor
{
    return [UIColor colorWithRed: 107.0/255.0 green: 123.0/255.0 blue: 169.0/255.0 alpha: 1.0];
}


@end
