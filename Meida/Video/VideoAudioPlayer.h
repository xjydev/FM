//
//  VideoAudioPlayer.h
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//音频视频播放的对象

#import <Foundation/Foundation.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , XPlayModelType) {
    XPlayModelTypeCycle,//循环播放，默认
    XPlayModelTypeSingle,//单曲循环
    XPlayModelTypeRandom,//随机播放
};

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

+ (instancetype)defaultPlayer;

@property (nonatomic, weak)id<VideoAudioPlayerDelegate> playerDelegate;
@property (nonatomic, copy)NSString *currentPath;
@property (nonatomic, strong)NSArray *mediaArray;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign)BOOL    isVideo;
@property (nonatomic, assign)BOOL    notSetStartTime;//不初始化初始播放时间
@property (nonatomic,strong) NSMutableDictionary  *nowPlayingInfo;//锁屏时显示的内容，暂停播放时要处理速率，显示的时候要处理播放时间，改变内容的时候要改变标题等。
@property (nonatomic, assign)XPlayModelType    playModelType;
@property (nonatomic, assign)int backTime;//非手动暂停的时候，开始播放会向后跳几秒。

@property (nonatomic, strong)NSDate   *stopDate;//定时关机时间；

@property (nonatomic, strong)UIImage  *mediaImage;

+ (void)playerRelease;

@end
