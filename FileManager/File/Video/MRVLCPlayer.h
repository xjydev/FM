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
#import "VideoAudioPlayer.h"
@protocol MRVLCPlayerDelegate <NSObject>

@optional
- (void)playerCloseButton:( UIButton * _Nonnull )button ;
//- (void)playerNextPrevButtonIsNext:(BOOL)isNext;
//- (void)playerStateEnd;

@end

@interface MRVLCPlayer : UIView <VLCMediaPlayerDelegate,MRVideoControlViewDelegate>

@property (nonatomic,assign) BOOL isFullscreenModel;
@property (nonatomic, assign) BOOL isLeft;

@property (nonatomic,strong) VideoAudioPlayer *_Nonnull videoPlayer;

@property (nullable, nonatomic,weak) id<MRVLCPlayerDelegate>delegate;
//- (void)showInView:(UIView * _Nonnull)view;
- (void)play;

@end


