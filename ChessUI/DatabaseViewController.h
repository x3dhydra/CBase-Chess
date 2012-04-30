//
//  DatabaseViewController.h
//  ChessUI
//
//  Created by Austen Green on 4/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessKit.h"

@interface DatabaseViewController : UITableViewController
@property (nonatomic, readonly) CKDatabase *database;

- (id)initWithDatabase:(CKDatabase *)database;

@end
