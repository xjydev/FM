//
//  UIView+xiao.h
//  FileManage
//
//  Created by xiaodev on Nov/2/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (xiao)
- (void)xNoDataThisViewTitle:(NSString *)title centerY:(CGFloat)y;
- (void)xRemoveNoData;
/**
 设置消息数，设置小于或等于0 、nil 就隐藏.设置@"" 为红点。
 */
@property (nonatomic, copy)NSString *xdBadgeValue;

@end
