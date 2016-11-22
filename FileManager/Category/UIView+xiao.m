//
//  UIView+xiao.m
//  FileManage
//
//  Created by xiaodev on Nov/2/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "UIView+xiao.h"
#import <objc/runtime.h>
static char *backChar = "backChar";
@implementation UIView (text)

- (void)xNoDataThisView {
    
    UILabel *backLabel = (UILabel *)objc_getAssociatedObject(self, backChar);
    if (!backLabel) {
        backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/6*2, self.frame.size.width, 40)];
        backLabel.text = @"无文档";
        backLabel.textAlignment = NSTextAlignmentCenter;
        backLabel.font = [UIFont boldSystemFontOfSize:18];
        backLabel.textColor = [UIColor grayColor];
        [self addSubview:backLabel];
        objc_setAssociatedObject(self, backChar, backLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
}
- (void)xRemoveNoData {
    
    UILabel *backLabel = (UILabel *)objc_getAssociatedObject(self, backChar);
    [backLabel removeFromSuperview];
}


@end
