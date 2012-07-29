//
//  CBaseNotifications.h
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

// Post this notification with no userInfo or object to indicate that a new database has been added
// and that any database lists should be refreshed
extern NSString * const CBaseDidAddDatabaseNotification;