//
//  FaceConnectController.h
//  FileManager
//
//  Created by xiaodev on Mar/14/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceConnectController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, copy)NSString *folderPath;
@property (nonatomic, copy)NSString *filePath;
@end
