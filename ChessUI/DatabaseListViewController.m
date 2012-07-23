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

@interface DatabaseListViewController () <CKDatabaseMetadataViewControllerDelegate>
@property (nonatomic, strong) NSArray *databaseURLs;

@end

@implementation DatabaseListViewController
@synthesize databaseURLs = _databaseURLs;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.title = NSLocalizedString(@"CK_DATABASE_LIST_TITLE", @"Title for database list");
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)reloadData
{
    self.databaseURLs = nil;
    if ([self isViewLoaded])
        [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            self.databaseURLs = nil;
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (NSArray *)supportedExtensions
{
    return [NSArray arrayWithObjects:@"pgn", nil];
}

- (NSArray *)databaseURLs
{
    if (!_databaseURLs)
    {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"pathExtension IN %@", [self supportedExtensions]];
        NSArray *filteredContents = [allContents filteredArrayUsingPredicate:filter];
        
        NSMutableArray *databaseURLs = [[NSMutableArray alloc] initWithCapacity:filteredContents.count];
        [filteredContents enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
            [databaseURLs addObject:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:fileName]]];
        }];
        
        [databaseURLs sortUsingDescriptors:[self databaseSortDescriptors]];
        
        _databaseURLs = databaseURLs;
    }
    return _databaseURLs;
}

- (NSArray *)databaseSortDescriptors
{
    NSSortDescriptor *alphabetical = [[NSSortDescriptor alloc] initWithKey:@"lastPathComponent" ascending:YES];
    return [NSArray arrayWithObjects:alphabetical, nil];
}

#pragma mark - MetadataControllerDelegate

- (void)metadataViewController:(CKDatabaseMetadataViewController *)metadataViewController didMoveDatabaseAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL
{
    self.databaseURLs = nil;
    NSInteger index = [self.databaseURLs indexOfObject:destinationURL];
    [self.tableView reloadData];
    
    if (index != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end
