//
//  CBTabbedListViewController.m
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CBTabbedListViewController.h"
#import "IIViewDeckController.h"

@interface CBTabbedListViewController ()

@end

@implementation CBTabbedListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    // Only support Plain Table View Style
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    UIViewController *controller = [self viewControllerForRowAtIndexPath:indexPath];
    UITabBarItem *tabBarItem = controller.tabBarItem;
    
    cell.textLabel.text = tabBarItem.title;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [self viewControllerForRowAtIndexPath:indexPath];
    self.selectedViewController = viewController;
    [self.viewDeckController closeLeftViewAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 

- (UIViewController *)viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewControllers objectAtIndex:indexPath.row];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = [viewControllers copy];
    if (![_viewControllers containsObject:self.selectedViewController])
    {
        self.selectedViewController = [_viewControllers objectAtIndex:0];
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    _selectedViewController = selectedViewController;
    self.viewDeckController.centerController = selectedViewController;
}

@end
