//
//  CKDatabaseListProvider.m
//  CBase Chess
//
//  Created by Austen Green on 7/23/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKDatabaseListProvider.h"

@implementation CKDatabaseListProvider
@synthesize rootDirectory = _rootDirectory;
@synthesize databaseURLs = _databaseURLs;

- (id)initWithRootDirectory:(NSString *)rootDirectory
{
    self = [super init];
    if (self)
    {
        _rootDirectory = [rootDirectory copy];
    }
    return self;
}

- (void)reloadData
{
    _databaseURLs = nil;
}

- (NSArray *)databaseURLs
{
    if (!_databaseURLs)
    {            
        NSArray *allContents = [[[NSFileManager defaultManager] subpathsAtPath:self.rootDirectory] arrayByAddingObject:self.rootDirectory];
        NSMutableArray *databaseURLs = [NSMutableArray array];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"pathExtension IN %@", [self supportedExtensions]];
        NSArray *filteredContents = [allContents filteredArrayUsingPredicate:filter];
        
        [filteredContents enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
            [databaseURLs addObject:[NSURL fileURLWithPath:[self.rootDirectory stringByAppendingPathComponent:fileName]]];
        }];
        
        [databaseURLs sortUsingDescriptors:[self databaseSortDescriptors]];
        
        _databaseURLs = databaseURLs;
    }
    return _databaseURLs;
}

- (NSArray *)supportedExtensions
{
    return [NSArray arrayWithObjects:@"pgn", nil];
}

- (NSArray *)databaseSortDescriptors
{
    NSSortDescriptor *alphabetical = [[NSSortDescriptor alloc] initWithKey:@"lastPathComponent" ascending:YES];
    return [NSArray arrayWithObjects:alphabetical, nil];
}

@end
