//
//  CBTabbedListViewController.h
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBTabbedListViewController : UITableViewController
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController *selectedViewController;

@end
