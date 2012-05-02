//
//  BoardViewController.m
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "BoardViewController.h"
#import "CKBoardView.h"
#import "ChessKit.h"

@interface BoardViewController ()
{
    BOOL reverse;
}

@property (nonatomic, strong) CKBoardView *boardView;
@property (nonatomic, strong) CKGameTree *gameTree;
@property (nonatomic, strong) CKGameTree *currentNode;

@end

@implementation BoardViewController
@synthesize boardView = _boardView;
@synthesize gameTree = _gameTree;
@synthesize currentNode = _currentNode;
@synthesize game = _game;

- (id)initWithGame:(CKGame *)game
{
    self = [super init];
    if (self)
    {
        _currentNode = game.gameTree;
        _game = game;
    }
    return self;
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _gameTree = [[CKGameTree alloc] initWithPosition:[CKPosition standardPosition]];
        
        CKGameTree *node = _gameTree;
        
        [node addMove:[CKMove moveWithFrom:h2 to:h4]];
        node = [node nextTree];
        
        [node addMove:[CKMove moveWithFrom:c7 to:c5]];
        node = [node nextTree];
        
        [node addMove:[CKMove moveWithFrom:h4 to:h5]];
        node = [node nextTree];

        [node addMove:[CKMove moveWithFrom:c5 to:c4]];
        node = [node nextTree];

        [node addMove:[CKMove moveWithFrom:h5 to:h6]];
        node = [node nextTree];
        
        [node addMove:[CKMove moveWithFrom:a7 to:a5]];
        node = [node nextTree];
        
        [node addMove:[CKMove moveWithFrom:h6 to:g7]];
        node = [node nextTree];

        [node addMove:[CKMove moveWithFrom:a5 to:a4]];
        node = [node nextTree];

        CKMove *move = [CKMove moveWithFrom:g7 to:h8];
        move.promotionPiece = QueenPiece;
        [node addMove:move];

        
//        [node addMove:[CKMove moveWithFrom:c7 to:c5]];
//        node = [node nextTree];
//        
//        [node addMove:[CKMove moveWithFrom:d2 to:d4]];
//        node = [node nextTree];
//        
//        [node addMove:[CKMove moveWithFrom:c5 to:d4]];
//        node = [node nextTree];
        
//        [node addMove:[CKMove moveWithFrom:g1 to:f3]];
//        node = [node nextTree];
//        
//        [node addMove:[CKMove moveWithFrom:b8 to:c6]];
//        node = [node nextTree];
//        
//        [node addMove:[CKMove moveWithFrom:f1 to:b5]];
//        node = [node nextTree];
//        
//        [node addMove:[CKMove moveWithFrom:g8 to:f6]];
//        node = [node nextTree];
//        
//        [node addMove:[CKMove moveWithFrom:e1 to:g1]];
//        node = [node nextTree];
        
        
        _currentNode = _gameTree;
        
    }
    return self;
}
 */

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] bounds]];
    CKBoardView *boardView = [[CKBoardView alloc] initWithFrame:self.view.bounds];
    [boardView sizeToFit];
    [self.view addSubview:boardView];
    self.boardView = boardView;
        
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.boardView addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.boardView addGestureRecognizer:right];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStyleBordered target:self action:@selector(flipBoard)];
}

- (void)swipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight && self.currentNode.children.count)
        {
            if (self.currentNode.children.count == 1)
            {
                self.currentNode = self.currentNode.nextTree;
                [self.boardView setPosition:self.currentNode.position withAnimation:CKBoardAnimationDelta];
            }
            else {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Variation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles: nil];
                NSArray *titles = [self.currentNode.children valueForKeyPath:@"moveString"];
                
                for (NSString *title in titles)
                    [sheet addButtonWithTitle:title];
                
                [sheet showInView:self.view];
            }
            
        }
        else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft && self.currentNode.parent)
        {
            self.currentNode = self.currentNode.parent;
            [self.boardView setPosition:self.currentNode.position withAnimation:CKBoardAnimationDelta];
        }
    }
}

- (void)flipBoard
{    
    [self.boardView setFlipped:!self.boardView.isFlipped animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
	// Do any additional setup after loading the view.
    [self.boardView setPosition:self.game.gameTree.position];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        NSInteger index = buttonIndex + [actionSheet firstOtherButtonIndex];
        self.currentNode = [self.currentNode.children objectAtIndex:index];
        [self.boardView setPosition:self.currentNode.position withAnimation:CKBoardAnimationDelta];
    }
}

@end
