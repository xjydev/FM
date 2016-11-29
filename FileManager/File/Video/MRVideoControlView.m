//
//  MRVideoControl.m
//  MRVLCPlayer
//
//  Created by Maru on 16/3/8.
//  Copyright © 2016年 Alloc. All rights reserved.
//

#import "MRVideoControlView.h"

@interface MRVideoControlView ()<UIGestureRecognizerDelegate>
{
    CGPoint     _beganPoint;//开始滑动时的位置
    CGPoint     _localPoint;//滑动的实时位置。
    
    int         _forwardSec;//前进播放多少秒
}
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end
@implementation MRVideoControlView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topBar.frame             = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds)>500?MRVideoControlBarHeight-20 : MRVideoControlBarHeight);
    self.closeButton.frame        = CGRectMake(CGRectGetMinX(self.topBar.bounds), CGRectGetHeight(self.topBar.bounds)-CGRectGetHeight(self.closeButton.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
    self.topTitleLabel.frame      = CGRectMake(CGRectGetMinX(self.topBar.bounds)+CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.topBar.bounds)-CGRectGetHeight(self.closeButton.bounds), CGRectGetWidth(self.topBar.bounds)-CGRectGetWidth(self.closeButton.bounds)-10, CGRectGetHeight(self.closeButton.bounds));
    
    self.bottomBar.frame          = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - MRVideoControlBottomHeight, CGRectGetWidth(self.bounds), MRVideoControlBottomHeight);
    self.bottomLayer.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds),MRVideoControlBottomHeight - MRVideoControlBottomLayerHeight, CGRectGetWidth(self.bounds), MRVideoControlBottomLayerHeight);
    
    self.progressSlider.frame     = CGRectMake(0, 0, CGRectGetWidth(self.bounds), MRVideoControlSliderHeight);
    
    self.playButton.frame         = CGRectMake(CGRectGetMinX(self.bottomBar.bounds)+5, MRVideoControlSliderHeight, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.pauseButton.frame        = self.playButton.frame;
    self.prevButton.frame         = CGRectMake(CGRectGetMinX(self.bottomBar.bounds)+10+MRVideoBarButtonWidth, MRVideoControlSliderHeight,CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.nextButton.frame         =  CGRectMake(CGRectGetMinX(self.bottomBar.bounds)+15+2*MRVideoBarButtonWidth, MRVideoControlSliderHeight,CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    
    self.fullScreenButton.frame   = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds) - 5, self.playButton.frame.origin.y, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    self.centerView.center     = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    self.timeLabel.frame          = CGRectMake(20+3*MRVideoBarButtonWidth, CGRectGetMinY(self.playButton.frame), CGRectGetWidth(self.bottomBar.frame)-30-4*MRVideoBarButtonWidth, CGRectGetHeight(self.playButton.frame));
    
    
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}


#pragma mark - Public Method
- (void)animateHide
{
    [UIView animateWithDuration:MRVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0;
        self.bottomBar.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateShow
{
    [UIView animateWithDuration:MRVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 1;
        self.bottomBar.alpha = 1;
    } completion:^(BOOL finished) {
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:MRVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}


#pragma mark - Private Method
- (void)setupView {
    
    self.backgroundColor = [UIColor clearColor];

    [self.layer addSublayer:self.bgLayer];
    
    
    [self addSubview:self.topBar];
    [self addSubview:self.centerView];
    [self addSubview:self.bottomBar];

    [self.topBar addSubview:self.closeButton];
    [self.topBar addSubview:self.topTitleLabel];
    
    [self.bottomBar.layer addSublayer:self.bottomLayer];
    [self.bottomBar addSubview:self.timeLabel];
    [self.bottomBar addSubview:self.playButton];
    [self.bottomBar addSubview:self.pauseButton];
    [self.bottomBar addSubview:self.fullScreenButton];
    [self.bottomBar addSubview:self.shrinkScreenButton];
    [self.bottomBar addSubview:self.nextButton];
    [self.bottomBar addSubview:self.prevButton];
    [self.bottomBar addSubview:self.progressSlider];
    
    [self addGestureRecognizer:self.pan];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    
    self.pauseButton.hidden = YES;
    self.shrinkScreenButton.hidden = YES;
    
   
}


- (void)responseTapImmediately {
    self.bottomBar.alpha == 0 ? [self animateShow] : [self animateHide];
}

#pragma mark - Override
#pragma mark Touch Event

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    
//    CGPoint localPoint = [pan locationInView:self];
    //相对偏移量，和速度发现都不适合。
//    NSLog(@"==l(%f  %f)  ===s( %f  %f) ====t(%f  %f)",[pan locationInView:self].x,[pan locationInView:self].y,[pan velocityInView:self].x,[pan velocityInView:self].y,[pan translationInView:self].x,[pan translationInView:self].y);
    switch (pan.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            _beganPoint = [pan locationInView:self];
            _localPoint = _beganPoint;
            _forwardSec = 0;
            
        }
            break;
            
            
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [pan locationInView:self];
            // 判断方向45°角，向上左是亮度右是音量，水平是播放时间。
            if (fabs(currentPoint.x - _beganPoint.x) > fabs(currentPoint.y - _beganPoint.y)) {//播放时间
                if (currentPoint.x - _localPoint.x > 0) {
//                    if ([_delegate respondsToSelector:@selector(controlViewFingerMoveRightWithTime:)]) {
//                        [self.delegate controlViewFingerMoveRightWithTime:(int)(currentPoint.x - _localPoint.x)];
//                    }
                    _forwardSec = (int)(currentPoint.x - _beganPoint.x);
                    [self.centerView ShowWithType:PlayerCenterTypeSpeedForward Title:[NSString stringWithFormat:@"+ %d S",_forwardSec]];

                }else {
//                    if ([_delegate respondsToSelector:@selector(controlViewFingerMoveLeftWithTime:)]) {
//                        [self.delegate controlViewFingerMoveLeftWithTime:(int)(currentPoint.x - _localPoint.x)];
//                    }
                    _forwardSec = (int)(currentPoint.x - _beganPoint.x);
                    [self.centerView ShowWithType:PlayerCenterTypeSpeedBack Title:[NSString stringWithFormat:@"- %d S",-_forwardSec]];

                }
            }else {
                
                if (_beganPoint.x > self.bounds.size.width / 2) {
                    // 改变音量
                    self.volumeSlider.value += -(currentPoint.y - _localPoint.y)*0.002;

                    [self.centerView ShowWithType:PlayerCenterTypeVolume Title:[NSString stringWithFormat:@"音量:%d%%",(int)(self.volumeSlider.value * 100)]];
                }else {
                    // 改变显示亮度
                    [UIScreen mainScreen].brightness +=  -(currentPoint.y - _localPoint.y)*0.002;
                    [self.centerView ShowWithType:PlayerCenterTypeBright Title:[NSString stringWithFormat:@"亮度:%d%%",(int)([UIScreen mainScreen].brightness * 100)]];
                }
            }
            
            _localPoint = currentPoint;
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            [self panEndBegainPlay];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{

                }];
            });
        }
            break;
        default:
            break;
    }
}
- (void)panEndBegainPlay {
    if (_forwardSec >0) {
        if ([_delegate respondsToSelector:@selector(controlViewFingerMoveRightWithTime:)]) {
            [self.delegate controlViewFingerMoveRightWithTime:_forwardSec];
        }
    }
    else
        if (_forwardSec<0) {
            if ([_delegate respondsToSelector:@selector(controlViewFingerMoveLeftWithTime:)]) {
                [self.delegate controlViewFingerMoveLeftWithTime:-_forwardSec];
            }
        }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.tapCount > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self responseTapImmediately];
        });

    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self responseTapImmediately];
}

#pragma mark - Property

- (PlayerCenterView *)centerView {
    if (!_centerView) {
        _centerView = [[PlayerCenterView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _centerView.backgroundColor = MRRGB(60, 60, 60,0.8);
//        _centerView.bounds = CGRectMake(0, 0, 100, 100);
    }
    return _centerView;
}
- (UIView *)topBar
{
    if (!_topBar) {
        _topBar = [[UIView alloc]init];
        _topBar.backgroundColor = MRRGB(60, 60, 60,0.8);
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc]init];
        _bottomBar.backgroundColor = [UIColor clearColor];
    }
    return _bottomBar;
}
- (CALayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CALayer layer];
        _bottomLayer.backgroundColor = MRRGB(60, 60, 60,0.8).CGColor;
        
    }
    return _bottomLayer;
}
- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"playing"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _playButton;
}

- (UIButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"play_pause"] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"play_full"] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton
{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"play_shrink"] forState:UIControlStateNormal];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"play_shrink_d"] forState:UIControlStateDisabled];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _shrinkScreenButton;
}
- (UIButton *)prevButton
{
    if (!_prevButton) {
        _prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prevButton setImage:[UIImage imageNamed:@"play_prev"] forState:UIControlStateNormal];
         [_prevButton setImage:[UIImage imageNamed:@"play_prev_d"] forState:UIControlStateDisabled];
        _prevButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _prevButton;
}
- (UIButton *)nextButton
{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"play_next"] forState:UIControlStateNormal];
        _nextButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _nextButton;
}


- (MRProgressSlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[MRProgressSlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"play_progress"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"play_progress_h"] forState:UIControlStateHighlighted];
        [_progressSlider setMinimumTrackTintColor:MRRGB(255, 255, 255,1)];
        [_progressSlider setMaximumTrackTintColor:MRRGB(157, 157, 157,1)];
        [_progressSlider setBackgroundColor:[UIColor clearColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"play_close"] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, MRVideoBarButtonWidth, MRVideoBarButtonWidth);
    }
    return _closeButton;
}
- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MRVideoControlBarHeight, MRVideoControlBarHeight)];
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _topTitleLabel;
}
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:MRVideoControlTimeLabelFontSize];
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, 100, MRVideoBarButtonWidth);
    }
    return _timeLabel;
}

- (CALayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [CALayer layer];
        _bgLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Video Bg"]].CGColor;
        _bgLayer.bounds = self.frame;
        _bgLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    }
    return _bgLayer;
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        for (UIControl *view in self.volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                _volumeSlider = (UISlider *)view;
            }
        }
    }
    return _volumeSlider;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
    }
    return _volumeView;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _pan.delegate = self;
    }
    return _pan;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if([touch.view isKindOfClass:[UISlider class]])
        
    {
        
        return NO;
        
    }else{
        
        return YES;
        
    }
}
@end

@implementation MRProgressSlider
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, self.bounds.size.height * 0.8, self.bounds.size.width, MRProgressWidth);
}

@end

