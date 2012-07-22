//
//  CKDatabaseMetadataViewController.m
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKDatabaseMetadataViewController.h"

static NSString * const CKDatabaseTitleKey = @"CKDatabaseTitleKey";

@interface CKDatabaseMetadataViewController ()
@property (nonatomic, strong) NSMutableDictionary *fileAttributes;
@property (nonatomic, strong) NSArray *keys;

@end

@implementation CKDatabaseMetadataViewController
@synthesize databaseURL = _databaseURL;
@synthesize fileAttributes = _fileAttributes;
@synthesize keys = _keys;

- (id)initWithURL:(NSURL *)databaseURL
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _databaseURL = databaseURL;
        self.title = _databaseURL.lastPathComponent;
    }
    return self;
}

- (void)viewDidLoad
{
    [self loadFileAttributes];

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)loadFileAttributes
{
    NSError *error = nil;
    NSDictionary *allAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.databaseURL.path error:&error];
    
    NSMutableArray *releventAttributeKeys = [NSMutableArray arrayWithObjects:NSFileSize, NSFileCreationDate, NSFileModificationDate, nil];
    NSArray *releventAttributes = [allAttributes objectsForKeys:releventAttributeKeys notFoundMarker:[NSNull null]];
    
    self.fileAttributes = [NSMutableDictionary dictionaryWithObjects:releventAttributes forKeys:releventAttributeKeys];
    
    NSString *title = [self.databaseURL lastPathComponent];
    if (title)
    {
        [self.fileAttributes setObject:title forKey:CKDatabaseTitleKey];
        [releventAttributeKeys insertObject:CKDatabaseTitleKey atIndex:0];
    }
    
    self.keys = releventAttributeKeys;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileAttributes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    
    NSInteger index = indexPath.row;
    NSString *key = [self.keys objectAtIndex:index];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [self formattedValueForKey:key];
    
    return cell;
}

- (NSString *)formattedValueForKey:(NSString *)key
{
    id value = [self.fileAttributes objectForKey:key];
    NSString *formattedValue = nil;
    
    if ([value isKindOfClass:[NSNumber class]])
    {
        formattedValue = [NSString stringWithFormat:@"%@ bytes", [NSNumberFormatter localizedStringFromNumber:value numberStyle:NSNumberFormatterDecimalStyle]];
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        formattedValue = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        formattedValue = value;
    }
    
    return formattedValue;
}

@end
