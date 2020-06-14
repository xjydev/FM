//
//  HomeFeedCell.h
//  FileManager
//
//  Created by 阿凡树 on 2017/4/7.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFeedModel.h"
@interface HomeFeedCell : UITableViewCell
@property (nonatomic, readwrite, retain) HomeFeedModel *model;

- (void)startPlay;
- (void)stopPlay;

@end
