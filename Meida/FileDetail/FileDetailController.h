//
//  FileDetailController.h
//  FileManager
//
//  Created by xiaodev on Dec/22/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileDetailController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, copy)NSString *filePath;
@end
