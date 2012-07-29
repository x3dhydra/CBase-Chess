//
//  CKDatabaseListProvider.h
//  CBase Chess
//
//  Created by Austen Green on 7/23/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKDatabaseListProviderDelegate;

@interface CKDatabaseListProvider : NSObject
@property (nonatomic, weak) id<CKDatabaseListProviderDelegate> delegate;
@property (nonatomic, strong) NSString *rootDirectory;
@property (nonatomic, readonly) NSArray *databaseURLs;

- (id)initWithRootDirectory:(NSString *)rootDirectory;

- (void)reloadData;

@end

@protocol CKDatabaseListProviderDelegate <NSObject>
@optional
- (void)databaseListProviderDidUpdateDatabaseList:(CKDatabaseListProvider *)listProvider;

@end