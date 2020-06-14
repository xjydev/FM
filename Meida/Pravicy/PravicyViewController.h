//
//  PravicyViewController.h
//  FileManager
//
//  Created by xiaodev on Sep/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PravicyViewController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, copy)NSString * filePath;
@end
