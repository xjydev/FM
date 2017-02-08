//
//  AudioViewController.h
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioViewController : UIViewController
@property (nonatomic ,copy)NSString *audioPath;
@property (nonatomic ,strong)NSArray *audioArray;
@property (nonatomic , assign)NSInteger index;
- (void)setAudioArray:(NSArray *)audioArray index:(NSInteger)index;
@end
