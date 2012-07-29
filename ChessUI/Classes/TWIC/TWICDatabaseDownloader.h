//
//  TWICDatabaseDownloader.h
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWICDatabaseDownloadDelegate;

@interface TWICDatabaseDownloader : NSObject
@property (nonatomic, weak) id<TWICDatabaseDownloadDelegate> delegate;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong) NSString *destinationPath;

- (id)initWithURL:(NSURL *)URL;

- (BOOL)isDownloading;
- (void)beginDownload;

@end

@protocol TWICDatabaseDownloadDelegate <NSObject>

@optional
- (void)databaseDownloaderDidFinish:(TWICDatabaseDownloader *)downloader;
- (void)databaseDownloader:(TWICDatabaseDownloader *)downloader didFailWithError:(NSError *)error;
- (void)databaseDOwnloader:(TWICDatabaseDownloader *)downloader didUpdateDownloadPercent:(CGFloat)downloadPercent;

@end