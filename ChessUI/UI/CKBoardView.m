//
//  CKBoardView.m
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKBoardView.h"
#import "CKPosition.h"

typedef void (^CKAnimationBlock)(void);

@interface CKBoardView()
{
    CCMutableBoardRef _board;
    NSMutableDictionary *_pieceImages;
}
@property (nonatomic, strong) NSMutableDictionary *pieceViews;
@property (nonatomic, strong) NSArray *squareAccessibilityElements;
@end

@implementation CKBoardView
@synthesize lightSquareColor = _lightSquareColor;
@synthesize darkSquareColor = _darkSquareColor;
@synthesize lightSquareImage = _lightSquareImage;
@synthesize darkSquareImage = _darkSquareImage;
@synthesize flipped = _flipped;
@synthesize debugSquares = _debugSquares;
@synthesize pieceViews = _pieceViews;
@synthesize squareAccessibilityElements = _squareAccessibilityElements;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _board = CCBoardCreateMutable();
        _pieceViews = [[NSMutableDictionary alloc] initWithCapacity:32];
        _pieceImages = [[NSMutableDictionary alloc] initWithCapacity:12];
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
        
        // Images take precedence over colors when drawing squares
        if ([squareBackground isKindOfClass:[UIImage class]])
        {
            [(UIImage *)squareBackground drawInRect:squareRect];
        }
        else
        {
            [(UIColor *)squareBackground set];
            UIRectFill(squareRect);
        }
        
        if (self.debugSquares)
        {
            // Draw square names into each square
            NSString *name = (__bridge NSString *)CCSquareName(square);
            [[UIColor blackColor] set];
            [name drawInRect:squareRect withFont:[UIFont systemFontOfSize:14.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        }
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
    
    // (7 - rank) since the top row of squares (in non-flipped geometry) is actually the 8th rank
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
        
    void (^animationBlock)(void) = ^ {
        [self.pieceViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CCSquare square = [key intValue];
            UIImageView *view = obj;
            
            view.frame = [self rectForSquare:square];
        }];

    };
    
    if (animated)
        [UIView animateWithDuration:0.3 animations:animationBlock];
    else
        animationBlock();
    
    
    // nil out the accessibility elements
    if (_squareAccessibilityElements)
    {
        self.squareAccessibilityElements = nil;
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
}

- (void)setDebugSquares:(BOOL)debugSquares
{
    _debugSquares = debugSquares;
    [self setNeedsDisplay];
}

- (void)setPiece:(CCColoredPiece)piece atSquare:(CCSquare)square
{
    if (piece == NoColoredPiece)
    {
        [self removePieceFromSquare:square];
        return;
    }
    
    id key = [NSNumber numberWithInt:square];
    
    UIImageView *imageView = [self.pieceViews objectForKey:key];
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.pieceViews setObject:imageView forKey:key];
    }
    imageView.image = [self imageForPiece:piece];
    imageView.frame = [self rectForSquare:square];
    
    [self addSubview:imageView];
}

- (void)removePieceFromSquare:(CCSquare)square
{
    id key = [NSNumber numberWithInt:square];
    
    UIImageView *imageView = [self.pieceViews objectForKey:key];
    [imageView removeFromSuperview];
    [self.pieceViews removeObjectForKey:key];
}

#pragma mark - Piece Images

- (UIImage *)imageForPiece:(CCColoredPiece)piece
{
    return [_pieceImages objectForKey:[NSNumber numberWithInt:piece]];
}

- (void)setImage:(UIImage *)image forPiece:(CCColoredPiece)piece
{
    [_pieceImages setObject:image forKey:[NSNumber numberWithInt:piece]];
}

// Dictionary with keys for each colored piece, wrapped as an NSNumber.  Raises an exception if any of the images are missing
- (void)setPieceImages:(NSDictionary *)pieceImages
{
    _pieceImages = [NSMutableDictionary dictionaryWithDictionary:pieceImages];
}

- (NSDictionary *)pieceImages
{
    return [NSDictionary dictionaryWithDictionary:_pieceImages];
}

#pragma mark - ChessKit Convenience Methods

- (void)setPosition:(CKPosition *)position
{
    [self setPosition:position withAnimation:CKBoardAnimationNone];
    
}

- (void)setPosition:(CKPosition *)position withAnimation:(CKBoardAnimation)animation
{
    if (animation == CKBoardAnimationNone)
    {
        CCBoardRelease(_board);
        _board = CCBoardCreateMutableCopy(position.board);
        
        for (CCSquare square = a1; square <= h8; square++)
        {
            CCColoredPiece piece = CCBoardGetPieceAtSquare(_board, square);
            [self setPiece:piece atSquare:square];
        }
    }
    else if (animation == CKBoardAnimationFade)
    {
        CCBoardRelease(_board);
        _board = CCBoardCreateMutableCopy(position.board);
        
        [UIView animateWithDuration:0.3 animations:^{
            for (UIImageView *pieceView in [self.pieceViews objectEnumerator])
                pieceView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            for (UIImageView *pieceView in [self.pieceViews objectEnumerator])
                [pieceView removeFromSuperview];
            
            [self.pieceViews removeAllObjects];
            
            for (CCSquare square = a1; square <= h8; square++)
            {
                CCColoredPiece piece = CCBoardGetPieceAtSquare(_board, square);
                [self setPiece:piece atSquare:square];
            }
            
            for (UIImageView *pieceView in [self.pieceViews objectEnumerator])
                pieceView.alpha = 0.0f;
            
            [UIView animateWithDuration:0.3 animations:^{
                for (UIImageView *pieceView in [self.pieceViews objectEnumerator])
                    pieceView.alpha = 1.0f;
            }];
        }];
    }
    else if (animation == CKBoardAnimationDelta)
    {
        [self animateDifferenceToBoard:position.board];
    }
}

- (void)animateDifferenceToBoard:(CCBoardRef)board
{
    NSMutableArray *animations = [NSMutableArray array];
    NSMutableArray *completion = [NSMutableArray array];
    
    [CCPieceGetAllPieces() enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        CCColoredPiece piece = (CCColoredPiece)idx;
        CCBitboard old = CCBoardGetBitboardForColoredPiece(_board, piece);
        CCBitboard new = CCBoardGetBitboardForColoredPiece(board, piece);
        CCBitboard delta = old ^ new;
        
        if (delta == EmptyBB)
            return;
        
        // For any given bitboard, there are five cases to consider
        // 1. The piece has been moved, so delta & the occupancy bitboard for both old and new yields a unique square
        // 2. The piece was captured, so only (delta & old) will yield a non-empty bitboard
        // 3. The piece is being uncapture, so only (delta & new) will yield a non-empty bitboard
        // 4. A pawn is being queened
        // 5. A queening is being retracted
        
        // Case 1
        if ((old & delta) && (new & delta))
        {
            CCSquare from = CCSquareForBitboard(old & delta);
            CCSquare to = CCSquareForBitboard(new & delta);
            
            if (CCSquareIsValid(from) && CCSquareIsValid(to))
            {
                UIImageView *imageView = [self.pieceViews objectForKey:[NSNumber numberWithInt:from]];
                NSAssert(imageView != nil, @"imageView should not be nil - internal inconsistency");
                [self.pieceViews removeObjectForKey:[NSNumber numberWithInt:from]];
                [self bringSubviewToFront:imageView];
                
                [animations addObject:[^{
                    imageView.frame = [self rectForSquare:to];
                } copy]];
                
                [completion addObject:[^{
                    [self.pieceViews setObject:imageView forKey:[NSNumber numberWithInt:to]];
                } copy]];
            }
        }
        
        // Case 2 - captured
        if ((old & delta) && (new & delta) == EmptyBB)
        {
            CCSquare capture = CCSquareForBitboard(old & delta);
            if (CCSquareIsValid(capture))
            {
                UIImageView *imageView = [self.pieceViews objectForKey:[NSNumber numberWithInt:capture]];
                [self.pieceViews removeObjectForKey:[NSNumber numberWithInt:capture]];
                
                [animations addObject:[^{
                    imageView.alpha = 0.0f;
                } copy]];
                
                [completion addObject:[^{
                    [imageView removeFromSuperview];
                } copy]];
            }
        }
        
        // Case 3 - uncapture
        if ((new & delta) && (old & delta) == EmptyBB)
        {
            CCSquare uncapture = CCSquareForBitboard(new & delta);
            if (CCSquareIsValid(uncapture))
            {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageForPiece:piece]];
                imageView.alpha = 0.0f;
                imageView.frame = [self rectForSquare:uncapture];
                [self addSubview:imageView];
                
                [animations addObject:[^{
                    imageView.alpha = 1.0f;
                } copy]];
                
                [completion addObject:[^{
                    [self.pieceViews setObject:imageView forKey:[NSNumber numberWithInt:uncapture]];
                } copy]];
            }

        }
    }];
    
    CCBoardRelease(_board);
    _board = CCBoardCreateMutableCopy(board);
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [animations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CKAnimationBlock animationBlock = obj;
            animationBlock();
        }];
    } completion:^(BOOL finished) {
        [completion enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CKAnimationBlock completionBlock = obj;
            completionBlock();
        }];
        self.userInteractionEnabled = YES;
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.pieceViews enumerateKeysAndObjectsUsingBlock:^(id key, UIImageView *view, BOOL *stop) {
        CCSquare square = [key integerValue];
        view.frame = [self rectForSquare:square];
    }];
    
//    for (CCSquare square = a1; square < h8; square++)
//    {
//        CCColoredPiece piece = CCBoardGetPieceAtSquare(_board, square);
//        [self setPiece:piece atSquare:square];
//    }
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

#pragma mark - Accessibility

- (NSInteger)accessibilityElementCount
{
    return self.squareAccessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [self.squareAccessibilityElements objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [self.squareAccessibilityElements indexOfObject:element];
}

- (NSArray *)squareAccessibilityElements
{
    if (!_squareAccessibilityElements)
    {
        NSMutableArray *elements = [NSMutableArray arrayWithCapacity:64];
        for (CCSquare square = a1; square <= h8; square++)
        {
            UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
            element.accessibilityFrame = [self convertRect:[self rectForSquare:square] toView:self.window];
            element.accessibilityLabel = (__bridge NSString *)CCSquareName(square);
            [elements addObject:element];
        }
        _squareAccessibilityElements = elements;
    }
    return _squareAccessibilityElements;
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
}

@end
