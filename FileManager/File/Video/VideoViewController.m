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
    MRVLCPlayer *_player;
}
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!_player) {
        _player = [[MRVLCPlayer alloc] init];
        
        _player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        _player.center = self.view.center;
        _player.delegate = self;
        self.view = _player;
    }
    _player.mediaURL = [NSURL fileURLWithPath:self.videoPath];
    
}
- (void)playerCloseButton:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

}
- (BOOL)shouldAutorotate {
    
    return XTOOLS.isCanRotation;
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
