//
//  TWICGameListScraper.m
//  CBase Chess
//
//  Created by Austen Green on 7/26/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "TWICDatabaseListScraper.h"

static NSString * const TWICDatabaseListPath = @"http://www.chess.co.uk/twic/twic";

@interface TWICDatabaseListScraper()
{
    NSArray *_databaseURLs;
}
@end

@implementation TWICDatabaseListScraper

- (void)fetchDatabaseListWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    NSURL *URL = [NSURL URLWithString:TWICDatabaseListPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    completion = [completion copy];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ((!data || error) && completion)
        {
            completion(NO, error);
        }
        else
        {
            BOOL success = [self parseData:data error:&error];
            
            if (completion)
                completion(success, nil);
        }
    }];
}

- (BOOL)parseData:(NSData *)data error:(NSError **)error
{
    //"http://www.chesscenter.com/twic/zips/twic924g.zip
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http.+(g.zip){1}" options:0 error:error];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSMutableArray *URLs = [NSMutableArray arrayWithCapacity:matches.count];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
        NSString *path = [string substringWithRange:[result range]];
        [URLs addObject:[NSURL URLWithString:path]];
    }];
    
    _databaseURLs = URLs;
    
    if (_databaseURLs.count)
        return YES;
    else
        return NO;
}

@end
