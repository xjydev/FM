//
//  XProgressView.h
//  FileManager
//
//  Created by xiaodev on Dec/15/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XProgressView : UIView
+(instancetype)defaultProgress;
@property (nonatomic , strong) UIProgressView  *progressView;
@property (nonatomic , assign)float  percentage;
- (void)removeRelease;
@end
