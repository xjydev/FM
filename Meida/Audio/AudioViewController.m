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
#import "UIColor+Hex.h"
#import "PickerArrayController.h"
#import "AudioVolumeViewController.h"

@interface AudioViewController ()<VideoAudioPlayerDelegate,VLCMediaPlayerDelegate,UIPopoverPresentationControllerDelegate>
{
    
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UIImageView *_backImageView;
    __weak IBOutlet UIVisualEffectView *_backBlurView;
    __weak IBOutlet UIButton *_bigPlayButton;
    __weak IBOutlet UISlider *_playProgress;
    __weak IBOutlet UILabel *_playTime;
    __weak IBOutlet UILabel *_mediaTimeLabel;
    __weak IBOutlet UILabel *_playNameLabel;
    __weak IBOutlet UIButton *_preButton;
    __weak IBOutlet UIButton *_playButton;
    __weak IBOutlet UIButton *_nextButton;
    __weak IBOutlet UIButton *_cycleButton;
    __weak IBOutlet UIButton *_listButton;
    __weak IBOutlet UILabel *_timingLabel;
    
    
    BOOL                      _isDrag;//拖拽的时候，进度条不要随动了。
    NSTimer                  *_audioTimer;
    NSInteger                 _currentRotateAngle;
    NSString                 *_frontPath;
    
    __weak IBOutlet NSLayoutConstraint *_headerViewHeight;
    __weak IBOutlet NSLayoutConstraint *_bottomViewHeight;
}
@property (nonatomic,strong) VideoAudioPlayer *player;

@end

@implementation AudioViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    AudioViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"AudioViewController"];
    return VC;
}
- (VideoAudioPlayer *)player {
    if (!_player) {
        _player =[VideoAudioPlayer defaultPlayer];
        _player.isVideo = NO;
        _player.playModelType = [[kUSerD objectForKey:@"xplaymodeltype"]integerValue];
    }
    return _player;
}
- (void)setAudioArray:(NSArray *)audioArray index:(NSInteger)index {
    self.audioArray = audioArray;
    self.index = index;
    
}
//获取当前路径下的所有音频文件
- (void)getAudioArrayCurrentPath {
    if (self.audioPath.length >0) {
        NSString *cpath = [self.audioPath substringToIndex:(self.audioPath.length - self.audioPath.lastPathComponent.length)];
        NSError *error;
        NSArray *array;
        if ([cpath hasPrefix:KDocumentP]) {
            _frontPath = [cpath substringFromIndex:KDocumentP.length];
            array = [kFileM subpathsOfDirectoryAtPath:cpath error:&error];
        }
        else
        {
            _frontPath = cpath;
            array = [kFileM subpathsOfDirectoryAtPath:[KDocumentP stringByAppendingPathComponent:cpath] error:&error];
        }
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
        NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
            return (NSComparisonResult)[obj1 compare:obj2 options:comparisonOptions];
            
        }];
        NSMutableArray *aArray = [NSMutableArray arrayWithCapacity:marry.count];
        for (NSString *name in marry) {
            if ([XTOOLS fileFormatWithPath:name] == FileTypeAudio) {
                [aArray addObject:[_frontPath stringByAppendingPathComponent:name]];
            }
        }
        
        NSInteger indexAudo = NSNotFound;
        if ([self.audioPath hasPrefix:KDocumentP]) {
            NSString *apath = [self.audioPath substringFromIndex:KDocumentP.length];;
            indexAudo = [aArray indexOfObject:apath];
        }
        else {
            indexAudo = [aArray indexOfObject:self.audioPath];
        }
        if (indexAudo!= NSNotFound) {
            self.audioArray = aArray;
            self.index = indexAudo;
        }
    }
    
    NSLog(@"audio ==%@ ==%@",self.audioArray,@(self.index));
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [XTOOLS umengClick:@"audio"];
    if (kDevice_Is_iPhoneX) {
        _headerViewHeight.constant = 64+30;
        _bottomViewHeight.constant = 84;
    }
    _bigPlayButton.layer.cornerRadius = _bigPlayButton.frame.size.width/2;
    _bigPlayButton.layer.masksToBounds = YES;
    _bigPlayButton.layer.borderWidth = 5;
    _bigPlayButton.layer.borderColor = [UIColor whiteColor].CGColor;
    if (self.player.playerDelegate == nil) {
        self.player.playerDelegate = self;
    }
    if (self.player.delegate == nil) {
        self.player.delegate = self;
    }
    
    
    
    if (self.audioArray.count>0) {
        self.player.mediaArray = self.audioArray;
        self.player.index = self.index;
    }
    else
        if (self.audioPath) {
            self.player.currentPath = self.audioPath;
            
        }
    _listButton.hidden = self.player.mediaArray.count ==0;
    [self changeBackImageView];
    //初始化播放类型，循环播放按钮初始化
    if (self.player.playModelType == XPlayModelTypeRandom) {
      [_cycleButton setImage:[UIImage imageNamed:@"audio_random"] forState:UIControlStateNormal];
    }
    else
        if (self.player.playModelType == XPlayModelTypeSingle) {
            [_cycleButton setImage:[UIImage imageNamed:@"singleCycle"] forState:UIControlStateNormal];
        }
    
}
- (void)changeBackImageView {

    [_bigPlayButton setImage:self.player.mediaImage forState:UIControlStateNormal];
    [_backImageView setImage:self.player.mediaImage];
}
#pragma mark -- 渐变色
- (void)setGradualColor {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor ora_colorWithHex:0x0000ff].CGColor, (__bridge id)[UIColor ora_colorWithHex:0x1d67f1].CGColor];
    gradientLayer.locations = @[@0.4, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
//    [self.view.layer addSublayer:gradientLayer];
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}
- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext {
    _preButton.enabled = hidePrev;
    _nextButton.enabled = hideNext;
    _playNameLabel.text = [self.player.currentPath lastPathComponent];
    [self changeBackImageView];
    [self.player play];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
   [AudioPlayingButton defaultAudioButton].buttonHidden = YES;
    if (self.player.isPlaying) {
        [self audioPlayStart];
        _playNameLabel.text = [self.player.currentPath lastPathComponent];
    }
    else
    {
       [self.player play];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.player.stopDate) {
        NSString *timestr = [XTOOLS hmtimeStrFromDate:self.player.stopDate];
        self->_timingLabel.text = timestr;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)dealloc {
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
}
- (IBAction)volumeButtonAction:(UIButton *)sender {
    AudioVolumeViewController *VC = [AudioVolumeViewController allocFromeStoryBoard];
    
    VC.modalPresentationStyle = UIModalPresentationPopover;
    VC.preferredContentSize = CGSizeMake(200, 100);
    VC.popoverPresentationController.delegate = self;
    VC.popoverPresentationController.sourceView = sender;
    VC.popoverPresentationController.sourceRect =sender.bounds;
    VC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    VC.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    [self presentViewController:VC animated:YES completion:^{
        
    }];
}
//关闭返回
- (IBAction)closeButtonAction:(id)sender {
    self.player.playerDelegate = nil;
    self.player.delegate = nil;
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
    else {
        [self.player play];
    }
}
- (IBAction)rateButtonAction:(UIButton *)sender {
    PickerArrayController *pickerArr = [PickerArrayController pickerControllerFromStroyboardType:1];
    
    pickerArr.modalPresentationStyle = UIModalPresentationPopover;
    pickerArr.preferredContentSize = CGSizeMake(80, 150);
    pickerArr.popoverPresentationController.delegate = self;
    pickerArr.popoverPresentationController.sourceView = sender;
    pickerArr.popoverPresentationController.sourceRect =sender.bounds;
 pickerArr.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
    pickerArr.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    pickerArr.pickerArrayBlock = ^(NSNumber *num,NSString *str) {
       [self.player setRate:num.floatValue];
        [sender setTitle:[NSString stringWithFormat:@"X%.1f",num.floatValue] forState:UIControlStateNormal];
    };
    [self presentViewController:pickerArr animated:YES completion:^{
        
    }];
}
- (IBAction)pre15sButtonAction:(id)sender {
    [XTOOLS umengClick:@"pre15s"];
    int targetIntvalue = self.player.time.intValue;
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue - 15000];
    [self.player setTime:targetTime];
}
- (IBAction)next15sButtonAction:(id)sender {
    [XTOOLS umengClick:@"next15s"];
    int targetIntvalue = self.player.time.intValue;
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue + 15000];
    [self.player setTime:targetTime];
}
- (IBAction)timingButtonAction:(UIButton *)sender {
    [XTOOLS umengClick:@"timing"];
    PickerArrayController *pickerArr = [PickerArrayController pickerControllerFromStroyboardType:2];
    pickerArr.modalPresentationStyle = UIModalPresentationPopover;
    pickerArr.preferredContentSize = CGSizeMake(80, 150);
    pickerArr.popoverPresentationController.delegate = self;
    pickerArr.popoverPresentationController.sourceView = sender;
    pickerArr.popoverPresentationController.sourceRect = sender.bounds;
 pickerArr.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionRight;
    pickerArr.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    pickerArr.pickerArrayBlock = ^(NSNumber *num,NSString *str) {
        NSDate *timeDate = [NSDate dateWithTimeInterval:num.integerValue *60 sinceDate:[NSDate date]];
        self.player.stopDate = timeDate;
        NSString *timestr = [XTOOLS hmtimeStrFromDate:timeDate];
        //        [sender setTitle:timestr forState:UIControlStateNormal];
        self->_timingLabel.text = timestr;
    };
    [self presentViewController:pickerArr animated:YES completion:^{
        
    }];
    
}
- (IBAction)preButtonAction:(id)sender {
//    self.player.notSetStartTime = YES;
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
//    self.player.notSetStartTime = YES;
    self.player.index = self.player.index +1;
}
- (IBAction)playProgressStart:(id)sender {
    _isDrag = YES;
}
- (IBAction)playProgressChangeAction:(UISlider *)sender {
    int targetIntvalue = (int)(sender.value * self.player.media.length.intValue)/1000;
    if (targetIntvalue/3600>0) {
        [_playTime setText:[NSString stringWithFormat:@"%d:%02d:%02d",targetIntvalue/3600,(targetIntvalue%3600)/60,targetIntvalue%60]];
    }
    else
    {
        [_playTime setText:[NSString stringWithFormat:@"%02d:%02d",(targetIntvalue%3600)/60,targetIntvalue%60]];
    }
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
    if (self.player.playModelType == XPlayModelTypeCycle) {
        self.player.playModelType = XPlayModelTypeSingle;
        [_cycleButton setImage:[UIImage imageNamed:@"singleCycle"] forState:UIControlStateNormal];
        [XTOOLS showMessage:@"单曲循环"];
        
    }
    else
        if (self.player.playModelType == XPlayModelTypeSingle) {
            self.player.playModelType = XPlayModelTypeRandom;
            [_cycleButton setImage:[UIImage imageNamed:@"audio_random"] forState:UIControlStateNormal];
            [XTOOLS showMessage:@"随机播放"];
        }
        else
        {
            self.player.playModelType = XPlayModelTypeCycle;
            [_cycleButton setImage:[UIImage imageNamed:@"cycle"] forState:UIControlStateNormal];
            [XTOOLS showMessage:@"循环播放"];
            
        }
    [kUSerD setObject:[NSNumber numberWithInteger:self.player.playModelType] forKey:@"xplaymodeltype"];
    [kUSerD synchronize];
}
- (IBAction)listButtonAction:(id)sender {
    [XTOOLS umengClick:@"listenlist"];
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
        _playTime.text =self.player.time.stringValue;
        _mediaTimeLabel.text = self.player.media.length.stringValue;
    }
    
    //设置播放的时间
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    NSLog(@"3===%@",aNotification);
}

#pragma mark -- 暂停播放，播放图标变化，开始旋转
- (void)audioPlayPaused {
//    if ([XTOOLS showAdview] ) {
//        self.nativeExpressAdView.hidden = NO;
//    }
    
    [_playButton setImage:[UIImage imageNamed:@"play_middle"] forState:UIControlStateNormal];
    if (_audioTimer) {
        [_audioTimer invalidate];
        _audioTimer = nil;
    }
}
#pragma Mark - 开始播放,
- (void)audioPlayStart {
//    self.nativeExpressAdView.hidden = YES;
    [_playButton setImage:[UIImage imageNamed:@"pause_middle"] forState:UIControlStateNormal];
    if (!_audioTimer) {
        _currentRotateAngle = 0;
        _audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioImageRotate) userInfo:nil repeats:YES];
        
    }
}
- (void)audioImageRotate {
    _currentRotateAngle ++;
    _bigPlayButton.transform = CGAffineTransformMakeRotation(M_PI/30.0*(_currentRotateAngle%60));
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IsPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL )shouldAutorotate {
    return YES;
}
#pragma mark -- UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
