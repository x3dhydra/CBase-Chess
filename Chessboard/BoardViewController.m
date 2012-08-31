//
//  BoardViewController.m
//  CBase Chess
//
//  Created by Austen Green on 8/25/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "BoardViewController.h"
#import "CKBoardView.h"
#import "CKGameFormatter.h"
#import "CTLabel.h"
#import "UIAlertView+BlocksKit.h"
#import "CBUnruledPosition.h"

@interface BoardViewController () <CKBoardViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CKBoardView *boardView;
@property (nonatomic, strong) CKGame *game;
@property (nonatomic, strong) CKGameTree *gameTree;
@property (nonatomic, strong) CTLabel *gameTextLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CKMove *pendingMove;
@property (nonatomic, strong) NSString *pendingMoveText;

- (CKPosition *)position;
@end

@implementation BoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_game = [CKGame gameWithStartingPosition:[CBUnruledPosition standardPosition]];
		_gameTree = _game.gameTree;
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStyleBordered target:self action:@selector(flipBoard)];
    }
    return self;
}

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	CGFloat dimension = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
	CKBoardView *boardView = [[CKBoardView alloc] initWithFrame:CGRectMake(0, 0, dimension, dimension)];
	boardView.allowsSelection = YES;
	boardView.delegate = self;
	[self.view addSubview:boardView];
	self.boardView = boardView;
	
	CTLabel *label = [[CTLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    //[label setText:string];
    label.numberOfLines = 0;
    [label sizeToFit];
    self.gameTextLabel = label;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.boardView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.boardView.frame))];
    [self.view addSubview:scrollView];
    scrollView.contentSize = label.bounds.size;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [scrollView addSubview:label];
    self.scrollView = scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self.boardView setImage:[UIImage imageNamed:@"AlphaBBishop.tiff"] forPiece:BB];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaBKing.tiff"] forPiece:BK];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaBKnight.tiff"] forPiece:BN];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaBPawn.tiff"] forPiece:BP];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaBQueen.tiff"] forPiece:BQ];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaBRook.tiff"] forPiece:BR];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaWBishop.tiff"] forPiece:WB];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaWKing.tiff"] forPiece:WK];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaWKnight.tiff"] forPiece:WN];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaWPawn.tiff"] forPiece:WP];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaWQueen.tiff"] forPiece:WQ];
    [self.boardView setImage:[UIImage imageNamed:@"AlphaWRook.tiff"] forPiece:WR];
	
	[self.boardView setPosition:self.position];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CKPosition *)boardView:(CKBoardView *)boardView positionForMove:(CKMove *)move
{
	BOOL isLegal = [self.position isMoveLegal:move];
	if (isLegal)
	{
		NSString *moveString = [CKSANHelper stringFromMove:move withPosition:self.gameTree.position];
		
		if (self.gameTree.children.count)
		{
			self.pendingMove = move;
			self.pendingMoveText = moveString;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:moveString message:@"Input new move" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"New Variation", @"New Main Line", @"Replace", nil];
			[alert show];
			return nil;
		}
		else
		{
			if ([self.gameTree.position isMovePromotion:move])
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Promote" message:@"Select promotion piece" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:NSLocalizedString(@"Queen", @"queen"), NSLocalizedString(@"Rook", @"rook"), NSLocalizedString(@"Bishop", @"bishop"), NSLocalizedString(@"Knight", @"knight"), nil];
				[alert setDidDismissBlock:^(UIAlertView *alertView, NSInteger index) {
					if (index == alertView.cancelButtonIndex)
						return;
					
					switch (index - 1) {
						case 0:
							move.promotionPiece = QueenPiece;
							break;
						case 1:
							move.promotionPiece = RookPiece;
							break;
						case 2:
							move.promotionPiece = BishopPiece;
							break;
						case 3:
							move.promotionPiece = KnightPiece;
							break;
					}
					
					[self.gameTree addMove:move];
					self.gameTree = [[self.gameTree children] lastObject];
					self.gameTree.moveString = moveString;
					[self.boardView setPosition:self.gameTree.position withAnimation:CKBoardAnimationDelta];
					[self updateGameText];

				}];
				[alert show];
				
				return nil;
			}
			
			[self.gameTree addMove:move];
		}

		self.gameTree = [[self.gameTree children] lastObject];
		self.gameTree.moveString = moveString;
		
		[self updateGameText];
		
		return self.gameTree.position;
	}
	else
	{
		return nil;
	}
}

- (BOOL)boardView:(CKBoardView *)boardView canSelectSquare:(CCSquare)square
{
	CCColoredPiece piece = CCBoardGetPieceAtSquare(self.position.board, square);
	if (!CCPieceIsValid(piece) || CCColoredPieceGetColor(piece) != self.position.sideToMove)
		return NO;
	else
		return YES;
}

- (void)flipBoard
{
	[self.boardView setFlipped:!self.boardView.flipped animated:YES];
}

- (CKPosition *)position
{
	return self.gameTree.position;
}

- (void)updateGameText
{
	[self.gameTextLabel setText:[self gameText]];
	[self.gameTextLabel sizeToFitCurrentWidth];
	self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.gameTextLabel.bounds));
}

- (NSAttributedString *)gameText
{
	__weak BoardViewController *controller = self;
	
    CKGameFormatter *formatter = [[CKGameFormatter alloc] initWithGame:self.game];
    formatter.textSize = 36.0f;
    formatter.moveCallback = ^(CKGameTree *tree, NSMutableAttributedString *string)
    {
        [string setLink:^(CTLabel *button, NSRange range, CTLinkBlockSelectionType selectionType) {
            controller.gameTree = tree;
            [controller.boardView setPosition:tree.position withAnimation:CKBoardAnimationNone];
        }];
        [string addAttribute:kCTLabelLinkHighlightedForegroundColorKey value:(__bridge id)[[UIColor orangeColor] CGColor] range:NSMakeRange(0, string.length)];
    };
    
    NSAttributedString *string = [formatter attributedGameTree];
	return string;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		if (buttonIndex == alertView.firstOtherButtonIndex)
		{
			// New variation
			[self.gameTree addMove:self.pendingMove];
			self.gameTree = [self.gameTree.children lastObject];
			self.gameTree.moveString = self.pendingMoveText;
			[self.boardView setPosition:self.gameTree.position];
		}
		else if (buttonIndex == alertView.firstOtherButtonIndex + 1)
		{
			// New mainline - can't do for now
		}
		else if (buttonIndex == alertView.firstOtherButtonIndex + 2)
		{
			// Replace mainline
			CKGameTree *tree = [self.gameTree gameTreeWithMove:self.pendingMove];
			tree.moveString = self.pendingMoveText;
			[self.gameTree replaceChildAtIndex:0 withGameTree:tree];
			self.gameTree = tree;
			[self.boardView setPosition:self.gameTree.position];
		}
		
		self.pendingMoveText = nil;
		self.pendingMove = nil;
		[self updateGameText];
	}
}

@end
