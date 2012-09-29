//
//  CKGameMetadataViewController.m
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameMetadataViewController.h"
#import "CKKeyValueCell.h"

@interface CKGameMetadataViewController ()
@property (nonatomic, strong) NSArray *sections;

@end

@implementation CKGameMetadataViewController
@synthesize game = _game;
@synthesize sections = _sections;

- (id)initWithGame:(CKGame *)game
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _game = game;
        self.title = NSLocalizedString(@"CK_GAME_METADATA_TITLE", @"Title for game metadata screen");
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CKKeyValueCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    NSString *key = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.game localizedAttributeForKey:key];
    cell.detailTextLabel.text = [self titleForRowAtIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        NSString *title = [self titleForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:title];
    }
}

#pragma mark - Section Data

- (NSArray *)sections
{
    if (!_sections)
    {
        _sections = [self generateSections];
    }
    return _sections;
}

- (NSArray *)generateSections
{
    NSMutableArray *sections = [NSMutableArray array];
    
    NSMutableIndexSet *masks = [NSMutableIndexSet indexSet];
    [masks addIndex:CKGamePlayerAttributes];
    [masks addIndex:CKGameEventAttributes];
    [masks addIndex:CKGameAttributes];
    
    [masks enumerateIndexesUsingBlock:^(CKGameAttributeMask mask, BOOL *stop) {
        NSMutableArray *validKeys = [NSMutableArray array];
        
        [[CKGame attributesForMask:mask] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([self.game.metadata objectForKey:key])
                [validKeys addObject:key];
        }];
        
        if (validKeys.count)
            [sections addObject:validKeys];
    }];
    
    return sections;
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [self.game.metadata objectForKey:key];
}

@end
