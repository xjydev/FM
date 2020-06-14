//
//  NewVideoViewController.h
//  FileManager
//
//  Created by XiaoDev on 15/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewVideoViewController : UIViewController
+ (instancetype)allocFromStoryBoard;

@property (nonatomic, copy)NSString *videoPath;
- (BOOL)getVideoArrayCurrentPath;
- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index;

@end
