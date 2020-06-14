//
//  safeView.h
//  FileManager
//
//  Created by xiaodev on Feb/25/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KPassWord @"wpoarsds"
#define kTouchPassWord @"ptaosuscwhord"

typedef NS_ENUM(NSInteger , PassWordType) {
    PassWordTypeDefault,
    PassWordTypeReset,
    PassWordTypeSet,
};
typedef void (^ ThroughPassWord)(NSInteger num);
@interface SafeView : UIView

@property (nonatomic, strong)ThroughPassWord throughPassWord;
@property (nonatomic, assign)PassWordType type;
@property (nonatomic, assign)BOOL supportTouchID;//是否支持人脸或者指纹
@property (nonatomic, assign)BOOL isTouchID;//是人脸识别还是指纹
+ (instancetype)defaultSafeView;
/**
 显示手势密码，并通过密码验证

 @param handle 密码1指纹通过，2手势通过，3放弃,4设置密码成功，5重置密码成功。void (^)(NSInteger num)
 */
- (void)showSafeViewHandle:(ThroughPassWord)handle;

@end
