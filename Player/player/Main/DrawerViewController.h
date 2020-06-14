//
//  DrawerViewController.h
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LeftViewController;
@interface DrawerViewController : UIViewController
+ (instancetype)shareDrawer;
@property (nonatomic, assign)BOOL isCanShow;
- (instancetype)initMainVC:(UIViewController *)mainVC leftVC:(LeftViewController *)leftVC leftWidth:(CGFloat)leftWidth;
- (void)openLeftMenu;
- (void)closeLeftMenu;
- (void)leftViewDidSelectedtag:(NSInteger )tag;
@end
