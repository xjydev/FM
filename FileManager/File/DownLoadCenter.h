//
//  DownLoadCenter.h
//  FileManager
//
//  Created by xiaodev on Dec/20/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSURLSessionDownloadTask;
@interface DownLoadCenter : NSObject
+ (instancetype)defaultDownLoad;
@property (nonatomic, strong)NSURLSessionDownloadTask *downloadTask;
- (BOOL)downLoadUrl:(NSString *)urlStr;
- (void)suspendDownloading;
- (void)resumeDownloading;
@end
