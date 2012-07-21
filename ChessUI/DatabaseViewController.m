//
//  DatabaseViewController.m
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "DatabaseViewController.h"
#import "BoardViewController.h"
#import "CKGameCell.h"
#import "CKDatabaseSearchController.h"


@interface DatabaseViewController () <UIDocumentInteractionControllerDelegate, CKDatabaseSearchControllerDelegate>
{
    BOOL _isDisplayingShareMenu;
}
@property (nonatomic, strong) UIDocumentInteractionController *shareController;
@property (nonatomic, strong) CKDatabaseSearchController *databaseSearchController;

@end

@implementation DatabaseViewController
@synthesize database = _database;
@synthesize shareController = _shareController;
@synthesize databaseSearchController = _databaseSearchController;

- (id)initWithDatabase:(CKDatabase *)database
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _database = database;
        _shareController = [[UIDocumentInteractionController alloc] init];
        _shareController.URL = database.url;
        _shareController.delegate = self;
        
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareDatabase:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:share, nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.tableView.rowHeight = 76.0f;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.0f)];
    [searchBar sizeToFit];
        
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _databaseSearchController = [[CKDatabaseSearchController alloc] initWithDatabase:self.database searchDisplayController:searchDisplayController];
    _databaseSearchController.delegate = self;
    
    self.tableView.tableHeaderView = searchBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.database.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CKGameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CKGameCell alloc] initWithReuseIdentifier:CellIdentifier];
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *metadata = [self.database metadataAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [metadata objectForKey:CKGameWhitePlayerKey], [metadata objectForKey:CKGameBlackPlayerKey]];
    cell.detailTextLabel.text = [metadata objectForKey:CKGameEventKey];
    cell.resultLabel.text = [metadata objectForKey:CKGameResultKey];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Date", @"Event date (table view cell)"), [metadata objectForKey:CKGameDateKey]];
    cell.alternateSubtitleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Round", @"Round (table view cell)"), [metadata objectForKey:CKGameRoundKey]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self displayGameAtIndex:indexPath.row];
}

#pragma mark - sharing

- (void)shareDatabase:(UIBarButtonItem *)item
{
    if (!_isDisplayingShareMenu)
        _isDisplayingShareMenu = [self.shareController presentOpenInMenuFromBarButtonItem:item animated:YES];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
   _isDisplayingShareMenu = NO;    
}

#pragma mark - 

- (void)displayGameAtIndex:(NSUInteger)index
{
    CKGame *game = [self.database gameAtIndex:index];
    BoardViewController *viewController = [[BoardViewController alloc] initWithGame:game];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)databaseSearchController:(CKDatabaseSearchController *)searchController didSelectGameAtIndex:(NSUInteger)index;
{
    [self displayGameAtIndex:index];
}


@end
