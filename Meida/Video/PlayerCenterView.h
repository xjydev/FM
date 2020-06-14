//
//  PlayerCenterView.h
//  iPhone
//
//  Created by xiaojingyuan on 4/22/15.
//  Copyright (c) 2015 优米网. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  NS_ENUM(NSInteger, PlayerCenterType)
{
    PlayerCenterTypeStop,//暂停
    PlayerCenterTypeWaiting,//等待，菊花转圈
    PlayerCenterTypeSpeedForward,//向前快进
    PlayerCenterTypeSpeedBack,//向后倒退
    PlayerCenterTypeDefaul,//默认的时候就是不显示。
    PlayerCenterTypeBright,//亮度
    PlayerCenterTypeVolume,//声音
};
@interface PlayerCenterView : UIView
{
    UILabel                 *_titleLabel;
    UIActivityIndicatorView *_activityView;
    PlayerCenterType         _playerType;
}
//中间的button，有时候就当imageview用了。
@property (strong,nonatomic)UIButton  *centerButton;
/**
 播放器中间的提升图标或按钮
 @param playertype 按钮的类型，根据这个进行显示。
 @param title  按钮下面显示 的文字，nil为空就是不显示。
 **/
- (void)ShowWithType:(PlayerCenterType)playertype Title:(NSString *)title;
- (void)hiddenPlayButton;
@end
