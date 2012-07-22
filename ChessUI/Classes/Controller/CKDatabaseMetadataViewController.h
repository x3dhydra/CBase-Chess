//
//  CKDatabaseMetadataViewController.h
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKDatabaseMetadataViewController : UITableViewController
@property (nonatomic, readonly) NSURL *databaseURL;

- (id)initWithURL:(NSURL *)databaseURL;

@end
