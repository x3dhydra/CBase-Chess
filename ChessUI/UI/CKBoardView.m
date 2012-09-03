//
//  CKBoardView.m
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKBoardView.h"
#import "CKPosition.h"
#import "CBaseConstants.h"
#import "CKAccessibility.h"
#import "CKMove.h"

static const CGFloat kHighlightedSquareStrokeWidth = 4.0f;

typedef void (^CKAnimationBlock)(void);

@interface CKBoardView() <UIGestureRecognizerDelegate>
{
    CCMutableBoardRef _board;
    NSMutableDictionary *_pieceImages;
}
@property (nonatomic, strong) NSMutableDictionary *pieceViews;
@property (nonatomic, strong) NSArray *squareAccessibilityElements;
@property (nonatomic, strong) NSMutableArray *animationCompletionBlocks;
@property (nonatomic, strong) UIPanGestureRecognizer *selectionPan;
@property (nonatomic, strong) UITapGestureRecognizer *selectionTap;
@property (nonatomic, strong) NSMutableIndexSet *highlightedSquares;
@property (nonatomic, assign) CCSquare selectedSquare;
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
@synthesize animationCompletionBlocks = _animationCompletionBlocks;
@synthesize boardTheme = _boardTheme;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _board = CCBoardCreateMutable();
        _pieceViews = [[NSMutableDictionary alloc] initWithCapacity:32];
        _pieceImages = [[NSMutableDictionary alloc] initWithCapacity:12];
        _animationCompletionBlocks = [[NSMutableArray alloc] init];
	
		_selectionPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(piecePanned:)];
		_selectionPan.delegate = self;
		[self addGestureRecognizer:_selectionPan];
		
		_selectionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(squareTapped:)];
		_selectionTap.delegate = self;
		[self addGestureRecognizer:_selectionTap];
		
		_selectedSquare = InvalidSquare;
		
		_highlightedSquares = [[NSMutableIndexSet alloc] init];
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
		
		[self.highlightedSquares enumerateIndexesUsingBlock:^(CCSquare square, BOOL *stop) {
			CGRect frame = [self rectForSquare:square];
			frame = CGRectInset(frame, kHighlightedSquareStrokeWidth / 2.0f, kHighlightedSquareStrokeWidth / 2.0f);
			CGContextRef context = UIGraphicsGetCurrentContext();
			UIGraphicsPushContext(context);
			CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
			CGContextStrokeRectWithWidth(context, frame, kHighlightedSquareStrokeWidth);
			UIGraphicsPopContext();
		}];
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
		UIColor *lightSquareColor = [self.boardTheme lightSquareColor];
		if (lightSquareColor)
			return lightSquareColor;
		
        _lightSquareColor = [[self class] lightSquareColor];
    }
    return _lightSquareColor;
}

- (UIColor *)darkSquareColor
{
    if (!_darkSquareColor)
    {
        UIColor *darkSquareColor = [self.boardTheme darkSquareColor];
		if (darkSquareColor)
			return darkSquareColor;
		
		_darkSquareColor = [[self class] darkSquareColor];
    }
    return _darkSquareColor;
}

- (UIImage *)darkSquareImage
{
	if (!_darkSquareImage)
		return [self.boardTheme darkSquareImage];
	else
		return _darkSquareImage;
}

- (UIImage *)lightSquareImage
{
	if (!_lightSquareImage)
		return [self.boardTheme lightSquareImage];
	else
		return _lightSquareImage;
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

- (CCSquare)squareAtPoint:(CGPoint)point
{
	CGSize size = [self sizeThatFits:self.bounds.size];
    CGFloat squareLength = size.width / 8.0f;
	
	if (point.x < 0.0 || point.y < 0.0 || point.x > size.width || point.y > size.height)
		return InvalidSquare;
	
	signed char file = floorf(point.x / squareLength);
	signed char rank = floorf(point.y / squareLength);
	
	if (self.isFlipped)
		file = 7 - file;
	else
		rank = 7 - rank;
	
	return CCSquareMake(rank, file);
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

- (CKBoardTheme *)boardTheme
{
	if (_boardTheme)
		return _boardTheme;
	else
		return [CKBoardTheme defaultTheme];
}

- (void)setBoardTheme:(CKBoardTheme *)boardTheme
{
	_boardTheme = boardTheme;
	[self setNeedsLayout];
}

- (UIImage *)imageForPiece:(CCColoredPiece)piece
{
	return [self.boardTheme imageForPiece:piece];
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
    NSMutableArray *completion = self.animationCompletionBlocks;
    
    if (completion.count)
    {
        [completion enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CKAnimationBlock completionBlock = obj;
            completionBlock();
        }];
        [completion removeAllObjects];
    }
    
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
        
        if (finished)
        {
            [completion enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CKAnimationBlock completionBlock = obj;
                completionBlock();
            }];
            [completion removeAllObjects];
        }
        self.userInteractionEnabled = YES;
        self.squareAccessibilityElements = nil;  // Reset Accessibility
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
            
            NSString *squareName = [(__bridge NSString *)CCSquareName(square) uppercaseString];
            NSString *accessibilityLabel = nil;
            
            CCColoredPiece piece = CCBoardGetPieceAtSquare(_board, square);
            
            if (piece != NoPiece)
            {
                NSString *pieceName = CKAccessibilityNameForColoredPiece(piece);
                NSString *format = NSLocalizedString(@"CK_ACCESSIBILITY_PIECE_SQUARE", @"Accessibility format string for board view.  First argument is the piece name, second argument is square.");
                accessibilityLabel = [NSString stringWithFormat:format, pieceName, squareName];
            }
            else
                accessibilityLabel = squareName;
            
            element.accessibilityLabel = accessibilityLabel;
            
			if (square == self.selectedSquare)
				element.accessibilityTraits |= UIAccessibilityTraitSelected;
			
            [elements addObject:element];
        }
        _squareAccessibilityElements = elements;
    }
    return _squareAccessibilityElements;
}

- (UIView *)pieceViewForSquare:(CCSquare)square
{
	NSNumber *key = [NSNumber numberWithInteger:square];
	return [self.pieceViews objectForKey:key];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (!self.allowsSelection)
		return NO;
	
	if (gestureRecognizer == self.selectionTap)
		return YES;
	
	if (gestureRecognizer == self.selectionPan && UIAccessibilityIsVoiceOverRunning())
		return NO;
	
	CGPoint point = [touch locationInView:self];
	CCSquare square = [self squareAtPoint:point];
	
	CCPiece piece = CCBoardGetPieceAtSquare(_board, square);
	if (CCPieceIsValid(piece))
	{
		BOOL canSelect = [self canSelectSquare:square];
		if (canSelect)
		{
			return YES;
		}
	}
		
	return NO;
}

- (void)piecePanned:(UIPanGestureRecognizer *)pan
{
	if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged)
	{
		CGPoint point = [pan locationInView:self];
		CCSquare square = [self squareAtPoint:point];
		
		if (pan.state == UIGestureRecognizerStateBegan)
		{
			[self setSelectedSquare:square];
		}
		
		CGPoint translation = [pan translationInView:self];
		UIView *pieceView = [self pieceViewForSquare:self.selectedSquare];
		pieceView.frame = CGRectOffset(pieceView.frame, translation.x, translation.y);
		[pan setTranslation:CGPointZero inView:self];
		
		// Make sure the piece comes to the front so that it's always visible
		if (pan.state == UIGestureRecognizerStateBegan)
			[self bringSubviewToFront:pieceView];
	}
	else if (pan.state == UIGestureRecognizerStateEnded)
	{
		CGPoint point = [pan locationInView:self];
		CCSquare square = [self squareAtPoint:point];
		
		[self tryMoveFromSquare:self.selectedSquare toSquare:square];
	}
	else if (pan.state == UIGestureRecognizerStateCancelled)
	{
		[self cancelPendingMove:YES];
	}
}

- (void)squareTapped:(UITapGestureRecognizer *)tap
{
	if (tap.state == UIGestureRecognizerStateRecognized)
	{
		CCSquare square = [self squareAtPoint:[tap locationInView:self]];
		if (square == self.selectedSquare)
		{
			[self cancelPendingMove:NO];
			return;
		}
		
		if (self.selectedSquare == InvalidSquare)
		{
			CCPiece piece = CCBoardGetPieceAtSquare(_board, square);
			if (CCPieceIsValid(piece) && [self canSelectSquare:square])
			{
				[self setSelectedSquare:square];
			}
		}
		else
		{
			// User tapped off square
			[self tryMoveFromSquare:self.selectedSquare toSquare:square];
		}
	}
}

#pragma mark - Selection

- (void)setSelectedSquare:(CCSquare)selectedSquare
{
	_selectedSquare = selectedSquare;
	if (_selectedSquare != InvalidSquare)
	{
		[self.highlightedSquares addIndex:_selectedSquare];
		[self setNeedsDisplayInRect:[self rectForSquare:_selectedSquare]];
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:NSLocalizedString(@"Selected: %@", @"Selected square accessibility"), CCSquareName(selectedSquare)]);
	}
	else
	{
		[self.highlightedSquares removeAllIndexes];
		[self setNeedsDisplay];
	}
	
	self.squareAccessibilityElements = nil;
}

- (BOOL)canSelectSquare:(CCSquare)square
{
	return [self.delegate respondsToSelector:@selector(boardView:canSelectSquare:)] ? [self.delegate boardView:self canSelectSquare:square] : YES;
}

- (void)tryMoveFromSquare:(CCSquare)from toSquare:(CCSquare)to
{
	if (!self.delegate)
		return;
	
	CKMove *move = [CKMove moveWithFrom:from to:to];
	CKPosition *position = [self.delegate boardView:self positionForMove:move];
	if (position)
	{
		[self setPosition:position withAnimation:CKBoardAnimationDelta];
		self.selectedSquare = InvalidSquare;
	}
	else
		[self cancelPendingMove:YES];
}

- (void)cancelPendingMove:(BOOL)animated
{
	self.selectedSquare = InvalidSquare;
	NSTimeInterval animationDuration = animated ? 0.1 : 0.0;
	
	[UIView animateWithDuration:animationDuration animations:^{
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}];
}

@end
