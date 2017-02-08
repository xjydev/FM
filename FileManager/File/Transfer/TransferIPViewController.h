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
@property (nonatomic, strong)FilesTransferChangeBack filesTransferChangeBack;
@end
