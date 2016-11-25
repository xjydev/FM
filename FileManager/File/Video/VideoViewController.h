//
//  VideoViewController.h
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoViewController : UIViewController
@property (nonatomic, copy)NSString *videoPath;
//@property (nonatomic, strong)NSArray *videoPathArray;
//@property (nonatomic, assign)NSInteger currentVideoIndex;
- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index;
@end
