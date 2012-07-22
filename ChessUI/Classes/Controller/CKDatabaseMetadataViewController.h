//
//  CKDatabaseMetadataViewController.h
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKDatabaseMetadataViewController;

@protocol CKDatabaseMetadataViewControllerDelegate <NSObject>

- (void)metadataViewController:(CKDatabaseMetadataViewController *)metadataViewController didMoveDatabaseAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL;

@end

@interface CKDatabaseMetadataViewController : UITableViewController
@property (nonatomic, readonly) NSURL *databaseURL;
@property (nonatomic, weak) id<CKDatabaseMetadataViewControllerDelegate> delegate;

- (id)initWithURL:(NSURL *)databaseURL;

@end
