//
//  DownLoadCenter.h
//  FileManager
//
//  Created by xiaodev on Dec/20/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSURLSessionDownloadTask;


@protocol DownloadCenterDelegate <NSObject>
/**
 *  断点续传的进度
 *
 *  @param values 双浮点
 */
- (void)progress:(double)values;
/**
 *  是否完成下载
 *
 *  @param isfinish 完成返回YES
 */
- (void)finishDown:(BOOL)isfinish filePath:(NSString *)path;

@end

@interface DownLoadCenter : NSObject
+ (instancetype)defaultDownLoad;
@property (nonatomic , strong) NSURLSession * downloadSession;
@property (nonatomic , strong) NSURLSessionDownloadTask *task;
@property (nonatomic , strong) NSData *resumeData;
@property (nonatomic , copy) NSString *downLoadUrlStr;
/**
 *  状态为1时，是已经断点过，不为1时时重头开始下载
 */
@property (nonatomic , assign)NSInteger statusnum;
/**
 *  续传下载协议
 */
@property (nonatomic , weak)id<DownloadCenterDelegate> DWdelegate;


/**
 *  开始下载
 *
 *  @param url  http/https
 *  @param trag 协议对象
 */
- (void)startDownload:(NSString *)url trag:(id)trag;
/**
 *  继续下载
 */
- (void)resumeDownload;
/**
 *  取消下载
 */
- (void)pauseDownload;

@end
