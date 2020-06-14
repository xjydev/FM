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
#import "NewVideoViewController.h"
#import "UIColor+Hex.h"
#import "VideoAudioPlayer.h"
static AudioPlayingButton *_audioButton = nil;
@interface AudioPlayingButton ()
@property(nonatomic,assign)UIEdgeInsets safeInsets;
@end;
@implementation AudioPlayingButton
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 44, 44)];
        
        [self addSubview:_topImageView];
    }
    return _topImageView;
}

+ (instancetype)defaultAudioButton {
    if (!_audioButton) {
        _audioButton = [AudioPlayingButton buttonWithType:UIButtonTypeCustom];
        float btx = [kUSerD floatForKey:@"audiobtx"];
        float bty = [kUSerD floatForKey:@"audiobty"];
        if (btx == 0 && bty == 0) {
          _audioButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 55, [UIScreen mainScreen].bounds.size.height - 104, 50, 50);
        }
        else
        {
          _audioButton.frame = CGRectMake(btx- 25, bty - 25, 50, 50);
        }
        
        _audioButton.layer.cornerRadius = 5;
        _audioButton.layer.masksToBounds = YES;
        _audioButton.userInteractionEnabled = YES;
        _audioButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _audioButton.layer.borderWidth = 0.5;
        _audioButton.backgroundColor =[UIColor colorWithWhite:0.9 alpha:0.3];
        _audioButton.topImageView.image = [UIImage imageNamed:@"music_playing"];
        [_audioButton addTarget:_audioButton action:@selector(showAudioDetail:) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_audioButton action:@selector(doMoveAction:)];
        [_audioButton addGestureRecognizer:panGestureRecognizer];
        
        [[UIApplication sharedApplication].keyWindow addSubview:_audioButton];
        if (kDevice_Is_iPhoneX) {
           _audioButton.safeInsets = UIEdgeInsetsMake(88, 0, 83, 0);
        }
        else
        {
            _audioButton.safeInsets = UIEdgeInsetsMake(64, 0, 49, 0);
        }
        
        
    }
    return _audioButton;
}
- (void)setButtonHidden:(BOOL)buttonHidden {
    if (buttonHidden) {
        if (_buttonTimer) {
            [_buttonTimer invalidate];
            _buttonTimer = nil;
        }
        self.viewController = nil;
    }
    else
    {
        _currentRotateAngle = 0;
        _buttonTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(buttonRotate) userInfo:nil repeats:YES];
    }
   
    _buttonHidden = buttonHidden;
     self.hidden = _buttonHidden;
}
- (void)buttonRotate {
    _currentRotateAngle ++;
    self.topImageView.transform = CGAffineTransformMakeRotation(M_PI/20.0*(_currentRotateAngle%40));
    
    int num = _currentRotateAngle%100;
    if (num<50) {
       _greenValue = _currentRotateAngle%50*0.02;
    }
    else
    {
       _greenValue =1.0 - _currentRotateAngle%50*0.02;
    }
    
    self.topImageView.tintColor = [UIColor colorWithRed:0 green:_greenValue blue:1.0 alpha:1.0];
}
- (void)showAudioDetail:(AudioPlayingButton *)button {
    button.buttonHidden = YES;
    if (self.viewController) {
        self.viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.viewController animated:YES completion:^{
            
        }];
        return;
    }
    if ([XTOOLS fileFormatWithPath:[VideoAudioPlayer defaultPlayer].currentPath] == FileTypeVideo) {
        
        NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
        video.modalPresentationStyle = UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:video animated:YES completion:^{
            
        }];
    }
    else
    {
        AudioViewController *audio = [AudioViewController allocFromStoryBoard];
        audio.modalPresentationStyle = UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:audio animated:YES completion:^{
            
        }];
    }
   
}
- (UIImage *)drawRadialGradientstartColor:(UIColor*)startColor
                  endColor:(UIColor*)endColor
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGMutablePathRef path = CGPathCreateMutable();
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0,0.7, 0.8,1.0 };
    
    NSArray *colors = @[(__bridge id) [UIColor ora_colorWithHex:0xf7f7f7].CGColor, (__bridge id) [UIColor ora_colorWithHex:0x666666].CGColor, (__bridge id) [UIColor clearColor].CGColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
//    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint center = CGPointMake(25,25);
    CGFloat radius = 50;
//    MAX(pathRect.size.width / 2.0, pathRect.size.height / 2.0) * sqrt(2);
    
    CGContextSaveGState(context);
//    CGContextAddPath(context, path);
    CGContextEOClip(context);
    
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (void)doMoveAction:(UIPanGestureRecognizer *)recognizer
{
    
    
        //1、手势在self.view坐标系中移动的位置
        CGPoint translation = [recognizer translationInView:self.superview];
        CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x,
                                        recognizer.view.center.y + translation.y);
        
        //2、限制屏幕范围：
        
        //上边界的限制
        newCenter.y = MAX(recognizer.view.frame.size.height/2 + self.safeInsets.top, newCenter.y);
        
        //下边界的限制
        newCenter.y = MIN(self.superview.frame.size.height- recognizer.view.frame.size.height/2 - self.safeInsets.bottom, newCenter.y);
        
        //左边界的限制
        newCenter.x = MAX(recognizer.view.frame.size.width/2, newCenter.x);
        
        //右边界的限制
        newCenter.x = MIN(self.superview.frame.size.width - recognizer.view.frame.size.width/2,newCenter.x);
        
        //设置中心点范围
        recognizer.view.center = newCenter;
        //3、将手势坐标点归0、否则会累加
        [recognizer setTranslation:CGPointZero inView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [kUSerD setFloat:recognizer.view.center.x forKey:@"audiobtx"];
        [kUSerD setFloat:recognizer.view.center.y forKey:@"audiobty"];
        [kUSerD synchronize];
    }
   
}
@end
