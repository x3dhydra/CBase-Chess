//
//  DatabaseListViewController.h
//  ChessUI
//
//  Created by Austen Green on 5/9/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatabaseListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (void)reloadData;

@end
