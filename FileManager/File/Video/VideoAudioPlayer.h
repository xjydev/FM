//
//  VideoAudioPlayer.h
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//音频视频播放的对象

#import <Foundation/Foundation.h>
#import <MobileVLCKit/MobileVLCKit.h>

@protocol VideoAudioPlayerDelegate <NSObject>

@optional

/**
 上一个下一个按钮是否可点。每次更换路径后判断。

 @param hidePrev 上一个是否可点
 @param hideNext 下一个是否可点
 */
- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext;

@end
@interface VideoAudioPlayer : VLCMediaPlayer
{
    BOOL   _isBegainPlay;
}
+ (instancetype)defaultPlayer;

@property (nonatomic, assign)id<VideoAudioPlayerDelegate> playerDelegate;
@property (nonatomic, copy)NSString *currentPath;
@property (nonatomic, strong)NSArray *mediaArray;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign)BOOL    isVideo;
@property (nonatomic,strong) NSMutableDictionary  *nowPlayingInfo;//锁屏时显示的内容，暂停播放时要处理速率，显示的时候要处理播放时间，改变内容的时候要改变标题等。
@property (nonatomic, assign)BOOL    isSingleCycle;

+ (void)playerRelease;
@end
