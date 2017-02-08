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
#import "UMMobClick/MobClick.h"
@interface VideoViewController ()<MRVLCPlayerDelegate>
{
    NSArray   *_videoArray;
    NSInteger  _videoIndex;
}
@property (nonatomic, strong)MRVLCPlayer *player;
@end

@implementation VideoViewController

- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index {
    _videoArray = videoArray;
    _videoIndex = index;
}
- (MRVLCPlayer *)player {
    if (!_player) {
        _player =[[MRVLCPlayer alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        if (!_player.delegate) {
            _player.delegate = self;
        }
    }
    return _player;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.player.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.player.center = self.view.center;
    
    self.view = self.player;
    if (self.videoPath) {
        self.player.videoPlayer.currentPath = self.videoPath;
    }
    else
    {
        self.player.videoPlayer.mediaArray = _videoArray;
        self.player.videoPlayer.index = _videoIndex;
    }
    
    
}
- (void)playerCloseButton:(UIButton *)button {
    
    [self dismissViewControllerAnimated:YES completion:^{
       [VideoAudioPlayer playerRelease];
       [self.player removeFromSuperview];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    XTOOLS.isCanRotation = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [MobClick endLogPageView:@"video"];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"video"];//("PageOne"为页面名称，可自定义)
}
- (BOOL)shouldAutorotate {
    
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

    
    return NO;
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
