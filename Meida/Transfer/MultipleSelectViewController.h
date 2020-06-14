//
//  MultipleSelectViewController.h
//  player
//
//  Created by XiaoDev on 2019/11/16.
//  Copyright © 2019 Xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTools.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^MultipleSelectComplete)(NSArray *selectArray);
@interface MultipleSelectViewController : UIViewController
+ (instancetype)allocFromInit;
- (void)selectFileComplete:(MultipleSelectComplete)complete;
@property (nonatomic, copy)NSString *folderPath;
@property (nonatomic, assign)FileType fileType;
@end

NS_ASSUME_NONNULL_END
