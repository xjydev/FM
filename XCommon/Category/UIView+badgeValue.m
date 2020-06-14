//
//  UIView+badgeValue.m
//  ABAuthModule
//
//  Created by XiaoDev on 2019/3/19.
//

#import "UIView+badgeValue.h"
#import <objc/runtime.h>

static NSString * const badgeStr = @"ABbadgeValue";
static char *badgeChar = "ABbadgeValueChar";

@implementation UIView (badgeValue)
@dynamic abBadgeValue;
- (void)setAbBadgeValue:(NSString *)abBadgeValue {
    [self willChangeValueForKey:badgeStr];
    UILabel *badgeLabel = (UILabel *)objc_getAssociatedObject(self, badgeChar);
    if (abBadgeValue && ![abBadgeValue isEqualToString:@"0"]) {//有值并且值不是@0
        if (!badgeLabel) {
            badgeLabel = [[UILabel alloc]init];
            badgeLabel.backgroundColor = [UIColor redColor];
            badgeLabel.textAlignment = NSTextAlignmentCenter;
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.font = [UIFont systemFontOfSize:10];
            [self addSubview:badgeLabel];
            objc_setAssociatedObject(self, badgeChar, badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        if (abBadgeValue.integerValue > 99) {
           badgeLabel.text = @"99+";
        }
        else
        {
           badgeLabel.text = abBadgeValue;
        }
        if (abBadgeValue.length>0) {
            CGSize size = [badgeLabel sizeThatFits:CGSizeMake(self.frame.size.width/2, 16)];
            badgeLabel.frame = CGRectMake(self.frame.size.width-size.width/2, -8,MAX(16, size.width+6), 16);
            badgeLabel.layer.cornerRadius = 8;
            badgeLabel.layer.masksToBounds = YES;
            badgeLabel.layer.borderWidth = 1;
            badgeLabel.layer.borderColor = [UIColor colorWithRed:97.0/255.0 green:99/255.0 blue:129/255.0 alpha:1.0].CGColor;
        }
        else
        {
            badgeLabel.frame = CGRectMake(self.frame.size.width-4, -4, 8, 8);
            badgeLabel.layer.cornerRadius = 4;
            badgeLabel.layer.masksToBounds = YES;
            badgeLabel.layer.borderWidth = 1;
            badgeLabel.layer.borderColor = [UIColor colorWithRed:97.0/255.0 green:99/255.0 blue:129/255.0 alpha:1.0].CGColor;
        }
    }
    else
    {
        if (badgeLabel) {
            [badgeLabel removeFromSuperview];
            objc_setAssociatedObject(self, badgeChar, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    [self didChangeValueForKey:badgeStr];
}
- (NSString *)abBadgeValue {
    UILabel *badgeLabel = objc_getAssociatedObject(self, badgeChar);
    return badgeLabel.text;
}
@end
