//
//  CKBoardView.h
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSquare.h"
#import "CCBoard.h"

typedef enum 
{
    CKBoardAnimationNone,
    CKBoardAnimationFade,
    CKBoardAnimationDelta,
} CKBoardAnimation;

@class CKPosition, CKMove;
@protocol CKBoardViewDelegate;

@interface CKBoardView : UIView

// Default square colors if there are none set
+ (UIColor *)lightSquareColor;
+ (UIColor *)darkSquareColor;

@property (nonatomic, strong) UIColor *lightSquareColor;
@property (nonatomic, strong) UIColor *darkSquareColor;

// Setting an image for light / dark squares takes precedence over color
@property (nonatomic, strong) UIImage *lightSquareImage;
@property (nonatomic, strong) UIImage *darkSquareImage;

@property (nonatomic, assign) BOOL debugSquares; // If YES then square names will be drawn on the squares

@property (nonatomic, assign, getter = isFlipped) BOOL flipped;
- (void)setFlipped:(BOOL)flipped animated:(BOOL)animated;

@property (nonatomic, assign) BOOL allowsSelection;  // Default NO
@property (nonatomic, weak) id<CKBoardViewDelegate> delegate;

- (NSIndexSet *)squaresInRect:(CGRect)rect;
- (CGRect)rectForSquare:(CCSquare)square;
- (CCSquare)squareAtPoint:(CGPoint)point;

- (void)setPiece:(CCColoredPiece)piece atSquare:(CCSquare)square;
- (void)removePieceFromSquare:(CCSquare)square;

- (UIImage *)imageForPiece:(CCColoredPiece)piece;
- (void)setImage:(UIImage *)image forPiece:(CCColoredPiece)piece;

// Dictionary with keys for each colored piece, wrapped as an NSNumber.  Raises an exception if any of the images are missing
- (void)setPieceImages:(NSDictionary *)pieceImages;
- (NSDictionary *)pieceImages;

- (void)reloadPieces;

@end

@protocol CKBoardViewDelegate <NSObject>
@required

- (CKPosition *)boardView:(CKBoardView *)boardView positionForMove:(CKMove *)move;  // Return nil to indicate the move is invalid

@optional
- (BOOL)boardView:(CKBoardView *)boardView canSelectSquare:(CCSquare)square;

@end

@interface CKBoardView (ChessKitAdditions)
- (void)setPosition:(CKPosition *)position;
- (void)setPosition:(CKPosition *)position withAnimation:(CKBoardAnimation)animation;
@end