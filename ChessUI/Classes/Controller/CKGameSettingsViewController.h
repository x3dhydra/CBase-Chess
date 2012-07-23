//
//  CKGameSettingsViewController.h
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKGameSettingsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *variationsSwitch;
- (IBAction)toggleVariations:(UISwitch *)sender;
- (IBAction)done:(id)sender;

@end
