//
//  MRVLCPlayer.h
//  MRVLCPlayer
//
//  Created by apple on 16/3/5.
//  Copyright © 2016年 Alloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import "MRVideoControlView.h"
typedef NS_ENUM(NSInteger ,PrevNextType) {
    PrevNextTypePrev,//前一个按钮不可点
    PrevNextTypeNext,//下一个不可点
    PrevNextTypeAll,//都不可点击
    PrevNextDefaul,//都可以点击
};
@protocol MRVLCPlayerDelegate <NSObject>

@optional
- (void)playerCloseButton:( UIButton * _Nonnull )button ;
- (void)playerNextPrevButtonIsNext:(BOOL)isNext;
- (void)playerStateEnd;

@end

@interface MRVLCPlayer : UIView <VLCMediaPlayerDelegate,MRVideoControlViewDelegate>

@property (nonatomic,strong,nonnull) NSURL *mediaURL;
@property (nonatomic,assign) BOOL isFullscreenModel;
@property (nonatomic, assign) PrevNextType prevNextType;

@property (nullable, nonatomic,weak) id<MRVLCPlayerDelegate>delegate;
- (void)showInView:(UIView * _Nonnull)view;
- (void)play;

@end


