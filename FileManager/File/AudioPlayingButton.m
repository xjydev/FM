//
//  AudioPlayingButton.m
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "AudioPlayingButton.h"
#import "XTools.h"
#import "AppDelegate.h"
#import "AudioViewController.h"
static AudioPlayingButton *_audioButton = nil;
@implementation AudioPlayingButton
+ (instancetype)defaultAudioButton {
    if (!_audioButton) {
        _audioButton = [AudioPlayingButton buttonWithType:UIButtonTypeCustom];
        _audioButton.frame = CGRectMake(kScreen_Width - 54, kScreen_Height - 100, 44, 44);
        _audioButton.backgroundColor = [UIColor clearColor];
        [_audioButton setImage:[UIImage imageNamed:@"music_playing"] forState:UIControlStateNormal];
        [_audioButton addTarget:_audioButton action:@selector(showAudioDetail:) forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow addSubview:_audioButton];
    }
    return _audioButton;
}
- (void)setButtonHidden:(BOOL)buttonHidden {
    if (buttonHidden) {
        if (_buttonTimer) {
            [_buttonTimer invalidate];
            _buttonTimer = nil;
        }
    }
    else
    {
        _currentRotateAngle = 0;
        _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(buttonRotate) userInfo:nil repeats:YES];
    }
   
    _buttonHidden = buttonHidden;
     _audioButton.hidden = _buttonHidden;
}
- (void)buttonRotate {
    _currentRotateAngle ++;
    _audioButton.transform = CGAffineTransformMakeRotation(M_PI/20.0*(_currentRotateAngle%40));
}
- (void)showAudioDetail:(AudioPlayingButton *)button {
    button.buttonHidden = YES;
    AudioViewController *audio = [[UIApplication sharedApplication].keyWindow.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:audio animated:YES completion:^{
        
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
