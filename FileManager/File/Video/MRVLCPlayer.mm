//
//  MRVLCPlayer.m
//  MRVLCPlayer
//
//  Created by apple on 16/3/5.
//  Copyright © 2016年 Alloc. All rights reserved.
//

#import "MRVLCPlayer.h"
//#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MRVideoConst.h"

#import "XTools.h"

static const NSTimeInterval kVideoPlayerAnimationTimeinterval = 0.3f;

@interface MRVLCPlayer ()<VideoAudioPlayerDelegate> 
{
    CGRect _originFrame;
    float  _playRate;
    BOOL   _isNotification;
}
@property (nonatomic, nonnull,strong) MRVideoControlView *controlView;
@end

@implementation MRVLCPlayer

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _originFrame = frame;
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
                
                self.isLeft = YES;
                
            }
            else
            {
                self.isLeft = NO;
                
            }
            self.isFullscreenModel = YES;
        }
        [self setupNotification];
        
    }
    return self;
}

- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext {
    self.controlView.prevButton.enabled = hidePrev;
    self.controlView.nextButton.enabled = hideNext;
    self.controlView.topTitleLabel.text =[self.videoPlayer.currentPath lastPathComponent];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self setupPlayer];
    
    [self setupView];
    
    [self setupControlView];
}


#pragma mark - Public Method

- (void)dismiss {
    [self.videoPlayer pause];
    self.videoPlayer.drawable = nil;
    
    // 注销通知
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _isNotification = NO;
    
}

#pragma mark - Private Method
- (void)setupView {
    [self setBackgroundColor:[UIColor blackColor]];
}

- (void)setupPlayer {
    [self.videoPlayer setDrawable:self];
//    self.videoPlayer.media = [[VLCMedia alloc] initWithURL:self.mediaURL];
}

- (void)setupControlView {

    [self addSubview:self.controlView];
    
    //添加控制界面的监听方法
    [self.controlView.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.centerView.centerButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlView.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.prevButton addTarget:self action:@selector(prevNextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.nextButton addTarget:self action:@selector(prevNextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.rateButton addTarget:self action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.progressSlider addTarget:self action:@selector(progressClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.progressSlider addTarget:self action:@selector(progressChange) forControlEvents:UIControlEventValueChanged];
    [self.controlView.progressSlider addTarget:self action:@selector(progressTouchDown) forControlEvents:UIControlEventTouchDown];
}

- (void)prevNextButtonAction:(UIButton *)button {
    if (button == self.controlView.prevButton) {
       self.videoPlayer.index -=1;
    }
    else
    {
       self.videoPlayer.index +=1;
    }
}

- (void)setupNotification {
    
    if (!_isNotification) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //    [UIApplication sharedApplication].statusBarOrientation
        //监听转屏
        if (XTOOLS.isCanRotation) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(orientationHandler)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil
             ];//UIDeviceOrientationDidChangeNotification
            //  UIApplicationDidChangeStatusBarOrientationNotification
        }
        //回到前台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        //进入后台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        _isNotification = YES;
    }
   
}

/**
 *    强制横屏
 *
 *    @param orientation 横屏方向
 */
- (void)forceChangeOrientation:(UIInterfaceOrientation)orientation
{
    int val = orientation;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark Notification Handler
/**
 *    屏幕旋转处理
 */
- (void)orientationHandler {

    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        self.isFullscreenModel = NO;
    }
    else
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
               
                   self.isLeft = YES;
               
            }
            else
            {
                  self.isLeft = NO;
                
            }
            self.isFullscreenModel = YES;
        }
    
    [self.controlView autoFadeOutControlBar];
}
/**
 *    即将进入前台的处理
 */
- (void)applicationWillEnterForeground {
    
    if (self.controlView.playButton.hidden){
        VLCTime *targetTime = [[VLCTime alloc] initWithInt:[self.videoPlayer.time.value floatValue]-2];
        [self.videoPlayer setTime:targetTime];
        [self play];
    }
}

/**
 *    即将返回后台的处理
 */
- (void)applicationWillResignActive {
    if (self.controlView.playButton.hidden) {
      [self pause];
    }
}
#pragma mark Button Event
- (void)playButtonClick {
    [self play];
    
}
- (void)pauseButtonClick {
    
    [self pause];
    
}
- (void)closeButtonClick {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(playerCloseButton:)]) {
        [self.delegate playerCloseButton:self.controlView.closeButton];
    }
}

- (void)fullScreenButtonClick {
    if (IsPad) {
        [XTOOLS showLoading:@"打开系统方向锁定"];
    }
    else
    {
       self.isFullscreenModel = YES;
    }
    
}

- (void)shrinkScreenButtonClick {
    if (IsPad) {
        [XTOOLS showLoading:@"打开系统方向锁定"];
    }
    else
    {
       self.isFullscreenModel = NO;
    }
    
    
}

- (void)progressClick {

    int targetIntvalue = (int)(self.controlView.progressSlider.value * (float)kMediaLength.intValue);
    
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue];
    
    [self.videoPlayer setTime:targetTime];
    
    [self.controlView autoFadeOutControlBar];
}
- (void)progressChange {
    
}
- (void)progressTouchDown {
    [self.controlView cancelAutoFadeOutControlBar];
}
#pragma mark Player Logic
- (void)play {
    
    [self.videoPlayer play];
    self.controlView.playButton.hidden = YES;
    self.controlView.pauseButton.hidden = NO;
    [self.controlView autoFadeOutControlBar];
}

- (void)pause {
    [self.videoPlayer pause];
    self.controlView.playButton.hidden = NO;
    self.controlView.pauseButton.hidden = YES;
    [self.controlView cancelAutoFadeOutControlBar];
}

- (void)stop {
    [self.videoPlayer stop];
    self.controlView.progressSlider.value = 1;
    self.controlView.playButton.hidden = NO;
    self.controlView.pauseButton.hidden = YES;
}
- (void)rateButtonAction:(UIButton *)button {
    [self.controlView autoFadeOutControlBar];
    if (_playRate >= 2.0) {
        _playRate = 0.5;
    }
    else
    {
        _playRate+=0.5;
    }
    [button setTitle:[NSString stringWithFormat:@"x%.1f",_playRate] forState:UIControlStateNormal];
    [self.videoPlayer setRate:_playRate];
}
#pragma mark - Delegate
#pragma mark VLC
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    // Every Time change the state,The VLC will draw video layer on this layer.
    NSLog(@"==%@ == %@",@(self.videoPlayer.media.state),@(self.videoPlayer.state));
    [self bringSubviewToFront:self.controlView];
    if (self.videoPlayer.media.state == VLCMediaStateBuffering) {
        [self.controlView.centerView ShowWithType:PlayerCenterTypeWaiting Title:@"缓存中"];
//        self.controlView.indicatorView.hidden = NO;

        self.controlView.hiddenFrontView = NO;
    }else if (self.videoPlayer.media.state == VLCMediaStatePlaying) {
        
        if (self.videoPlayer.state == VLCMediaPlayerStatePaused) {
            [self.controlView.centerView ShowWithType:PlayerCenterTypeStop Title:nil];
        }
        else
        {
            [self.controlView.centerView hiddenPlayButton];
        }
        [self.controlView.totalTimeLabel setText:[NSString stringWithFormat:@"%@",kMediaLength.stringValue]];
        self.controlView.hiddenFrontView = YES;
    }else if (self.videoPlayer.state == VLCMediaPlayerStateStopped) {
       
        
    }
    else {
        [self.controlView.centerView ShowWithType:PlayerCenterTypeWaiting Title:@"缓存中"];
        self.controlView.hiddenFrontView = NO;
    }
    
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    
    [self bringSubviewToFront:self.controlView];
    
    if (self.controlView.progressSlider.state != UIControlStateNormal) {
        return;
    }
    
    float precentValue = ([self.videoPlayer.time.value floatValue]) / ([kMediaLength.value floatValue]);
    
    [self.controlView.progressSlider setValue:precentValue animated:YES];
    
    [self.controlView.timeLabel setText:[NSString stringWithFormat:@"%@",self.videoPlayer.time.stringValue]];
    
}

#pragma mark ControlView
- (void)controlViewFingerMoveLeftWithTime:(int)intSec {
    
    [self.videoPlayer jumpBackward:intSec];
    
}

- (void)controlViewFingerMoveRightWithTime:(int)intSec {

    [self.videoPlayer jumpForward:intSec];
}
- (int)currentPlayTimeSecond {
    return [XTOOLS timeStrToSecWithStr:self.videoPlayer.time.stringValue];
}
- (int)allPlayTimeSecond {
  return [XTOOLS timeStrToSecWithStr:kMediaLength.stringValue];
}
- (void)controlViewFingerMoveUp {
    
    self.controlView.volumeSlider.value += 0.05;
}

- (void)controlViewFingerMoveDown {
    
    self.controlView.volumeSlider.value -= 0.05;
}

#pragma mark - Property
- (VideoAudioPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [VideoAudioPlayer defaultPlayer];
        _videoPlayer.isVideo = YES;
        _videoPlayer.playerDelegate = self;
        _playRate = 1.0;
    }
    return _videoPlayer;
}

- (MRVideoControlView *)controlView {
    if (!_controlView) {
        _controlView = [[MRVideoControlView alloc] initWithFrame:self.bounds];
        _controlView.delegate = self;
    }
    return _controlView;
}


- (void)setIsFullscreenModel:(BOOL)isFullscreenModel {
    if (_isFullscreenModel!=isFullscreenModel) {
        if (isFullscreenModel) {
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            if (IsPad) {
                
                //如果选择了放大，以前是小的就放大。
                CGFloat height = kScreen_Width;
                CGFloat width = kScreen_Height;
                CGRect frame = CGRectMake(0, 0, width, height);
                [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
//                    self.frame = frame;
//                    CGFloat pi =-M_PI_2;
//                    if (self.isLeft) {
//                        pi = M_PI_2;
//                    }
//                    self.transform = CGAffineTransformMakeRotation(pi);
                    //            }
                    self.controlView.frame = frame;
                    self.controlView.isFullscreen = YES;
                    [self.controlView layoutIfNeeded];
                    self.controlView.fullScreenButton.hidden = YES;
                    self.controlView.shrinkScreenButton.hidden = NO;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                //如果选择了放大，以前是小的就放大。
                CGFloat height = kScreen_Width;
                CGFloat width = kScreen_Height;
                CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
                [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
                    self.frame = frame;
                    CGFloat pi =-M_PI_2;
                    if (self.isLeft) {
                        pi = M_PI_2;
                    }
                    self.transform = CGAffineTransformMakeRotation(pi);
                    //            }
                    self.controlView.frame = self.bounds;
                    self.controlView.isFullscreen = YES;
                    [self.controlView layoutIfNeeded];
                    self.controlView.fullScreenButton.hidden = YES;
                    self.controlView.shrinkScreenButton.hidden = NO;
                } completion:^(BOOL finished) {
                    
                }];
  
            }
        }else
        {
             [[UIApplication sharedApplication]setStatusBarHidden:NO];
            if (IsPad) {
                [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
                    self.transform = CGAffineTransformIdentity;
//                    self.frame = _originFrame;
                    self.controlView.frame = _originFrame;
                    self.controlView.isFullscreen = NO;
                    [self.controlView layoutIfNeeded];
                    self.controlView.fullScreenButton.hidden = NO;
                    self.controlView.shrinkScreenButton.hidden = YES;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
                    self.transform = CGAffineTransformIdentity;
                    self.frame = _originFrame;
                    self.controlView.frame = self.bounds;
                    self.controlView.isFullscreen = NO;
                    [self.controlView layoutIfNeeded];
                    self.controlView.fullScreenButton.hidden = NO;
                    self.controlView.shrinkScreenButton.hidden = YES;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
            
        }
        _isFullscreenModel = isFullscreenModel;
        
    }
    
}
- (void)setIsLeft:(BOOL)isLeft {
    if (_isLeft!= isLeft) {
        _isLeft = isLeft;
        if (self.isFullscreenModel) {
            CGFloat pi =-M_PI_2;
            if (isLeft) {
                pi = M_PI_2;
            }
            [UIView animateWithDuration:0.2 animations:^{
               self.transform = CGAffineTransformMakeRotation(pi);
            }];
           
        }
        
    }
    
}

@end
