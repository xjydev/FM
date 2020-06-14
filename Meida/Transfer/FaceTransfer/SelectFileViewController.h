//
//  FaceTransferViewController.h
//  FileManager
//
//  Created by xiaodev on Feb/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTools.h"
typedef void(^SelectedPath) (NSString *path);
@interface SelectFileViewController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, strong)SelectedPath selectedPath;
@property (nonatomic, assign)FileType fileType;
@property (nonatomic, assign)BOOL     showHiddenFiles;
@end
