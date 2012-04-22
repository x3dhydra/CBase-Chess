//
//  ChessbaseDatabaseViewController.h
//  ChessUI
//
//  Created by Austen Green on 11/27/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBDatabase.h"

@interface ChessbaseDatabaseViewController : UITableViewController
@property (nonatomic, strong) CBDatabase *database;

@end
