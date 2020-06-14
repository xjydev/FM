//
//  UIView+badgeValue.h
//  ABAuthModule
//
//  Created by XiaoDev on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (badgeValue)
/**
 设置消息数，设置小于或等于0 、nil 就隐藏.设置@"" 为红点。
 */
@property (nonatomic, copy)NSString *abBadgeValue;

@end

NS_ASSUME_NONNULL_END
