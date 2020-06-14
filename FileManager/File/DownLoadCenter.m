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
#import "XManageCoreData.h"
static DownLoadCenter *_center = nil;
#define VIDEO_URL @"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4"
@interface DownLoadCenter ()<NSURLSessionDownloadDelegate>

@end
@implementation DownLoadCenter

+ (instancetype)defaultDownLoad {
    if (_center == nil) {
        _center = [[DownLoadCenter alloc]init];
    }
    return _center;
}
- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.downloadSession = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _downloadSession;
}
- (void)startDownload:(NSString *)url trag:(id)trag
{
    if ([self.downLoadUrlStr isEqualToString:url]) {
//        if (self.statusnum = 1) {
//            [self resumeDownload];
//        }
    }
    else
    {
        self.downLoadUrlStr = url;
        NSString *tmpPath =[kCachesP stringByAppendingPathComponent:[XTOOLS md5Fromstr:self.downLoadUrlStr]];
        if ([kFileM fileExistsAtPath:tmpPath]) {
            self.resumeData = [NSData dataWithContentsOfFile:tmpPath];
        }
        else
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            NSURL * URL = [NSURL URLWithString:url];
            self.task = [self.downloadSession downloadTaskWithURL:URL];
            [self.task resume];
            self.statusnum = 1;
            //开始下载的时候存储一下
            [[XManageCoreData manageCoreData]saveDownloadUrl:url Progress:0 downLoadPath:nil];
        }
        
    }
    self.DWdelegate = trag;
    
}

- (void)resumeDownload
{
    // 传入上次暂停下载返回的数据，就可以恢复下载
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.task = [self.downloadSession downloadTaskWithResumeData:self.resumeData];
    
    // 继续
    [self.task resume];
    // 清空
    self.resumeData = nil;
    
}

- (void)pauseDownload
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    __weak typeof(self) vc = self;
    [self.task cancelByProducingResumeData:^(NSData *resumeData) {
        vc.resumeData = resumeData;
        vc.task = nil;
        NSString *tmpPath = [kCachesP stringByAppendingPathComponent:[XTOOLS md5Fromstr:self.downLoadUrlStr]];
        
        [vc.resumeData writeToFile:tmpPath atomically:YES];
        [[XManageCoreData manageCoreData]saveDownloadUrl:self.downLoadUrlStr Progress:0 downLoadPath:nil];
    }];
    
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (session == self.downloadSession) {
        //        NSLog(@"下载停止");
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        // response.suggestedFilename 建议使用本身文件的名字命名
        NSString *file = [documentPath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
        
        
        self.statusnum = 2;
        
        self.downLoadUrlStr = nil;
       
            // AtPath : 剪切前的文件路径
            // ToPath : 剪切后的文件路径
        [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:file error:nil];
        [[XManageCoreData manageCoreData]saveDownloadUrl:self.downLoadUrlStr Progress:1.0 downLoadPath:file];
        if ([self.DWdelegate respondsToSelector:@selector(finishDown:filePath:)]) {
            [self.DWdelegate finishDown:YES filePath:file];
        }
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (session == self.downloadSession) {
        
        //    NSLog(@"获得下载进度--%@", [NSThread currentThread]);
        // 获得下载进度
        double  down_To = (double)totalBytesWritten / totalBytesExpectedToWrite;
        
        [self.DWdelegate progress:down_To];
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
@end
