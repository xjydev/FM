//
//  MRVideoControl.h
//  MRVLCPlayer
//
//  Created by Maru on 16/3/8.
//  Copyright © 2016年 Alloc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MRVideoHUDView.h"
#import "PlayerCenterView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MRVideoConst.h"
@class MRProgressSlider;


@protocol MRVideoControlViewDelegate <NSObject>
@optional
- (void)controlViewFingerMoveUp;
- (void)controlViewFingerMoveDown;
- (void)controlViewFingerMoveLeftWithTime:(int)intSec;
- (void)controlViewFingerMoveRightWithTime:(int)intSec;
- (int)currentPlayTimeSecond;
- (int)allPlayTimeSecond;

@end


@interface MRVideoControlView : UIView

@property (nonatomic,weak) id<MRVideoControlViewDelegate> delegate;

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *topTitleLabel;

@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) CAGradientLayer *bottomLayer;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *rateButton;

@property (nonatomic, strong) MRProgressSlider *progressSlider;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) PlayerCenterView *centerView;
@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, assign) BOOL  hiddenFrontView;
@property (nonatomic, assign) BOOL  isFullscreen;
//@property (nonatomic, strong) UILabel *alertlable;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

@end

@interface MRProgressSlider : UISlider
@end



