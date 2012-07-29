//
//  TWICDatabaseListViewController.m
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "TWICDatabaseListViewController.h"
#import "TWICDatabaseListScraper.h"
#import "TWICDatabaseDownloader.h"
#import "CBaseNotifications.h"

@interface TWICDatabaseListViewController () <TWICDatabaseDownloadDelegate>
{
    struct
    {
        unsigned int needsListFetch : 1;
        unsigned int loading : 1;
    } _databaseListFlags;
    NSUInteger _downloadingIndex;
}
@property (nonatomic, strong) TWICDatabaseListScraper *listScraper;
@property (nonatomic, strong) TWICDatabaseDownloader *downloader;

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
        _downloadingIndex = NSNotFound;
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
    if (_databaseListFlags.loading || !self.listScraper.databaseURLs.count || self.downloader)
        return nil;
    else
        return indexPath;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *databaseURL = [self.listScraper.databaseURLs objectAtIndex:indexPath.row];
    cell.textLabel.text = [self titleForDatabaseURL:databaseURL];
    
    if (_downloadingIndex == indexPath.row)
    {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity startAnimating];
        cell.accessoryView = activity;
    }
    else
        cell.accessoryView = nil;
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *URL = [self.listScraper.databaseURLs objectAtIndex:indexPath.row];
    _downloadingIndex = indexPath.row;
    [self beginDownloadForURL:URL];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark Downloading

- (void)beginDownloadForURL:(NSURL *)URL
{
    TWICDatabaseDownloader *downloader = [[TWICDatabaseDownloader alloc] initWithURL:URL];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    downloader.destinationPath = path;
    downloader.delegate = self;
    self.downloader = downloader;
    [downloader beginDownload];
}

- (void)cleanupDownload
{
    self.downloader.delegate = nil;
    self.downloader = nil;
    
    if (_downloadingIndex < [self.tableView numberOfRowsInSection:0])
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_downloadingIndex inSection:0];
        _downloadingIndex = NSNotFound;
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - TWICDatabaseDownloadDelegate

- (void)databaseDownloader:(TWICDatabaseDownloader *)downloader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error title") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert show];
    [self cleanupDownload];
}

- (void)databaseDownloaderDidFinish:(TWICDatabaseDownloader *)downloader
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CBaseDidAddDatabaseNotification object:nil];
    [self cleanupDownload];
}

@end
