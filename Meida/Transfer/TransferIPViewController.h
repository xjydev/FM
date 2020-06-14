//
//  TransferIPViewController.h
//  FileManager
//
//  Created by xiaodev on Nov/28/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//
typedef void(^FilesTransferChangeBack)(int num);
#import <UIKit/UIKit.h>

@interface TransferIPViewController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, copy)NSString *filePath;
/**
 如果创建了文件夹，首页的文件夹列表需要刷新。
 */
@property (nonatomic, strong)FilesTransferChangeBack filesTransferChangeBack;
@end
