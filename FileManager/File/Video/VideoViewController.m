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
@interface VideoViewController ()
{
    MRVLCPlayer *_player;
}
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
   }
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    XTOOLS.isCanRotation = !XTOOLS.isCanRotation;
    if (!_player) {
        _player = [[MRVLCPlayer alloc] init];
        
        _player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        _player.center = self.view.center;
        //    player.mediaURL = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"wmv"];
        _player.mediaURL = [NSURL fileURLWithPath:self.videoPath];
        //    [NSURL URLWithString:self.videoPath];
        //    player.mediaURL = [NSURL fileURLWithPath:@"/Users/Maru/Documents/Media/Movie/1.mkv"];
        
        [_player showInView:self.view];
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
