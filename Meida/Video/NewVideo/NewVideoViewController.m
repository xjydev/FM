//
//  NewVideoViewController.m
//  FileManager
//
//  Created by XiaoDev on 15/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "NewVideoViewController.h"
#import "NewPlayerView.h"
#import "VideoAudioPlayer.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import "AudioPlayingButton.h"
#import "PickerArrayController.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "CaptionViewController.h"

@interface NewVideoViewController ()<VideoAudioPlayerDelegate,VLCMediaPlayerDelegate,VLCMediaPlayerDelegate,NewPlayerViewDelegate,UIPopoverPresentationControllerDelegate,VLCMediaThumbnailerDelegate>
{
    NSArray   *_videoArray;
    NSInteger  _videoIndex;
//    NewPlayerView *_playerView;
    UIInterfaceOrientationMask _lockMask;
    BOOL   _hiddenStatus;
   
}
@property (weak, nonatomic) IBOutlet NewPlayerView *playerView;

//@property (nonatomic, strong)MPVolumeView *volumeView;

@property (nonatomic, strong)VideoAudioPlayer *videoPlayer;
@end

@implementation NewVideoViewController

+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    NewVideoViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"NewVideoViewController"];
    return VC;
}

#pragma mark - Property

- (VideoAudioPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [VideoAudioPlayer defaultPlayer];
        if (!_videoPlayer.isPlaying) {//如果没有正在播放就设置为视频，不然就原来的状态
           _videoPlayer.isVideo = YES;
            _videoPlayer.playModelType = XPlayModelTypeCycle;
        }
        else
            if ([XTOOLS fileFormatWithPath:_videoPlayer.currentPath]== FileTypeAudio) {//如果正在播放的是视频文件，切换到视频状态。
              _videoPlayer.isVideo = YES;
            }
       
        _videoPlayer.playerDelegate = self;
        _videoPlayer.delegate = self;
//        _playRate = 1.0;
    }
    return _videoPlayer;
}

- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index {
    _videoArray = videoArray;
    _videoIndex = index;
}

/**
 获取到视频同级别路径下所有视频，及此视频的位置

 @return 是否包含
 */
- (BOOL)getVideoArrayCurrentPath {
    if (self.videoPath.length >0) {//如果有地址就用这个地址
//        if (![self.videoPath hasPrefix:KDocumentP]) {
//            self.videoPath = [KDocumentP stringByAppendingPathComponent:self.videoPath];
//        }
        NSString *frontPath = [self.videoPath substringToIndex:(self.videoPath.length - self.videoPath.lastPathComponent.length)];
        NSError *error;
        NSArray *array;
        if ([frontPath hasPrefix:KDocumentP]) {
            array = [kFileM subpathsOfDirectoryAtPath:frontPath error:&error];
        }
        else
        {
            array = [kFileM subpathsOfDirectoryAtPath:[KDocumentP stringByAppendingPathComponent:frontPath] error:&error];
        }
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
        NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
            return (NSComparisonResult)[obj1 compare:obj2 options:comparisonOptions];
            
        }];
        NSMutableArray *aArray = [NSMutableArray arrayWithCapacity:marry.count];
        for (NSString *name in marry) {
            if ([XTOOLS fileFormatWithPath:name] == FileTypeVideo) {
                [aArray addObject:[frontPath stringByAppendingPathComponent:name]];
            }
        }
        
        _videoArray = aArray;
        
        _videoIndex = [_videoArray indexOfObject:self.videoPath];
        
        return YES;
    }
    return NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    NSInteger status = [kUSerD integerForKey:@"krotatestatus"];
    NSLog(@"open status == %@",@(status));
    if (status != 0) {
        [_playerView rotateScreenWithStatus:status];
    }
    if (IsPad) {
        _playerView.frame = self.view.bounds;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
    NSLog(@"end status == %@",@(self.playerView.rotateStatus));
    [kUSerD setInteger:self.playerView.rotateStatus forKey:@"krotatestatus"];
    [kUSerD synchronize];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [XTOOLS umengClick:@"newvideo"];
//    _playerView = [[NewPlayerView alloc]initWithFrame:self.view.bounds];
    self.playerView.playerViewdelegate = self;
//    [self.view addSubview:_playerView];
    
    [self.videoPlayer setDrawable:self.playerView.contentView];
    if (!self.videoPlayer.isVideo) {//如果不是视频，就是在听视频。
        _playerView.listenVideo = YES;
        [_playerView.totalTimeLabel setText:[NSString stringWithFormat:@"%@",self.videoPlayer.media.length.stringValue]];
        [self.videoPlayer play];
    }
    
    if (_videoArray.count >0) {
        self.videoPlayer.mediaArray = _videoArray;
        self.videoPlayer.index = _videoIndex;
    }
    else
        if (self.videoPath) {
            self.videoPlayer.currentPath = self.videoPath;
        }
    
    
    [_playerView.closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.listenButton addTarget:self action:@selector(listenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.prevButton addTarget:self action:@selector(prevButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.rateButton addTarget:self action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.ratioButton addTarget:self action:@selector(ratioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_playerView.progressSlider addTarget:self action:@selector(progressSliderClick) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.progressSlider addTarget:self action:@selector(progressSliderChange:) forControlEvents:UIControlEventValueChanged];
    [_playerView.progressSlider addTarget:self action:@selector(progressSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    
    [_playerView.captionButton addTarget:self action:@selector(captionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.screenShotButton addTarget:self action:@selector(screenShotButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.lockButton addTarget:self action:@selector(lockButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.cycleButton addTarget:self action:@selector(cycleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_playerView autoFadeOutControlBar];//初始化后开始计时隐藏
    
}
#pragma mark -- 按钮事件
//字幕
- (void)captionButtonAction:(UIButton *)button {
    [XTOOLS umengClick:@"videoCaption"];
    [_playerView autoFadeOutControlBar];
    CaptionViewController *captionVC = [CaptionViewController allocFromStoryBoard];
    captionVC.delayTime = _videoPlayer.currentVideoSubTitleDelay;
    captionVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    captionVC.subTitleArray = _videoPlayer.videoSubTitlesNames;
    NSLog(@"==%@\n==%@",_videoPlayer.videoSubTitlesNames,_videoPlayer.videoSubTitlesIndexes);
    captionVC.popoverPresentationController.backgroundColor = [UIColor clearColor];
    captionVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    captionVC.captionSelectCompletion = ^(int time, NSObject *subTitleObject) {
        if (time!=0) {
            self->_videoPlayer.currentVideoSubTitleDelay = time;
        }
        if ([subTitleObject isKindOfClass:[NSString class]]) {
            NSString *filePath = (NSString *)subTitleObject;
            if (![filePath hasPrefix:KDocumentP]) {
                filePath = [KDocumentP stringByAppendingPathComponent:filePath];
            }
            int subInt = [self->_videoPlayer addPlaybackSlave:[NSURL URLWithString:filePath] type:VLCMediaPlaybackSlaveTypeSubtitle enforce:YES];
            if (subInt>0) {
               [XTOOLS showMessage:@"添加成功"];
            }
            else
            {
                [XTOOLS showMessage:@"添加失败"];
            }
            NSLog(@"subtitle ==%d",subInt);
        }
        else
            if ([subTitleObject isKindOfClass:[NSNumber class]]) {
                NSNumber *subTitleNumber = (NSNumber *)subTitleObject;
                self->_videoPlayer.currentVideoSubTitleIndex = [subTitleNumber intValue];
            }
    };
    [self presentViewController:captionVC animated:YES completion:^{
        
    }];
}
//截屏
- (void)screenShotButtonAction:(UIButton *)button {
    [XTOOLS umengClick:@"videoScreenShot"];
    if (_videoPlayer.media.length.value.doubleValue>0) {
        VLCMedia *m = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_videoPlayer.currentPath]];
        VLCMediaThumbnailer *thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:m andDelegate:self];
        thumbnailer.thumbnailHeight = _videoPlayer.videoSize.height;
        thumbnailer.thumbnailWidth = _videoPlayer.videoSize.width;
        thumbnailer.snapshotPosition =  _videoPlayer.time.value.doubleValue/_videoPlayer.media.length.value.doubleValue;;
        [thumbnailer fetchThumbnail];
        button.enabled = NO;
        [_playerView.screenShotIndicatorView startAnimating];
    }
    
}
//锁
- (void)lockButtonAction:(UIButton *)button {
    [XTOOLS umengClick:@"videoLock"];
    button.selected = !button.selected;
    _playerView.lockView = button.selected;
    
}
- (void)cycleButtonAction:(UIButton *)button {
    [XTOOLS umengClick:@"videocycle"];
    button.selected = !button.isSelected;
    if (button.isSelected) {
        self.videoPlayer.playModelType = XPlayModelTypeSingle;
        [XTOOLS showMessage:@"单个循环"];
    }
    else {
        self.videoPlayer.playModelType = XPlayModelTypeCycle;
        [XTOOLS showMessage:@"顺序播放"];
    }
}
- (void)closeButtonAction {
    if (self.videoPlayer.isVideo) {
        
        [VideoAudioPlayer playerRelease];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        
        if (self.videoPlayer.isPlaying) {
            [AudioPlayingButton defaultAudioButton].buttonHidden = NO;
            [AudioPlayingButton defaultAudioButton].viewController = self;
        }
        else
        {
            self.videoPlayer.playerDelegate = nil;
            self.videoPlayer.delegate = nil;
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if (!self.videoPlayer.playing) {
                [VideoAudioPlayer playerRelease];
                
            }
            
        }];
    }
   
}
- (void)listenButtonAction:(UIButton *)button {
   
    if (_playerView.listenVideo) {
        _playerView.listenVideo = NO;
        [button setImage:[UIImage imageNamed:@"video_listen"] forState:UIControlStateNormal];
        self.videoPlayer.isVideo = YES;
        [_playerView autoFadeOutControlBar];
    }
    else
    {
         [XTOOLS umengClick:@"videoListen"];
        _playerView.listenVideo = YES;
        self.videoPlayer.isVideo = NO; 
        [button setImage:[UIImage imageNamed:@"video_look"] forState:UIControlStateNormal];
        [_playerView cancelAutoFadeOutControlBar];
    }
    
}
- (void)nextButtonAction {
    [XTOOLS umengClick:@"next"];
    [self.videoPlayer pause];
//    self.videoPlayer.notSetStartTime = YES;
     self.videoPlayer.index +=1;
//    [_playerView autoFadeOutControlBar];
}
- (void)prevButtonAction {
    [XTOOLS umengClick:@"prev"];
    [self.videoPlayer pause];
//    self.videoPlayer.notSetStartTime = YES;
    self.videoPlayer.index -=1;
//    [_playerView autoFadeOutControlBar];
}
- (void)rateButtonAction:(UIButton *)button {
  [_playerView autoFadeOutControlBar];
    [XTOOLS umengClick:@"rate"];
    PickerArrayController *pickerArr = [PickerArrayController pickerControllerFromStroyboardType:1];
    pickerArr.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    pickerArr.modalPresentationStyle = UIModalPresentationPopover;
    pickerArr.preferredContentSize = CGSizeMake(80, 150);
    pickerArr.popoverPresentationController.sourceView = button;
    pickerArr.popoverPresentationController.sourceRect =button.bounds;
 pickerArr.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    pickerArr.popoverPresentationController.delegate = self;
    pickerArr.pickerArrayBlock = ^(NSNumber *num,NSString *str) {
        [self.videoPlayer setRate:num.floatValue];
        [button setTitle:[NSString stringWithFormat:@"X%@",num] forState:UIControlStateNormal];
    };
    [self presentViewController:pickerArr animated:YES completion:^{
        
    }];
}

- (void)ratioButtonAction:(UIButton *)button {
  [_playerView autoFadeOutControlBar];
    [XTOOLS umengClick:@"ratio"];
    PickerArrayController *pickerArr = [PickerArrayController pickerControllerFromStroyboardType:3];

    pickerArr.modalPresentationStyle = UIModalPresentationPopover;
    pickerArr.preferredContentSize = CGSizeMake(80, 150);
    pickerArr.popoverPresentationController.sourceView = button;
    pickerArr.popoverPresentationController.sourceRect =button.bounds;
    pickerArr.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    pickerArr.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    pickerArr.popoverPresentationController.delegate = self;
    pickerArr.pickerArrayBlock = ^(NSNumber *num,NSString *str) {
        self.videoPlayer.videoAspectRatio = (char *)[str UTF8String];
        NSString *ratiostr = str;
        if ([str isEqualToString:@"DEFAULT"]) {
            ratiostr = @"默认";
        }
        else
            if ([str isEqualToString:@"FILL_TO_SCREEN"]) {
                ratiostr = @"满屏";
            }
        [button setTitle:ratiostr forState:UIControlStateNormal];

    };
    [self presentViewController:pickerArr animated:YES completion:^{

    }];

}
- (void)progressSliderClick {
    int targetIntvalue = (int)(_playerView.progressSlider.value * (float)self.videoPlayer.media.length.intValue);
    
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue];
    
    [self.videoPlayer setTime:targetTime];
    
  [_playerView autoFadeOutControlBar];
}
- (void)progressSliderChange:(UISlider *)slider {
    int targetIntvalue = (int)(slider.value * self.videoPlayer.media.length.intValue)/1000;
    if (targetIntvalue/3600>0) {
        [_playerView.timeLabel setText:[NSString stringWithFormat:@"%d:%02d:%02d",targetIntvalue/3600,(targetIntvalue%3600)/60,targetIntvalue%60]];
    }
    else
    {
        [_playerView.timeLabel setText:[NSString stringWithFormat:@"%02d:%02d",(targetIntvalue%3600)/60,targetIntvalue%60]];
    }
  [_playerView autoFadeOutControlBar];
}
- (void)progressSliderTouchDown {
 [_playerView autoFadeOutControlBar];
}
#pragma mark -- newPlayerview delegate
- (void)playerViewPlayorPauseMedia {
    if (self.videoPlayer.isPlaying) {
        [self.videoPlayer pause];
//        [_playerView cancelAutoFadeOutControlBar];
    }
    else
    {
        [self.videoPlayer play];
        if (self.videoPlayer.time.intValue >= self.videoPlayer.media.length.intValue - 2000) {//如果差两秒，点击播放就重新播放
            self.videoPlayer.currentPath = self.videoPlayer.currentPath;
            [self.videoPlayer play];
        }
        else
        {
            if (self.videoPlayer.backTime >0) {
                [self.videoPlayer jumpBackward:self.videoPlayer.backTime];
                self.videoPlayer.backTime = 0;
            }
        }
        
//        [_playerView autoFadeOutControlBar];
    }
}
- (void)playerViewForwardSeconds:(int)second {
    int targetIntvalue = (int)(self.videoPlayer.time.intValue)/1000+second;
    NSString * timeStr = nil;
    targetIntvalue = MIN(targetIntvalue, self.videoPlayer.media.length.intValue/1000-2);
    targetIntvalue = MAX(targetIntvalue, 0);
    if (targetIntvalue/3600>0) {//大于一个小时
       timeStr = [NSString stringWithFormat:@"%d:%02d:%02d",targetIntvalue/3600,(targetIntvalue%3600)/60,targetIntvalue%60];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"%02d:%02d",(targetIntvalue%3600)/60,targetIntvalue%60];
    }
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ / %@",timeStr,_playerView.totalTimeLabel.text] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];//colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f
    [att setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:kMainCOLOR} range:NSMakeRange(0, timeStr.length +1)];
   [_playerView.centerView forwardSeconds:(targetIntvalue - (int)(self.videoPlayer.time.intValue)/1000) withShowString:att];
}
- (void)playerViewDidJumpFormard:(int)second {
    
    int nowInt = -(int)self.videoPlayer.time.intValue/1000;
    int residueInt = (int)self.videoPlayer.media.length.intValue/1000 +nowInt-2 ;
    if (second < nowInt) {
        second = nowInt;
    }
    else
        if (second > residueInt) {
            second = residueInt;
        }
    
    if (second>0) {
        [self.videoPlayer jumpForward:second];
    }
    else
    {
        [self.videoPlayer jumpBackward:abs(second)];
    }
}
#pragma mark -- 截图代理
- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
  NSString * name =[NSString stringWithFormat:@"%@截图%@.png", [[self.videoPlayer.currentPath lastPathComponent]stringByDeletingPathExtension],_videoPlayer.time.stringValue];
    NSString *imageFile = [KDocumentP stringByAppendingPathComponent:name];
    UIImage *pimage = [UIImage imageWithCGImage:thumbnail];
    NSData *imageDate = UIImagePNGRepresentation(pimage);
    [imageDate writeToFile:imageFile atomically:YES];
    [XTOOLS umengClick:@"videoScShots"];
    if ([kUSerD boolForKey:@"kthumbanail"]) {
       [XTOOLS showMessage:@"截图成功"];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"截图成功" message:@"请在首页“图片”中查看截图" preferredStyle:UIAlertControllerStyleAlert];
        
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [kUSerD setBool:YES forKey:@"kthumbanail"];
                [kUSerD synchronize];
            }];
            [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
       
    }
    
    _playerView.screenShotButton.enabled = YES;
    [_playerView.screenShotIndicatorView stopAnimating];
}
- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    [_playerView.screenShotIndicatorView stopAnimating];
    _playerView.screenShotButton.enabled = YES;
    [XTOOLS showMessage:@"截图失败"];
    NSLog(@"截图失败");
}
#pragma mark VLC delegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    NSLog(@"playstatus delegate==%@ == %@",@(self.videoPlayer.media.state),@(self.videoPlayer.state));
    if (self.videoPlayer.media.state == VLCMediaStatePlaying) {
        if (self.videoPlayer.state == VLCMediaPlayerStatePaused) {//暂停
            [_playerView pauseStatus];
            
        }
        else
        {
            [_playerView playStatus];
        }
       
    }
    else
    {
        if (self.videoPlayer.media.state == VLCMediaStateNothingSpecial && self.videoPlayer.state == VLCMediaPlayerStateStopped) {//如果发生错误,并且已经停止
            
            if ([self.videoPlayer.currentPath.pathExtension isEqualToString:@"swf"]) {
                NSLog(@"swf === %@ %@",@(self.videoPlayer.state),@(self.videoPlayer.media.state));
                [self dismissViewControllerAnimated:YES completion:^{
                  [XTOOLS showAlertTitle:@"此文件可能不是视频文件" message:@"应用只支持swf格式的视频文件，你可以把此文件拖入到安装有flash插件的浏览器，进行浏览查看。" buttonTitles:@[@"确定"] completionHandler:nil];
                }];
            }
            else {
              [_playerView pauseStatus];
            }
        }
        else {
            [_playerView pauseStatus];
        }
        
    }
    
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    
    if (![_playerView.totalTimeLabel.text isEqualToString:self.videoPlayer.media.length.stringValue]) {
      [_playerView.totalTimeLabel setText:self.videoPlayer.media.length.stringValue];
    }
    
    if (_playerView.progressSlider.state != UIControlStateNormal) {//非操作状态下才可以
        return;
    }
    
    float precentValue = ([self.videoPlayer.time.value floatValue]) / ([self.videoPlayer.media.length.value floatValue]);
    
    [_playerView.progressSlider setValue:precentValue animated:YES];
    
    [_playerView.timeLabel setText:[NSString stringWithFormat:@"%@",self.videoPlayer.time.stringValue]];
    
}
- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext {
    _playerView.prevButton.enabled = hidePrev;
    _playerView.nextButton.enabled = hideNext;
    _playerView.titleLabel.text =[self.videoPlayer.currentPath lastPathComponent];
}
- (void)playerViewWillShowOrHidden:(BOOL)ishidden {
    _hiddenStatus = ishidden;
    [self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark --旋转
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return YES;
//}

- (BOOL)shouldAutorotate
{
    return !_playerView.lockView;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    
    return _hiddenStatus;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}
- (BOOL)prefersHomeIndicatorAutoHidden{
    
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

- (void)dealloc {
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
