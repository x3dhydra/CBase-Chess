//
//  CKGameMetadataViewController.h
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKGame.h"

@interface CKGameMetadataViewController : UITableViewController
@property (nonatomic, readonly) CKGame *game;

- (id)initWithGame:(CKGame *)game;

@end
