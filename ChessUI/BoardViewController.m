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
#import "CKGameMetadataViewController.h"
#import "CBaseConstants.h"
#import "CKAccessibility.h"

@interface BoardViewController () <UIPopoverControllerDelegate>
{
    BOOL reverse;
}

@property (nonatomic, strong) CKBoardView *boardView;
@property (nonatomic, strong) CKGameTree *gameTree;
@property (nonatomic, strong) CKGameTree *currentNode;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CTLabel *gameTextLabel;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) BOOL shouldDisplayVariationsDialog;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@property (nonatomic, strong) UIBarButtonItem *previousBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *nextBarButtonItem;

@end

@implementation BoardViewController
@synthesize boardView = _boardView;
@synthesize gameTree = _gameTree;
@synthesize currentNode = _currentNode;
@synthesize game = _game;
@synthesize scrollView = _scrollView;
@synthesize gameTextLabel = _gameTextLabel;
@synthesize popoverController = _presentedPopoverController;
@synthesize actionSheet = _actionSheet;
@synthesize shouldDisplayVariationsDialog = _shouldDisplayVariationsDialog;

@synthesize previousBarButtonItem = _previousBarButtonItem;
@synthesize nextBarButtonItem = _nextBarButtonItem;

- (id)initWithGame:(CKGame *)game
{
    self = [super init];
    if (self)
    {
        _currentNode = game.gameTree;
        _game = game;
        
        NSString *white = [game.metadata objectForKey:CKGameWhitePlayerKey];
        NSString *black = [game.metadata objectForKey:CKGameBlackPlayerKey];
        
        if (white.length && black.length)
            self.title = [NSString stringWithFormat:@"%@ - %@", white, black];
        else if (white.length)
            self.title = white;
        else if (black.length)
            self.title = black;
        else
            self.title = NSLocalizedString(@"CK_GAME_VIEW_NO_PLAYER_TITLE", @"Title for Board View Controller when neither side has a player name");
            
            
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVariationsPreference) name:CKDisplayVariationsPreferenceDidChangeNotification object:nil];
        [self updateVariationsPreference];
        [self updateToolbar];        
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
            [controller updateToolbarButtons];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverController dismissPopoverAnimated:animated];
    self.popoverController = nil;
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
        if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight)
        {
            [self showNextMove];            
        }
        else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)
        {
            [self showPreviousMove];
        }
    }
}

- (void)showPreviousMove
{
    if ([self canShowPreviousMove])
    {
        if (self.actionSheet)
        {
            [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet cancelButtonIndex] animated:YES];
        }
        
        self.currentNode = self.currentNode.parent;
        [self.boardView setPosition:self.currentNode.position withAnimation:CKBoardAnimationDelta];
        [self updateToolbarButtons];
    }
}

- (void)showNextMove
{
    if ([self canShowNextMove])
    {
        if (self.currentNode.children.count == 1 || !self.shouldDisplayVariationsDialog)
        {
            [self showNextMoveWithTree:self.currentNode.nextTree];            
        }
        else 
        {
            [self showVariationsDialog];
        }
    }
}

- (void)showNextMoveWithTree:(CKGameTree *)tree
{
    self.currentNode = tree;
    [self.boardView setPosition:self.currentNode.position withAnimation:CKBoardAnimationDelta];
    
    NSString *move = CKAccessibilityNameForGameTree(self.currentNode);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, move);
    
    [self updateToolbarButtons];
}

- (void)showVariationsDialog
{
    if (self.actionSheet)
    {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
        [self showNextMoveWithTree:self.currentNode.nextTree];
        return;
    }
    
    BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    NSString *cancelButtonTitle = isIpad ? nil : NSLocalizedString(@"Cancel", nil);
    //NSString *cancelButtonTitle =  NSLocalizedString(@"Cancel", nil);
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Variation", nil) delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles: nil];
    self.actionSheet = sheet;
    NSArray *titles = [self.currentNode.children valueForKeyPath:@"moveString"];
    
    for (NSString *title in titles)
        [sheet addButtonWithTitle:title];
    
    if (isIpad)
        [sheet showFromBarButtonItem:self.nextBarButtonItem animated:YES];
    else
        [sheet showInView:self.view];
}

- (BOOL)canShowPreviousMove
{
    return self.currentNode.parent != nil;
}

- (BOOL)canShowNextMove
{
    return self.currentNode.children.count > 0;
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
        NSInteger index = buttonIndex;
        if ([actionSheet cancelButtonIndex] != -1)
            index += 1;
        CKGameTree *tree = [self.currentNode.children objectAtIndex:index];
        [self showNextMoveWithTree:tree];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.actionSheet = nil;
}

#pragma mark - Details

- (void)showGameDetails
{
    CKGameMetadataViewController *controller = [[CKGameMetadataViewController alloc] initWithGame:self.game];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Toolbar

- (void)updateToolbar
{
    UIButtonType type = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? UIButtonTypeInfoLight : UIButtonTypeInfoDark;
    UIButton *button = [UIButton buttonWithType:type];
    [button addTarget:self action:@selector(showGameDetails) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithCustomView:button];
    info.accessibilityLabel = NSLocalizedString(@"CK_BOARD_INFO_BUTTON_ACCESSIBILITY_TITLE", @"Accessibilty title for game info button on board");
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.previousBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIButtonBarArrowLeft"] landscapeImagePhone:[UIImage imageNamed:@"UIButtonBarArrowLeftLandscape"] style:UIBarButtonItemStylePlain target:self action:@selector(showPreviousMove)];
    self.previousBarButtonItem.accessibilityLabel = NSLocalizedString(@"CK_BOARD_PREVIOUS_BUTTON_ACCESSIBILITY_TITLE", @"Accessibilty title for previous move button on board");
    
    self.nextBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIButtonBarArrowRight"] landscapeImagePhone:[UIImage imageNamed:@"UIButtonBarArrowRightLandscape"] style:UIBarButtonItemStylePlain target:self action:@selector(showNextMove)];
    self.nextBarButtonItem.accessibilityLabel = NSLocalizedString(@"CK_BOARD_NEXT_BUTTON_ACCESSIBILITY_TITLE", @"Accessibilty title for previous move button on board");
    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    settings.accessibilityLabel = NSLocalizedString(@"CK_BOARD_SETTINGS_ACCESSIBILITY_TITLE", @"Accessibility title for game settings toolbar item");
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, info, flexibleSpace, settings, flexibleSpace, self.previousBarButtonItem, flexibleSpace, self.nextBarButtonItem, flexibleSpace, nil];
    
    [self updateToolbarButtons];
}

- (void)updateToolbarButtons
{
    self.previousBarButtonItem.enabled = [self canShowPreviousMove];
    self.nextBarButtonItem.enabled = [self canShowNextMove];
}

- (void)showSettings:(UIBarButtonItem *)item
{
    if (self.popoverController)
    {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
    UIViewController *settings = [storyboard instantiateViewControllerWithIdentifier:@"GameSettings"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:settings animated:YES completion:nil];
    }
    else 
    {        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:settings];
        [popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popoverController = popover;
    }
}

- (void)updateVariationsPreference
{
    self.shouldDisplayVariationsDialog = [[NSUserDefaults standardUserDefaults] boolForKey:CKDisplayVariationsDialogKey];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController = nil;
    return YES;
}

@end
