//
//  XDPhotoViewController.h
//  Wenjian
//
//  Created by XiaoDev on 2019/9/2.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,XDPhotoStatus) {
    XDPhotoStatusCancel,//取消
    XDPhotoStatusComplete,//完成
};
typedef void (^PhotoComplete)(NSArray * _Nullable photoArray,XDPhotoStatus status);

@interface XDPhotoViewController : UINavigationController
@property (nonatomic, copy)PhotoComplete photoCompleteHandler;
@property (nonatomic, assign)NSInteger maxCount;//最大张数
+ (void)pickerPhotoWithSelectedArray:(nullable NSArray *)selectedArray max:(NSInteger)max complete:(PhotoComplete)completeHanlder;
+ (void)pickerPhotoWithMaxCount:(NSInteger)max complete:(PhotoComplete)completeHanlder;

@end

NS_ASSUME_NONNULL_END
