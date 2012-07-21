//
//  CKDatabaseSearchController.h
//  ChessUI
//
//  Created by Austen Green on 7/14/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDatabase.h"

@protocol CKDatabaseSearchControllerDelegate;

@interface CKDatabaseSearchController : NSObject <UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, readonly, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, readonly, strong) CKDatabase *database;
@property (nonatomic, assign) id<CKDatabaseSearchControllerDelegate> delegate;

- (id)initWithDatabase:(CKDatabase *)database searchDisplayController:(UISearchDisplayController *)searchDisplayController;

@end

@protocol CKDatabaseSearchControllerDelegate <NSObject>

- (void)databaseSearchController:(CKDatabaseSearchController *)searchController didSelectGameAtIndex:(NSUInteger)index;

@end