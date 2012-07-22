//
//  CKDatabaseMetadataViewController.m
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKDatabaseMetadataViewController.h"
#import "CKKeyValueCell.h"

static NSString * const CKDatabaseTitleKey = @"CKDatabaseTitleKey";

@interface CKDatabaseMetadataViewController ()
{
    BOOL _shouldCommitOnEndEditing;
}
@property (nonatomic, strong) NSMutableDictionary *fileAttributes;
@property (nonatomic, strong) NSArray *keys;

@end

@implementation CKDatabaseMetadataViewController
@synthesize databaseURL = _databaseURL;
@synthesize fileAttributes = _fileAttributes;
@synthesize keys = _keys;
@synthesize delegate = _delegate;

- (id)initWithURL:(NSURL *)databaseURL
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _databaseURL = databaseURL;
        [self loadFileAttributes];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    NSString *title = [[self.databaseURL lastPathComponent] stringByDeletingPathExtension];
    if (title)
    {
        [self.fileAttributes setObject:title forKey:CKDatabaseTitleKey];
        [releventAttributeKeys insertObject:CKDatabaseTitleKey atIndex:0];
        self.title = title;
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
        cell = [[CKKeyValueCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    
    NSInteger index = indexPath.row;
    NSString *key = [self.keys objectAtIndex:index];
    cell.textLabel.text = NSLocalizedString(key, nil);
    cell.detailTextLabel.text = [self formattedValueForKey:key];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    return index == [self.keys indexOfObject:CKDatabaseTitleKey];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing && [tableView.dataSource tableView:tableView canEditRowAtIndexPath:indexPath])
    {
        [self setEditing:YES animated:YES];
    }
}


#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)];
        _shouldCommitOnEndEditing = YES;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
        if (_shouldCommitOnEndEditing)
            [self commitEdits];
    }
}

- (void)cancelEditing
{
    _shouldCommitOnEndEditing = NO;
    [self setEditing:NO animated:YES];
}

- (void)commitEdits
{
    NSInteger titleIndex = [self.keys indexOfObject:CKDatabaseTitleKey];
    CKKeyValueCell *nameCell = (CKKeyValueCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:titleIndex inSection:0]];
    
    NSString *editedName = nameCell.textField.text;
    if (![editedName isEqualToString:[self.fileAttributes objectForKey:CKDatabaseTitleKey]])
    {
        [self setDatabaseName:editedName];
    }
}

- (void)setDatabaseName:(NSString *)updatedName
{
    NSURL *oldPath = [self.databaseURL URLByDeletingLastPathComponent];
    
    NSURL *source = self.databaseURL;
    NSURL *destination= [[oldPath URLByAppendingPathComponent:updatedName] URLByAppendingPathExtension:source.pathExtension];
    NSError *error;
    
    
    if (![[NSFileManager defaultManager] moveItemAtURL:source toURL:destination error:&error])
    {
        NSString *title;
        NSString *message;
        
        if (!updatedName.length)
        {
            title = NSLocalizedString(@"CK_INVALID_DATABASE_NAME_TITLE", @"Title for invalid name when renaming database");
            message = NSLocalizedString(@"CK_INVALID_DATABASE_NAME_MESSAGE", @"Message for invalid name when renaming database");
        }
        else 
        {
            title = NSLocalizedString(@"CK_DATABASE_RENAMING_ERROR_TITLE", @"Title for generic error when renaming database");
            message = NSLocalizedString(@"CK_DATABASE_RENAMING_ERROR_MESSAGE", @"Message for generic error when renaming database");
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"CK_ERROR_ALERT_GENERIC_CANCEL_BUTTON_TITLE", @"Generic title for error alerts which only have on option") otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
        _databaseURL = destination;
        [self loadFileAttributes];
        [self.tableView reloadData];
        if ([self.delegate respondsToSelector:@selector(metadataViewController:didMoveDatabaseAtURL:toURL:)])
            [self.delegate metadataViewController:self didMoveDatabaseAtURL:source toURL:destination];
    }
}

#pragma mark - Formatting

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
