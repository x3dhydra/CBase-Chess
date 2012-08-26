//
//  BoardViewController.m
//  CBase Chess
//
//  Created by Austen Green on 8/25/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "BoardViewController.h"
#import "CKBoardView.h"

@interface BoardViewController () <CKBoardViewDelegate>
@property (nonatomic, strong) CKBoardView *boardView;
@property (nonatomic, strong) CKPosition *position;
@end

@implementation BoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_position = [CKPosition standardPosition];
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
	self.boardView.flipped = YES;
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
		CKPosition *position = [self.position positionByMakingMove:move];
		self.position = position;
		return position;
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

@end