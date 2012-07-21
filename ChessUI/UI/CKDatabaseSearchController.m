//
//  CKDatabaseSearchController.m
//  ChessUI
//
//  Created by Austen Green on 7/14/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKDatabaseSearchController.h"
#import "CKGameCell.h"
#import "CKGame.h"

@interface CKDatabaseSearchController()
@property (nonatomic, strong) NSArray *gameIndexes;
@end

@implementation CKDatabaseSearchController
@synthesize database = _database;
@synthesize searchDisplayController = _searchDisplayController;
@synthesize gameIndexes = _gameIndexes;
@synthesize delegate;

- (id)initWithDatabase:(CKDatabase *)database searchDisplayController:(UISearchDisplayController *)searchDisplayController
{
    self = [super init];
    if (self)
    {
        _database = database;
        _searchDisplayController = searchDisplayController;
        _searchDisplayController.delegate = self;
        _searchDisplayController.searchResultsDelegate = self;
        _searchDisplayController.searchResultsDataSource = self;
    }
    return self;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 76.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gameIndexes.count;
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
    
    NSUInteger index = [self indexForIndexPath:indexPath];
    
    NSDictionary *metadata = [self.database metadataAtIndex:index];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [metadata objectForKey:CKGameWhitePlayerKey], [metadata objectForKey:CKGameBlackPlayerKey]];
    cell.detailTextLabel.text = [metadata objectForKey:CKGameEventKey];
    cell.resultLabel.text = [metadata objectForKey:CKGameResultKey];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Date", @"Event date (table view cell)"), [metadata objectForKey:CKGameDateKey]];
    cell.alternateSubtitleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Round", @"Round (table view cell)"), [metadata objectForKey:CKGameRoundKey]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *predicate = [self searchPredicate];
    self.gameIndexes = [self.database filteredGamesUsingPredicate:predicate];
    [controller.searchResultsTableView reloadData];

    return YES;
}

- (NSUInteger)indexForIndexPath:(NSIndexPath *)indexPath
{
    return [[self.gameIndexes objectAtIndex:indexPath.row] unsignedIntegerValue];
}

- (NSPredicate *)searchPredicate
{
    NSString *searchQuery = self.searchDisplayController.searchBar.text;
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        NSString *name = [evaluatedObject objectForKey:CKGameWhitePlayerKey];
        NSRange range = [name rangeOfString:searchQuery options:NSAnchoredSearch | NSCaseInsensitiveSearch];
        return range.location != NSNotFound;
    }];
    
    return predicate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate databaseSearchController:self didSelectGameAtIndex:[self indexForIndexPath:indexPath]];
}

@end