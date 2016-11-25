//
//  VideoViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//
#import "XTools.h"
#import "VideoViewController.h"
#import "MRVLCPlayer.h"
@interface VideoViewController ()<MRVLCPlayerDelegate>
{
    NSArray   *_videoArray;
    NSInteger  _videoIndex;
    MRVLCPlayer *_player;
    PrevNextType _playPrevNextType;
}
@end

@implementation VideoViewController
- (void)setVideoPath:(NSString *)videoPath {
    _playPrevNextType = PrevNextTypeAll;
    _videoPath = videoPath;
}
- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index {
    _videoArray = videoArray;
    _videoIndex = index;
    if (videoArray.count== 0) {
        _playPrevNextType = PrevNextTypeAll;
        return;
    }
    if (_videoIndex == 0) {
        _playPrevNextType = PrevNextTypePrev;
        self.videoPath = _videoArray[_videoIndex];
        
    }
    else if (_videoIndex >0 && _videoIndex<_videoArray.count-1) {
        _playPrevNextType = PrevNextTypeNext;
      self.videoPath = _videoArray[_videoIndex];  
    }
    else
    if(_videoIndex == _videoArray.count - 1){
       _playPrevNextType = PrevNextTypeNext;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!_player) {
        _player = [[MRVLCPlayer alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
//        _player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        _player.center = self.view.center;
        _player.delegate = self;
        self.view = _player;
    }
    if (self.videoPath) {
       _player.mediaURL = [NSURL fileURLWithPath:self.videoPath];
        _player.prevNextType = _playPrevNextType;
    }
    else
    {
        NSLog(@"播放路径错误");
    }
    
    
}
- (void)playerCloseButton:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)playerNextPrevButtonIsNext:(BOOL)isNext {
    _player.mediaURL = [NSURL fileURLWithPath:self.videoPath];
    _player.prevNextType = _playPrevNextType;
    [_player play];
}
- (void)playerStateEnd {
    _player.mediaURL = [NSURL fileURLWithPath:self.videoPath];
    _player.prevNextType = _playPrevNextType;
    [_player play];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    if (_player) {
        [_player play];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    XTOOLS.isCanRotation = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];

}
- (BOOL)shouldAutorotate {
    
    return XTOOLS.isCanRotation;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    XTOOLS.isCanRotation = NO;
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
