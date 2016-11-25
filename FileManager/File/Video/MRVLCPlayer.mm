//
//  MRVLCPlayer.m
//  MRVLCPlayer
//
//  Created by apple on 16/3/5.
//  Copyright © 2016年 Alloc. All rights reserved.
//

#import "MRVLCPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MRVideoConst.h"
#import "XTools.h"

static const NSTimeInterval kVideoPlayerAnimationTimeinterval = 0.3f;

@interface MRVLCPlayer ()
{
    CGRect _originFrame;
}
@property (nonatomic,strong) VLCMediaPlayer *player;
@property (nonatomic, nonnull,strong) MRVideoControlView *controlView;
@end

@implementation MRVLCPlayer

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _originFrame = frame;
        [self setupNotification];
        
    }
    return self;
}
- (void)setPrevNextType:(PrevNextType)prevNextType {
    _prevNextType = prevNextType;
    switch (_prevNextType) {
        case PrevNextTypePrev:
        {
            self.controlView.prevButton.enabled = NO;
            self.controlView.nextButton.enabled = YES;
        }
            break;
        case PrevNextTypeNext:
        {
            self.controlView.prevButton.enabled = YES;
            self.controlView.nextButton.enabled = NO;
            
        }
            break;
        case PrevNextTypeAll:
        {
            self.controlView.prevButton.enabled = NO;
            self.controlView.nextButton.enabled = NO;
        }
            break;
            
        default:
        {
            self.controlView.prevButton.enabled = YES;
            self.controlView.nextButton.enabled = YES;
        }
            break;
    }
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self setupPlayer];
    
    [self setupView];
    
    [self setupControlView];
}


#pragma mark - Public Method
- (void)showInView:(UIView *)view {
    
    NSAssert(_mediaURL != nil, @"MRVLCPlayer Exception: mediaURL could not be nil!");
    
    [view addSubview:self];
    
    self.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self play];
    }];
}

- (void)dismiss {
    [self.player stop];
    self.player.delegate = nil;
    self.player.drawable = nil;
    self.player = nil;
    
    // 注销通知
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeFromSuperview];
}

#pragma mark - Private Method
- (void)setupView {
    [self setBackgroundColor:[UIColor blackColor]];
}

- (void)setupPlayer {
    [self.player setDrawable:self];
    self.player.media = [[VLCMedia alloc] initWithURL:self.mediaURL];
}

- (void)setupControlView {

    [self addSubview:self.controlView];
    
    //添加控制界面的监听方法
    [self.controlView.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlView.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.prevButton addTarget:self action:@selector(prevNextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.nextButton addTarget:self action:@selector(prevNextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.progressSlider addTarget:self action:@selector(progressClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView.progressSlider addTarget:self action:@selector(progressChange) forControlEvents:UIControlEventValueChanged];
    [self.controlView.progressSlider addTarget:self action:@selector(progressTouchDown) forControlEvents:UIControlEventTouchDown];
}
- (void)prevNextButtonAction:(UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(playerNextPrevButtonIsNext:)]) {
        [self.player stop];
        [self.delegate playerNextPrevButtonIsNext:button == self.controlView.nextButton];
    }
}
- (void)setupNotification {
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [UIApplication sharedApplication].statusBarOrientation
    //监听转屏
    if (XTOOLS.isCanRotation) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationHandler)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil
         ];//UIDeviceOrientationDidChangeNotification
  
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
//    NSLog(@"0==%@",@([UIDevice currentDevice].orientation));
    //UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight|| [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        self.isFullscreenModel = YES;
        
    }else//UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait|| [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            self.isFullscreenModel = NO;
        }

    [self.controlView autoFadeOutControlBar];
}

/**
 *    即将进入后台的处理
 */
- (void)applicationWillEnterForeground {
    
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:[self.player.time.value floatValue]-2];
    [self.player setTime:targetTime];
    
    [self play];
}

/**
 *    即将返回前台的处理
 */
- (void)applicationWillResignActive {
    [self pause];
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
    if (XTOOLS.isCanRotation) {
       [self forceChangeOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    else
    {
        self.isFullscreenModel = YES;
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
    }
   

}

- (void)shrinkScreenButtonClick {
    if (XTOOLS.isCanRotation) {
      [self forceChangeOrientation:UIInterfaceOrientationPortrait];
    }
    else
    {
        self.isFullscreenModel = NO;
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
    }
    
}

- (void)progressClick {

    int targetIntvalue = (int)(self.controlView.progressSlider.value * (float)kMediaLength.intValue);
    
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue];
    
    [self.player setTime:targetTime];
    
    [self.controlView autoFadeOutControlBar];
}
- (void)progressChange {
    
}
- (void)progressTouchDown {
    [self.controlView cancelAutoFadeOutControlBar];
}
#pragma mark Player Logic
- (void)play {
    self.controlView.topTitleLabel.text =[_mediaURL.absoluteString lastPathComponent];
    NSAssert(_mediaURL != nil, @"MRVLCPlayer Exception: mediaURL could not be nil!");
    [self.player play];
    self.controlView.playButton.hidden = YES;
    self.controlView.pauseButton.hidden = NO;
    [self.controlView autoFadeOutControlBar];
}

- (void)pause {
    [self.player pause];
    self.controlView.playButton.hidden = NO;
    self.controlView.pauseButton.hidden = YES;
    [self.controlView autoFadeOutControlBar];
}

- (void)stop {
    [self.player stop];
    self.controlView.progressSlider.value = 1;
    self.controlView.playButton.hidden = NO;
    self.controlView.pauseButton.hidden = YES;
}

#pragma mark - Delegate
#pragma mark VLC
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    // Every Time change the state,The VLC will draw video layer on this layer.
    [self bringSubviewToFront:self.controlView];
    if (self.player.media.state == VLCMediaStateBuffering) {
        self.controlView.indicatorView.hidden = NO;
        self.controlView.bgLayer.hidden = NO;
    }else if (self.player.media.state == VLCMediaStatePlaying) {
        self.controlView.indicatorView.hidden = YES;
        self.controlView.bgLayer.hidden = YES;
    }else if (self.player.state == VLCMediaPlayerStateStopped) {
        [self stop];
        if (self.player.media.state == VLCMediaStateNothingSpecial) {
            NSLog(@"111=== play end ===");
            if ([self.delegate respondsToSelector:@selector(playerStateEnd)]) {
                [self.delegate playerStateEnd];
            }
        }
        
    }
    else {
        self.controlView.indicatorView.hidden = NO;
        self.controlView.bgLayer.hidden = NO;
    }
    
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    
    [self bringSubviewToFront:self.controlView];
    
    if (self.controlView.progressSlider.state != UIControlStateNormal) {
        return;
    }
    
    float precentValue = ([self.player.time.value floatValue]) / ([kMediaLength.value floatValue]);
    
    [self.controlView.progressSlider setValue:precentValue animated:YES];
    
    [self.controlView.timeLabel setText:[NSString stringWithFormat:@"%@/%@",_player.time.stringValue,kMediaLength.stringValue]];
}

#pragma mark ControlView
- (void)controlViewFingerMoveLeft {
    
    [self.player shortJumpBackward];
    
}

- (void)controlViewFingerMoveRight {

    [self.player shortJumpForward];
    
}

- (void)controlViewFingerMoveUp {
    
    self.controlView.volumeSlider.value += 0.05;
}

- (void)controlViewFingerMoveDown {
    
    self.controlView.volumeSlider.value -= 0.05;
}

#pragma mark - Property
- (VLCMediaPlayer *)player {
    if (!_player) {
        _player = [[VLCMediaPlayer alloc] init];
        _player.delegate = self;
    }
    return _player;
}

- (MRVideoControlView *)controlView {
    if (!_controlView) {
        _controlView = [[MRVideoControlView alloc] initWithFrame:self.bounds];
        _controlView.delegate = self;
    }
    return _controlView;
}


- (void)setIsFullscreenModel:(BOOL)isFullscreenModel {
    
//    if (_isFullscreenModel == isFullscreenModel) {
//        return;
//    }
    
    _isFullscreenModel = isFullscreenModel;
    
    if (isFullscreenModel) {
//        _originFrame = self.frame;
        
        CGFloat height = kMRSCREEN_BOUNDS.size.width;
        CGFloat width = kMRSCREEN_BOUNDS.size.height;
        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
        [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
            /**
             *    此判断是为了适配项目在Deployment Info中是否勾选了横屏
             */
           
            if (XTOOLS.isCanRotation) {
//                NSLog(@"00 ===%@",@([UIApplication sharedApplication].statusBarOrientation));
                if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
//                    self.frame = frame;
                    self.frame = kMRSCREEN_BOUNDS;
                    
//                    NSLog(@"111===%@ ===%@",@(self.frame.size.width) ,@([UIApplication sharedApplication].statusBarOrientation));
                }else
                    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                        self.frame = kMRSCREEN_BOUNDS;
//                        self.transform = CGAffineTransformMakeRotation(M_PI);
//                         NSLog(@"222===%@ ===%@",@(self.frame.size.width) ,@([UIApplication sharedApplication].statusBarOrientation));
                    }
            }
            else
            {
                self.frame = frame;
                self.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
            self.controlView.frame = self.bounds;
            [self.controlView layoutIfNeeded];
            self.controlView.fullScreenButton.hidden = YES;
            self.controlView.shrinkScreenButton.hidden = NO;
        } completion:^(BOOL finished) {
//         NSLog(@"++++++++++++++ %@",@([UIApplication sharedApplication].statusBarOrientation));
        }];
        
    }else {
        [UIView animateWithDuration:kVideoPlayerAnimationTimeinterval animations:^{
            self.transform = CGAffineTransformIdentity;
            self.frame = _originFrame;
            self.controlView.frame = self.bounds;
            [self.controlView layoutIfNeeded];
            self.controlView.fullScreenButton.hidden = NO;
            self.controlView.shrinkScreenButton.hidden = YES;
            
        } completion:^(BOOL finished) {
//            NSLog(@"============= %@",@([UIApplication sharedApplication].statusBarOrientation));
        }];

        
    }

}


@end
