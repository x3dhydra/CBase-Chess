//
//  TWICGameListScraper.h
//  CBase Chess
//
//  Created by Austen Green on 7/26/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWICDatabaseListScraper : NSObject
@property (nonatomic, readonly) NSArray *databaseURLs;

- (void)fetchDatabaseListWithCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
