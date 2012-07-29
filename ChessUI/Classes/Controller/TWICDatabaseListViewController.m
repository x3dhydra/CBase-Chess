//
//  TWICDatabaseListViewController.m
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "TWICDatabaseListViewController.h"
#import "TWICDatabaseListScraper.h"

@interface TWICDatabaseListViewController ()
{
    struct
    {
        unsigned int needsListFetch : 1;
        unsigned int loading : 1;
    } _databaseListFlags;
}
@property (nonatomic, strong) TWICDatabaseListScraper *listScraper;

@end

@implementation TWICDatabaseListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        _listScraper = [[TWICDatabaseListScraper alloc] init];
        _databaseListFlags.needsListFetch = YES;
        self.title = NSLocalizedString(@"TWIC_LIST_TITLE", @"Title for The Week In Chess list view");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchDatabaseListIfNeeded];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_databaseListFlags.loading)
        return 1;
    else
        return self.listScraper.databaseURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_databaseListFlags.loading)
    {
        static NSString *CellIdentifier = @"LoadingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activity startAnimating];
            cell.accessoryView = activity;
        }
        
        cell.textLabel.text = NSLocalizedString(@"TWIC_LOADING_CELL_TITLE", @"Title for loading cell in TWIC dataase list");
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self configureCell:cell forRowAtIndexPath:indexPath];
        
        return cell;

    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_databaseListFlags.loading || !self.listScraper.databaseURLs.count)
        return nil;
    else
        return indexPath;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *databaseURL = [self.listScraper.databaseURLs objectAtIndex:indexPath.row];
    cell.textLabel.text = [self titleForDatabaseURL:databaseURL];
}

- (NSString *)titleForDatabaseURL:(NSURL *)databaseURL
{
    NSString *zipName = databaseURL.lastPathComponent;
    NSScanner *scanner = [NSScanner scannerWithString:zipName];
    scanner.charactersToBeSkipped = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *index;
    [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&index];
    
    NSString *title = [NSString stringWithFormat:@"TWIC %@", index];
    return title;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Fetching


- (void)fetchDatabaseListIfNeeded
{
    if (!_databaseListFlags.needsListFetch)
        return;
    
    __weak TWICDatabaseListViewController *weakSelf = self;
    _databaseListFlags.loading = YES;
    
    [self.listScraper fetchDatabaseListWithCompletion:^(BOOL success, NSError *error) {
        if (weakSelf)
        {
            TWICDatabaseListViewController *controller = weakSelf;
            controller->_databaseListFlags.loading = NO;
            [controller.tableView reloadData];
        }
    }];
}

@end
