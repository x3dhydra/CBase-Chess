//
//  DatabaseListViewController.m
//  ChessUI
//
//  Created by Austen Green on 5/9/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "DatabaseListViewController.h"
#import "DatabaseViewController.h"
#import "ChessKit.h"
#import "CKDatabaseMetadataViewController.h"
#import "CKDatabaseListProvider.h"
#import "TWICDatabaseListScraper.h"
#import "TWICDatabaseDownloader.h"

@interface DatabaseListViewController () <CKDatabaseMetadataViewControllerDelegate, TWICDatabaseDownloadDelegate>
@property (nonatomic, strong) NSArray *databaseURLs;
@property (nonatomic, strong) CKDatabaseListProvider *listProvider;
@property (nonatomic, strong) UIView *noGamesView;
@property (nonatomic, strong) TWICDatabaseListScraper *listScraper;
@property (nonatomic, strong) TWICDatabaseDownloader *downloader;

@end

@implementation DatabaseListViewController
@synthesize databaseURLs = _databaseURLs;
@synthesize listProvider = _listProvider;
@synthesize noGamesView = _noGamesView;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.title = NSLocalizedString(@"CK_DATABASE_LIST_TITLE", @"Title for database list");
        self.hidesBottomBarWhenPushed = YES;
//        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        self.listProvider = [[CKDatabaseListProvider alloc] initWithRootDirectory:path];
//        self.listScraper = [[TWICDatabaseListScraper alloc] init];
//        [self.listScraper fetchDatabaseListWithCompletion:^(BOOL success, NSError *error) {
//            NSLog(@"Complete: %@", error);
//            NSURL *URL = [self.listScraper.databaseURLs objectAtIndex:0];
//            self.downloader = [[TWICDatabaseDownloader alloc] initWithURL:URL];
//            self.downloader.destinationPath = path;
//            self.downloader.delegate = self;
//            [self.downloader beginDownload];
//        }];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)reloadData
{
    [self.listProvider reloadData];
    if ([self isViewLoaded])
    {
        [self.tableView reloadData];
        [self displayNoGamesViewIfNeeded];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self displayNoGamesViewIfNeeded];
}

- (void)displayNoGamesViewIfNeeded
{
    NSInteger count = self.databaseURLs.count;
    if (!count)
    {
        self.noGamesView.frame = self.view.bounds;
        self.tableView.tableHeaderView = self.noGamesView;
        self.tableView.scrollEnabled = NO;
    }
    else
    {
        self.tableView.scrollEnabled = YES;
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.databaseURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
    cell.textLabel.text = [[[url path] lastPathComponent] stringByDeletingPathExtension];
    cell.accessoryView = nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = activity;
    [activity startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CKDatabase *database = [CKDatabase databaseWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            DatabaseViewController *controller = [[DatabaseViewController alloc] initWithDatabase:database];
            [self.navigationController pushViewController:controller animated:YES];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    });
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
        
        if ([[NSFileManager defaultManager] removeItemAtURL:url error:NULL])
        {
            [self.listProvider reloadData];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self displayNoGamesViewIfNeeded];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
    return [[NSFileManager defaultManager] isDeletableFileAtPath:url.path];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
    
    CKDatabaseMetadataViewController *controller = [[CKDatabaseMetadataViewController alloc] initWithURL:url];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Data

- (NSArray *)databaseURLs
{
    return self.listProvider.databaseURLs;
}

#pragma mark - MetadataControllerDelegate

- (void)metadataViewController:(CKDatabaseMetadataViewController *)metadataViewController didMoveDatabaseAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL
{
    [self.listProvider reloadData];
    NSInteger index = [self.databaseURLs indexOfObject:destinationURL];
    [self.tableView reloadData];
    
    if (index != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - 

- (UIView *)noGamesView
{
    if (!_noGamesView)
    {
        _noGamesView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Semi-Transparent-Board"]];
        _noGamesView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        _noGamesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _noGamesView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:_noGamesView.bounds];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.text = NSLocalizedString(@"No Databases\nYou currently don't have any databases.  Download .pgn files from Safari or copy databases in via iTunes.", @"No databases title");
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.numberOfLines = 0;
        [_noGamesView addSubview:textLabel];
    }
    return _noGamesView;
}

#pragma mark - TWICDatabaseDownloadDelegate

- (void)databaseDownloader:(TWICDatabaseDownloader *)downloader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error title") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert show];
}

- (void)databaseDownloaderDidFinish:(TWICDatabaseDownloader *)downloader
{
    [self reloadData];
}

@end
