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
}
+ (instancetype)defaultAudioButton;
@property (nonatomic, assign)BOOL  buttonHidden;
@end
