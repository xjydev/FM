//
//  XimageViewController.h
//  FileManager
//
//  Created by xiaodev on Dec/10/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XimageViewController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, strong)NSArray  *moveArray;
@property (nonatomic, copy)NSString *folderPath;
@end
