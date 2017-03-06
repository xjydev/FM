//
//  TransferIPManager.h
//  FileManager
//
//  Created by xiaodev on Feb/16/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDWebUploader.h"
@protocol TransferIpManagerDelegate ;

typedef NS_ENUM(NSInteger , UploaderType){
    UploaderTypeDownload,
    UploaderTypeUpload,
    UploaderTypeMove,
    UploaderTypeDelete,
    UploaderTypeCreate
    
};

@interface TransferIPManager : NSObject

@property (nonatomic, strong)GCDWebUploader* webServer;
@property (nonatomic, weak)id<TransferIpManagerDelegate> delegate;
@property (nonatomic, assign)BOOL   isUploading;
+ (instancetype)defaultManager;

/**
 开始连接
 */
- (void)startConnect;

/**
 结束连接
 */
- (void)stopConnect;
@end
@protocol TransferIpManagerDelegate <NSObject>

@optional
/**
 是否开始连接

 @param isStart 是否已经开始连接
 */
- (void)transferServerDidStartOrStop:(BOOL)isStart;

/**
 是否开始传输

 @param isConnect 是否正在传输
 */
- (void)transferConnectOrDisConnect:(BOOL)isConnect;

/**
 文件传输完成的方式和路径

 @param type 操作的方式
 @param path 原路径
 */
- (void)transferUploaderType:(UploaderType)type Path:(NSString *)path;

@end
