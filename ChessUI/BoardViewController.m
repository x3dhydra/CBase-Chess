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
#import "CKGameFormatter.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "CTLabel.h"

@interface BoardViewController ()
{
    BOOL reverse;
}

@property (nonatomic, strong) CKBoardView *boardView;
@property (nonatomic, strong) CKGameTree *gameTree;
@property (nonatomic, strong) CKGameTree *currentNode;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CTLabel *gameTextLabel;

@end

@implementation BoardViewController
@synthesize boardView = _boardView;
@synthesize gameTree = _gameTree;
@synthesize currentNode = _currentNode;
@synthesize game = _game;
@synthesize scrollView = _scrollView;
@synthesize gameTextLabel = _gameTextLabel;

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
    
    __weak BoardViewController *controller = self;
    
    // Add attributed string scroll view
    CKGameFormatter *formatter = [[CKGameFormatter alloc] initWithGame:_game];
    formatter.textSize = 18.0f;
    formatter.moveCallback = ^(CKGameTree *tree, NSMutableAttributedString *string)
    {
        [string setLink:^(CTLabel *button, NSRange range, CTLinkBlockSelectionType selectionType) {
            controller.currentNode = tree;
            [controller.boardView setPosition:tree.position withAnimation:CKBoardAnimationNone];
        }];
        [string addAttribute:kCTLabelLinkHighlightedForegroundColorKey value:(__bridge id)[[UIColor orangeColor] CGColor] range:NSMakeRange(0, string.length)];
    };
    
    NSAttributedString *string = [formatter attributedGameTree];
    
    CTLabel *label = [[CTLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    //[label setText:string];
    //[label setAttributedText:string];
    [label setText:string];
    label.numberOfLines = 0;
    [label sizeToFit];
    self.gameTextLabel = label;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.contentSize = label.bounds.size;
    [scrollView addSubview:label];
    self.scrollView = scrollView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.boardView.frame = CGRectMake(0.0f, 0.0f, width, width);
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        CGRect frame = CGRectMake(0.0f, CGRectGetMaxY(self.boardView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.boardView.frame));
        self.scrollView.frame = frame;
    }
    else 
    {
        CGRect frame = CGRectMake(CGRectGetMaxX(self.boardView.frame), 0.0f, CGRectGetWidth(self.view.bounds) - CGRectGetMaxX(self.boardView.frame), CGRectGetHeight(self.view.bounds));
        self.scrollView.frame = frame;
    }
    
    self.gameTextLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.view.bounds));
    [self.gameTextLabel sizeToFitCurrentWidth];
    self.scrollView.contentSize = self.gameTextLabel.bounds.size;
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

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
