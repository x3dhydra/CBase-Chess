//
//  AppDelegate.m
//  ChessUI
//
//  Created by Austen Green on 11/27/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "AppDelegate.h"
#import "ChessbaseDatabaseViewController.h"
#import "ChessKit.h"
#import "BoardViewController.h"
#import "DatabaseViewController.h"
#import "DatabaseListViewController.h"
#import "IIViewDeckController.h"
#import "CBTabbedListViewController.h"

@interface AppDelegate()

@property (nonatomic, strong) DatabaseListViewController *databaseListController;
@end

@implementation AppDelegate
@synthesize databaseListController;

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.databaseListController = [[DatabaseListViewController alloc] init];
    UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:self.databaseListController];
    
    CBTabbedListViewController *listController = [[CBTabbedListViewController alloc] init];
    listController.viewControllers = @[ centerController ];
    
    IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:listController];
    
    self.window.rootViewController = viewDeckController;
    
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Defaults" withExtension:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSURL *newURL = [[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]] URLByAppendingPathComponent:[url lastPathComponent]];
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtURL:url toURL:newURL error:&error];
    
    if (success)
    {
        [self.databaseListController reloadData];
    }
    else {
        NSLog(@"Error moving file: %@", error);
    }
    return success;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
