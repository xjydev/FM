//
//  DownLoadCenter.m
//  FileManager
//
//  Created by xiaodev on Dec/20/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "DownLoadCenter.h"
#import "XTools.h"
#import <AFNetworking/AFNetworking.h>
static DownLoadCenter *_center = nil;
@implementation DownLoadCenter

+ (instancetype)defaultDownLoad {
    if (_center == nil) {
        _center = [[DownLoadCenter alloc]init];
    }
    return _center;
}
- (BOOL)downLoadUrl:(NSString *)urlStr {
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSDictionary *headerDict =  request.allHTTPHeaderFields;
    NSLog(@"headerDict == %@",headerDict);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.requestSerializer.timeoutInterval = 3.0;
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        NSLog(@"%.2f / %.2f",(float)totalBytesWritten/1024.0/1024.0,(float)totalBytesExpectedToWrite/1024.0/1024.0);
    }];
   
    
//    _downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        
//    }];
//    
//    [_downloadTask resume];
    return YES;
//    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(suspend) userInfo:nil repeats:NO];
    
}
- (void)suspendDownloading {
    [_center.downloadTask suspend];
    
}
- (void)resumeDownloading {
    [_center.downloadTask resume];
}
@end
