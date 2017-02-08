//
//  AudioViewController.m
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "AudioViewController.h"
#import "VideoAudioPlayer.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "XTools.h"
#import "AudioPlayingButton.h"
#import "MoveFilesView.h"
#import "UMMobClick/MobClick.h"
@interface AudioViewController ()<VideoAudioPlayerDelegate>
{
    
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UIButton *_bigPlayButton;
    __weak IBOutlet UISlider *_playProgress;
    __weak IBOutlet UILabel *_playTime;
    __weak IBOutlet UIButton *_preButton;
    __weak IBOutlet UIButton *_playButton;
    __weak IBOutlet UIButton *_nextButton;
    __weak IBOutlet UIButton *_cycleButton;
    __weak IBOutlet UIButton *_listButton;
    
    BOOL                      _isDrag;//拖拽的时候，进度条不要随动了。
    NSTimer                  *_audioTimer;
    NSInteger                 _currentRotateAngle;
    
}
@property (nonatomic,strong) VideoAudioPlayer *player;

@end

@implementation AudioViewController

- (VideoAudioPlayer *)player {
    if (!_player) {
        _player =[VideoAudioPlayer defaultPlayer];
        _player.isVideo = NO;
    }
    return _player;
}
- (void)setAudioArray:(NSArray *)audioArray index:(NSInteger)index {
    self.audioArray = audioArray;
    self.index = index;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.player.playerDelegate) {
        self.player.playerDelegate = self;
    }
    
    if (self.audioPath) {
        self.player.currentPath = self.audioPath;
    }
    else
        if (self.audioArray.count>0) {
            self.player.mediaArray = self.audioArray;
            self.player.index = self.index;
        }
    _listButton.hidden = self.audioArray.count ==0;
    
}

- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext {
    _preButton.enabled = hidePrev;
    _nextButton.enabled = hideNext;
    _titleLabel.text = [self.player.currentPath lastPathComponent];
    [self.player play];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   [AudioPlayingButton defaultAudioButton].buttonHidden = YES;
    if (self.player.isPlaying) {
        [self audioPlayStart];
        _titleLabel.text = [self.player.currentPath lastPathComponent];
    }
    else
    {
       [self.player play];
    }
    [MobClick beginLogPageView:@"audio"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"audio"];
}
//关闭返回
- (IBAction)closeButtonAction:(id)sender {
    self.player.playerDelegate = nil;
    if (self.player.isPlaying) {
        [AudioPlayingButton defaultAudioButton].buttonHidden = NO;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (!self.player.playing) {
            [VideoAudioPlayer playerRelease];
            
        }
    }];
}
- (IBAction)bigButtonAction:(id)sender {
    if (self.player.isPlaying) {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
    
}
- (IBAction)preButtonAction:(id)sender {
    self.player.index = self.player.index - 1;
}
- (IBAction)playButtonAction:(id)sender {
    if (self.player.isPlaying) {
        [self.player pause];
    }
    else
    {
        
        if (self.player.state == VLCMediaPlayerStateStopped) {
            self.player.currentPath = self.player.currentPath;
        }
        else
        {
          [self.player play];
        }
        
    }
}
- (IBAction)nextButtonAction:(id)sender {
    self.player.index = self.player.index +1;
}
- (IBAction)playProgressStart:(id)sender {
    _isDrag = YES;
}
- (IBAction)playProgressChangeAction:(id)sender {
}
- (IBAction)playProgressEndAction:(id)sender {
    _isDrag = NO;
    int targetIntvalue = (int)(_playProgress.value * [self.player.media.length.value floatValue]);
    
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue];
    if (self.player.state == VLCMediaPlayerStateStopped) {
       self.player.currentPath = self.player.currentPath;
        [self performSelector:@selector(setNowCurrentTime:) withObject:targetTime afterDelay:0.1];
    }
    else
    {
        
    }
    
    [self.player setTime:targetTime];
}
- (void)setNowCurrentTime:(VLCTime *)time {
    [self.player setTime:time];
    
}
- (IBAction)cycleButtonAction:(id)sender {
    if (self.player.isSingleCycle) {
        self.player.isSingleCycle = NO;
        [_cycleButton setImage:[UIImage imageNamed:@"cycle"] forState:UIControlStateNormal];
        [XTOOLS showMessage:@"循环播放"];
    }
    else
    {
        self.player.isSingleCycle = YES;
        [_cycleButton setImage:[UIImage imageNamed:@"singleCycle"] forState:UIControlStateNormal];
        [XTOOLS showMessage:@"单曲循环"];
    }
}
- (IBAction)listButtonAction:(id)sender {
    MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
    
    [fileView showWithFolderArray:self.player.mediaArray withTitle:@"音频列表" backBlock:^(NSString *movePath, NSInteger index) {
        self.player.index = index;
    }];
}

#pragma mark -- VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
//    VLCMediaPlayerStateStopped,        ///< Player has stopped
//    VLCMediaPlayerStateOpening,        ///< Stream is opening
//    VLCMediaPlayerStateBuffering,      ///< Stream is buffering
//    VLCMediaPlayerStateEnded,          ///< Stream has ended
//    VLCMediaPlayerStateError,          ///< Player has generated an error
//    VLCMediaPlayerStatePlaying,        ///< Stream is playing
//    VLCMediaPlayerStatePaused          ///< Stream is paused
    NSLog(@"state == %@ == %@",@(self.player.state),@(self.player.media.state));
    switch (self.player.state) {
        case VLCMediaPlayerStateStopped:
        {
            if (self.player.media.state == VLCMediaStateNothingSpecial) {
                [self audioPlayPaused];
//                self.player.index +=1;
            }
           
           
        }
            break;
        case VLCMediaPlayerStateBuffering:
        {
            if (self.player.media.state == VLCMediaStatePlaying ) {
              [self audioPlayStart];
            }
            
        }
            break;
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStateError:
        {
            [self audioPlayPaused];
//            self.player.index +=1;
            
        }
            break;
        case VLCMediaPlayerStatePlaying:
        {
            [self audioPlayStart];
            
        }
            break;
        case VLCMediaPlayerStatePaused:
        {
            [self audioPlayPaused];
        }
            break;
            
        default:
            break;
    }
//    VLCMediaStateNothingSpecial,        ///< Nothing
//    VLCMediaStateBuffering,             ///< Stream is buffering
//    VLCMediaStatePlaying,               ///< Stream is playing
//    VLCMediaStateError,
    
}
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    //    NSLog(@"2===%@",aNotification);
    if (!_isDrag) {
        float precentValue = ([self.player.time.value floatValue]) / ([self.player.media.length.value floatValue]);
        [_playProgress setValue:precentValue animated:YES];
    }
    _playTime.text = [NSString stringWithFormat:@"%@/%@",self.player.time.stringValue,self.player.media.length.stringValue];
    //设置播放的时间
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    NSLog(@"3===%@",aNotification);
}

#pragma mark -- 暂停播放，播放图标变化，开始旋转
- (void)audioPlayPaused {
    [_playButton setImage:[UIImage imageNamed:@"play_middle"] forState:UIControlStateNormal];
    if (_audioTimer) {
        [_audioTimer invalidate];
        _audioTimer = nil;
    }
}
#pragma Mark - 开始播放,
- (void)audioPlayStart {
    [_playButton setImage:[UIImage imageNamed:@"pause_middle"] forState:UIControlStateNormal];
    if (!_audioTimer) {
        _currentRotateAngle = 0;
        _audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioImageRotate) userInfo:nil repeats:YES];
        
    }
}
- (void)audioImageRotate {
    _currentRotateAngle ++;
    _bigPlayButton.transform = CGAffineTransformMakeRotation(M_PI/20.0*(_currentRotateAngle%40));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
