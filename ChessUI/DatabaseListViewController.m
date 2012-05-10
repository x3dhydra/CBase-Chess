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

@interface DatabaseListViewController ()
@property (nonatomic, strong) NSArray *databaseURLs;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DatabaseListViewController
@synthesize databaseURLs = _databaseURLs;
@synthesize tableView = _tableView;

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
    
    self.databaseURLs = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)reloadData
{
    self.databaseURLs = nil;
    [self.tableView reloadData];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
    cell.textLabel.text = [[[url path] lastPathComponent] stringByDeletingPathExtension];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self.databaseURLs objectAtIndex:indexPath.row];
    DatabaseViewController *controller = [[DatabaseViewController alloc] initWithDatabase:[CKDatabase databaseWithContentsOfURL:url]];
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
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO) lastObject];
        
        NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"pathExtension IN %@", [self supportedExtensions]];
        NSArray *filteredContents = [allContents filteredArrayUsingPredicate:filter];
        
        NSMutableArray *databaseURLs = [[NSMutableArray alloc] initWithCapacity:filteredContents.count];
        [filteredContents enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            [databaseURLs addObject:[NSURL fileURLWithPath:path]];
        }];
        
        _databaseURLs = databaseURLs;
    }
    return _databaseURLs;
}

@end
