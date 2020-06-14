//
//  AudioPlayingButton.h
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioPlayingButton : UIButton
{
    NSTimer     *_buttonTimer;
    NSInteger   _currentRotateAngle;
    
//    float  _blueValue;
    float  _greenValue;
//    float  _redValue;
    
}
+ (instancetype)defaultAudioButton;
@property (nonatomic, assign)BOOL  buttonHidden;
@property (nonatomic,strong)UIImageView *topImageView;
@property (nonatomic,strong)UIViewController *viewController;

@end
