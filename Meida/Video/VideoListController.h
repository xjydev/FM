//
//  VideoListController.h
//  FileManager
//
//  Created by XiaoDev on 07/04/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoListController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, strong)NSArray  *moveArray;
@property (nonatomic, copy) NSString *folderPath;
@end
