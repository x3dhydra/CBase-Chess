//
//  CKGameSettingsViewController.m
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameSettingsViewController.h"
#import "CBaseConstants.h"

@interface CKGameSettingsViewController ()

@end

@implementation CKGameSettingsViewController
@synthesize variationsSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.variationsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:CKDisplayVariationsDialogKey];
    
    // Tweak for iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)toggleVariations:(UISwitch *)sender 
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:CKDisplayVariationsDialogKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:CKDisplayVariationsPreferenceDidChangeNotification object:nil];
}

- (IBAction)done:(id)sender 
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320.0f, 200.0f);
}
@end
