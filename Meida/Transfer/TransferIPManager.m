//
//  TransferIPManager.m
//  FileManager
//
//  Created by xiaodev on Feb/16/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "TransferIPManager.h"
#import "XTools.h"
static TransferIPManager *_transfer = nil;
@interface TransferIPManager ()<GCDWebUploaderDelegate>


@end
@implementation TransferIPManager
+ (instancetype)defaultManager {
    if (!_transfer) {
        _transfer = [[TransferIPManager alloc]init];
    }
    return _transfer;
}
- (void)startConnect {
    if (self.uploadPath.length == 0) {
        self.uploadPath = KDocumentP;
    }
    
    if (!self.webServer) {
        self.webServer = [[GCDWebUploader alloc] initWithUploadDirectory:self.uploadPath];
        self.webServer.delegate = self;
        self.webServer.allowHiddenItems = YES;
    }
    else if (![self.webServer.uploadDirectory isEqualToString:self.uploadPath]) {
       self.webServer = [[GCDWebUploader alloc] initWithUploadDirectory:self.uploadPath];
        self.webServer.delegate = self;
        self.webServer.allowHiddenItems = YES;
    }
    
    [self.webServer start];
}
- (void)stopConnect {
    if (self.webServer.isRunning) {
        [self.webServer stop];
    }
}
- (void)webServerDidStart:(GCDWebServer *)server {
    if ([self.delegate respondsToSelector:@selector(transferServerDidStartOrStop:)]) {
        [self.delegate transferServerDidStartOrStop:YES];
    }
}
- (void)webServerDidStop:(GCDWebServer *)server {
    if ([self.delegate respondsToSelector:@selector(transferServerDidStartOrStop:)]) {
        [self.delegate transferServerDidStartOrStop:NO];
    }
    self.webServer.delegate = nil;
    self.webServer = nil;      

}
- (void)webServerDidConnect:(GCDWebServer *)server {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.isUploading = YES;
    NSLog(@"=====%@",server);
    if ([self.delegate respondsToSelector:@selector(transferConnectOrDisConnect:)]) {
        [self.delegate transferConnectOrDisConnect:YES];
    }
    
}
- (void)webServerDidDisconnect:(GCDWebServer *)server {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.isUploading = NO;
    if ([self.delegate respondsToSelector:@selector(transferConnectOrDisConnect:)]) {
        [self.delegate transferConnectOrDisConnect:NO];
    }
    if (!self.delegate) {
        [self stopConnect];
    }
}
- (void)webUploader:(GCDWebUploader *)uploader didDownloadFileAtPath:(NSString *)path {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(transferUploaderType:Path:)]) {
        [self.delegate transferUploaderType:UploaderTypeDownload Path:path];
    }
    else
    {
       [XTOOLS showMessage:@"下载完成"];
    }
}
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);

    if (self.delegate&&[self.delegate respondsToSelector:@selector(transferUploaderType:Path:)]) {
        [self.delegate transferUploaderType:UploaderTypeUpload Path:path];
    }
    else
    {
        [XTOOLS showMessage:@"上传完成"];
    }
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(transferUploaderType:Path:)]) {
        [self.delegate transferUploaderType:UploaderTypeMove Path:fromPath];
    }
    else
    {
        [XTOOLS showMessage:@"转移完成"];
    }

}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(transferUploaderType:Path:)]) {
        [self.delegate transferUploaderType:UploaderTypeDelete Path:path];
    }
    else
    {
        [XTOOLS showMessage:@"删除完成"];
    }

}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(transferUploaderType:Path:)]) {
        [self.delegate transferUploaderType:UploaderTypeCreate Path:path];
    }
    else
    {
        [XTOOLS showMessage:@"创建完成"];
    }

}

@end
