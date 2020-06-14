//
//  UIView+xiao.m
//  FileManage
//
//  Created by xiaodev on Nov/2/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "UIView+xiao.h"
#import <objc/runtime.h>
#import "XTools.h"
#import "UIColor+Hex.h"
static char *backChar = "backChar";

static NSString * const badgeStr = @"ABbadgeValue";
static char *badgeChar = "ABbadgeValueChar";

@implementation UIView (xiao)
@dynamic xdBadgeValue;
- (void)xNoDataThisViewTitle:(NSString *)title centerY:(CGFloat)y{
    
    UILabel *backLabel = (UILabel *)objc_getAssociatedObject(self, backChar);
    if (!backLabel) {
        backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/6*2, kScreen_Width, 40)];
        backLabel.text = NSLocalizedString(@"NOfiles", nil);
        backLabel.textAlignment = NSTextAlignmentCenter;
        backLabel.font = [UIFont boldSystemFontOfSize:18];
        backLabel.textColor = [UIColor grayColor];
        [self addSubview:backLabel];
        [self bringSubviewToFront:backLabel];
        objc_setAssociatedObject(self, backChar, backLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    backLabel.alpha = 1.0;
    backLabel.center = CGPointMake(kScreen_Width/2, y);
    backLabel.text = title;
    
}
- (void)xRemoveNoData {
    
    UILabel *backLabel = (UILabel *)objc_getAssociatedObject(self, backChar);
    if (backLabel) {
       [backLabel removeFromSuperview];
       objc_setAssociatedObject(self, backChar, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setXdBadgeValue:(NSString *)xdBadgeValue {
    [self willChangeValueForKey:badgeStr];
    UILabel *badgeLabel = (UILabel *)objc_getAssociatedObject(self, badgeChar);
    if (xdBadgeValue) {//有值
        if (!badgeLabel) {
            badgeLabel = [[UILabel alloc]init];
            badgeLabel.backgroundColor = [UIColor redColor];
            badgeLabel.textAlignment = NSTextAlignmentCenter;
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.font = [UIFont systemFontOfSize:10];
            badgeLabel.layer.cornerRadius = 5;
            badgeLabel.layer.masksToBounds = YES;
            [self addSubview:badgeLabel];
            objc_setAssociatedObject(self, badgeChar, badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        badgeLabel.text = xdBadgeValue;
        if (xdBadgeValue.length>0) {
            badgeLabel.frame = CGRectMake(self.frame.size.width - 12, 0,18, 18);
            badgeLabel.layer.cornerRadius = 9;
            badgeLabel.layer.masksToBounds = YES;
        }
        else {
            badgeLabel.frame = CGRectMake(self.frame.size.width - 6, 0, 10, 10);
//            badgeLabel.layer.cornerRadius = 5;
//            badgeLabel.layer.masksToBounds = YES;
        }
    }
    else {
        if (badgeLabel) {
            [badgeLabel removeFromSuperview];
            objc_setAssociatedObject(self, badgeChar, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    [self didChangeValueForKey:badgeStr];
}

    - (NSString *)xdBadgeValue {
        UILabel *badgeLabel = objc_getAssociatedObject(self, badgeChar);
        return badgeLabel.text;
    }
@end
