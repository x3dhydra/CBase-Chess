//
//  TWICDatabaseDownloader.m
//  CBase Chess
//
//  Created by Austen Green on 7/29/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "TWICDatabaseDownloader.h"
#import "SSZipArchive.h"

@interface TWICDatabaseDownloader() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *_connection;
    NSFileHandle *_fileHandle;
    NSString *_temporaryFilePath;
    NSString *_destinationPath;
}

@end

@implementation TWICDatabaseDownloader

- (id)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self)
    {
        _URL = URL;
    }
    return self;
}

- (void)beginDownload
{
    if ([self isDownloading])
        return;
    
    _temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    if ([[NSFileManager defaultManager] createFileAtPath:_temporaryFilePath contents:nil attributes:nil])
    {
        NSError *error = nil;
        NSURL *tempURL = [NSURL fileURLWithPath:_temporaryFilePath];
        _fileHandle = [NSFileHandle fileHandleForWritingToURL:tempURL error:&error];
        if (_fileHandle)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
            _connection = [NSURLConnection connectionWithRequest:request delegate:self];
        }
        else
        {
            [self didFailWithError:error];
        }
    }
    else
    {
        [self didFailWithError:nil];
    }
}

- (BOOL)isDownloading
{
    return _connection != nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self cleanupDownload];
    [self didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cleanupDownload];
    [self unzipFileAtPath:_temporaryFilePath];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_fileHandle writeData:data];
}

#pragma mark - Completion

- (void)cleanupDownload
{
    _connection = nil;
}

- (void)didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(databaseDownloader:didFailWithError:)])
    {
        [self.delegate databaseDownloader:self didFailWithError:error];
    }
}

- (void)didSucceed
{
    if ([self.delegate respondsToSelector:@selector(databaseDownloaderDidFinish:)])
    {
        [self.delegate databaseDownloaderDidFinish:self];
    }
}

#pragma mark - Zip Operations

- (void)unzipFileAtPath:(NSString *)path
{
    NSError *error = nil;
    if ([SSZipArchive unzipFileAtPath:path toDestination:self.destinationPath overwrite:NO password:nil error:&error])
        [self didSucceed];
    else
        [self didFailWithError:error];
}

@end
