//
//  VideoAudioPlayer.m
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "VideoAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "XTools.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XManageCoreData.h"
#import "AudioPlayingButton.h"

static VideoAudioPlayer *_player = nil;
@implementation VideoAudioPlayer
+ (instancetype)defaultPlayer {
    if (!_player) {
        _player = [[VideoAudioPlayer alloc]init];
        
        //播放即创建远程控制
        [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
        [[UIApplication sharedApplication]becomeFirstResponder];

        [kNOtificationC addObserver:_player selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        [kNOtificationC addObserver:_player selector:@selector(playerStateChanged:) name:VLCMediaPlayerStateChanged object:_player];
        [kNOtificationC addObserver:_player selector:@selector(playerTimeChanged:) name:VLCMediaPlayerTimeChanged object:_player];
    }
    return _player;
}

+(void)playerRelease {
    //
    if (_player.isVideo && [XTOOLS timeStrToSecWithStr:_player.time.stringValue]<[XTOOLS timeStrToSecWithStr:_player.media.length.stringValue]-10) {
      [[XManageCoreData manageCoreData]saveRecordName:[_player.media.metaDictionary objectForKey:VLCMetaInformationTitle]  path:_player.currentPath record:[XTOOLS timeStrToSecWithStr:_player.time.stringValue]];
    }
    
    //对象release关闭远程控制
    if (!_player.isVideo) {
        [[UIApplication sharedApplication]resignFirstResponder];
        [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
        [AudioPlayingButton defaultAudioButton].buttonHidden = YES;
    }
    
    [kNOtificationC removeObserver:_player];
    [_player stop];
    _player.playerDelegate = nil;
    _player.delegate = nil;
    _player = nil;
    [XTOOLS gotoAppStoreComment];
}
#pragma mark -- 监听
- (void)handleInterreption:(NSNotification *)sender {
    if(_player.isPlaying)
    {
        [_player pause];
       
    }
    else
    {
        [_player play];

    }
}
- (void)playerStateChanged:(NSNotification *)notifi {
    NSLog(@"notifi======%@",notifi);
    switch (_player.state) {
        case VLCMediaPlayerStateStopped:
        {
            if (_player.media.state == VLCMediaStateNothingSpecial) {
                //如果单曲循环就重新播放，不然就下一首
                if (self.isSingleCycle) {
                     self.currentPath = self.currentPath;
                }
                else
                {
                    if (self.mediaArray.count>0) {
                      self.index +=1;
                    }
                  
                }
                
            }
        }
            break;
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStateError:
        {
            if (self.isSingleCycle) {
                 self.currentPath = self.currentPath;
            }
            else
            {
                if (self.mediaArray.count>0) {
                  self.index +=1;
                }
                
            }
            
        }
            break;
        case VLCMediaPlayerStatePlaying:
        {
            if (!self.isVideo) {
               [self.nowPlayingInfo setValue:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            }
           
        }
            break;
        case VLCMediaPlayerStatePaused:
        {
            if (!self.isVideo) {
                [self.nowPlayingInfo setValue:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.nowPlayingInfo];
            }
            
        }
            break;
        default:
            break;
    }
}
- (void)playerTimeChanged:(NSNotification *)notifi {
    if (!self.isVideo) {
        [self.nowPlayingInfo setValue:@([XTOOLS timeStrToSecWithStr:_player.media.length.stringValue]) forKey:MPMediaItemPropertyPlaybackDuration];
        [self.nowPlayingInfo setValue:@([XTOOLS timeStrToSecWithStr:_player.time.stringValue]) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.nowPlayingInfo];
    }
    
}
- (void)setPlayerDelegate:(id<VideoAudioPlayerDelegate>)playerDelegate {
    _player.delegate = (id)playerDelegate;
    _playerDelegate = playerDelegate;
}
- (void)setMediaArray:(NSArray *)mediaArray {
    _mediaArray = mediaArray;
}
- (void)setIndex:(NSInteger)index {
    if (self.mediaArray.count>0) {
        if (index>=0 && index<self.mediaArray.count) {
            _index = index;
            
        }
        else
        {
            _index = 0;
        }
        self.currentPath = self.mediaArray[_index];
    }
    else
    {
//        self.currentPath = self.currentPath;
    }
    
}
- (void)setCurrentPath:(NSString *)currentPath {
    
    if (currentPath == nil) {
        return;
    }
    if (![currentPath hasPrefix:KDocumentP]) {
        currentPath = [NSString stringWithFormat:@"%@/%@",KDocumentP,currentPath];
    }
    
    _currentPath = currentPath;
    BOOL isPrev = NO;
    BOOL isNext = NO;
    if (self.mediaArray.count>1) {
        if (self.index == 0) {
            isPrev = NO;
            isNext = YES;
        }
        else
            if (self.index >0 && self.index < self.mediaArray.count-1) {
                isPrev = YES;
                isNext = YES;
            }
        else
            if (self.index == self.mediaArray.count - 1) {
                isPrev = YES;
                isNext = NO;
                
            }
    }
    
    if (_player&&[NSURL fileURLWithPath:_currentPath] != _player.media.url) {
        _player.media = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_currentPath]];
        if (!self.isVideo) {
          [self reloadNowPlayInfo];
        }
        _isBegainPlay = YES;
       
        [_player play];
        if (_player.isVideo) {
          [self performSelector:@selector(setPlayTime) withObject:nil afterDelay:0.1];
        }
        
        
    }
    
    if ([self.playerDelegate respondsToSelector:@selector(playerHidePrev:HideNext:) ]) {
        [self.playerDelegate playerHidePrev:isPrev HideNext:isNext];
    }
}
- (void)setIsVideo:(BOOL)isVideo {
    _isVideo = isVideo;
    if (_isVideo) {//如果是视频就隐藏音乐的播放按钮
       [AudioPlayingButton defaultAudioButton].buttonHidden = YES;
    }
}
- (void)setPlayTime {
    float num = [[XManageCoreData manageCoreData]getRecordWithPath:_currentPath];
    NSLog(@"progress == %@",@(num));
    if (num>0) {
        [_player jumpForward:num];
    }
}
- (NSMutableDictionary *)nowPlayingInfo {
    if (!_nowPlayingInfo) {
      _nowPlayingInfo = [[NSMutableDictionary alloc]init];
    }
    return _nowPlayingInfo;
}
#pragma mark -- 锁屏后显示的信息
//刷新锁屏内容。
- (void)reloadNowPlayInfo {
    UIImage *artWorkImage = [_player.media.metaDictionary objectForKey:VLCMetaInformationArtwork];
    if (!artWorkImage) {
        artWorkImage = [UIImage imageNamed:@"music"];
    }
    NSString *title = [_player.media.metaDictionary objectForKey:VLCMetaInformationTitle];
    if (!title) {
        title = _player.currentPath.lastPathComponent;
    }
    NSString *artistName = [_player.media.metaDictionary objectForKey:VLCMetaInformationArtist];
    if (!artistName) {
        artistName = @"";
    }
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:artWorkImage];
    
    [self.nowPlayingInfo setValue:title forKey:MPMediaItemPropertyTitle];
    [self.nowPlayingInfo setValue:artistName forKey:MPMediaItemPropertyArtist];
    [self.nowPlayingInfo setValue:artWork forKey:MPMediaItemPropertyArtwork];
    [self.nowPlayingInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
}
@end
