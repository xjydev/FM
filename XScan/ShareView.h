//
//  ShareView.h
//  QRcreate
//
//  Created by xiaodev on May/3/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger , XShareType) {
    XShareTypeWeChat,
    XShareTypeTimeLine,
    XShareTypeQQ,
    XShareTypeQzone,
    XShareTypeCopy,
    XShareTypeReadList,
    XShareTypeSaveImage,
    XShareTypeSafari,
    XShareTypeEnd,//必须要用end结束。
};

@interface ShareView : UIView
@property (nonatomic, strong)UIViewController *currentViewController;
+(instancetype)shareView;

- (void)shareViewWithUrl:(NSString *)urlstr Title:(NSString *)title;
- (void)shareViewWithImage:(UIImage *)image;
- (void)shareViewVithText:(NSString *)text;

- (void)shareViewWithTitle:(NSString *)title Detail:(NSString *)detail Image:(UIImage *)image Types:(XShareType)types,...;

@end
