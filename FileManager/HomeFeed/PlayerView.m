//
//  PlayerView.m
//  AFCachePlayer
//
//  Created by 阿凡树 on 2017/3/23.
//  Copyright © 2017年 阿凡树. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

static const NSString *kItemStatusContext;
@interface PlayerView ()
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *playProgressView;
@property (strong, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) id playerObserver;
@property (strong, nonatomic) AVURLAsset *asset;
@property (strong, nonatomic) AVPlayerItem *currentItem;
@end
@implementation PlayerView
- (BOOL)isPlaying {
    return _player.status == AVPlayerItemStatusReadyToPlay;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderColor = [UIColor greenColor].CGColor;
}
- (void)dealloc {
    [self removeObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_currentItem) {
        [_currentItem removeObserver:self forKeyPath:@"status" context:&kItemStatusContext];
    }
}

- (IBAction)next:(id)sender {
}
- (void)play {
    if (!self.playable) {
        return;
    }
    [self updatePlayStatus];
    [self addObservers];
    [self.player play];
}

- (void)pause {
    [self.player pause];
    [self removeObservers];
}
- (void)stopPlay {
    [self pause];
    
}
- (void)setOriginState {
    [self stopPlay];
    _maskView.hidden = NO;
}
- (void)playWithURL:(NSURL *)url {
    self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
    [self.asset loadValuesAsynchronouslyForKeys:@[@"duration", @"playable"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playable) {
                [self configurePlayerItem];
                [self play];
            }
        });
    }];
}
- (void)configurePlayerItem {
    if (self.currentItem) {
        [self.currentItem removeObserver:self forKeyPath:@"status" context:&kItemStatusContext];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    }
    self.currentItem = [AVPlayerItem playerItemWithAsset:self.asset];
    [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:&kItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        if (self.playerLayer) {
            [self.playerLayer removeFromSuperlayer];
            self.hidden = YES;
        }
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kItemStatusContext) {
        [self updatePlayStatus];
    }
}
- (void)addObservers {
    [self removeObservers];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.maskView.hidden = YES;
    });
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updatePlayStatus];
    }];
}

- (void)removeObservers {
    self.maskView.hidden = NO;
    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
}
- (void)updatePlayStatus {
    if (self.currentItem.status == AVPlayerItemStatusFailed) {
        [self removeObservers];
    } else if (self.currentItem.status == AVPlayerItemStatusReadyToPlay && self.player.rate != 0) {
        if (!self.playerLayer.superlayer) {
            [self.videoView.layer addSublayer:self.playerLayer];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.hidden = NO;
            });
        }
        NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.duration);
        NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
        self.startLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)current/60,(long)current%60];
        self.endLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)duration/60,(long)duration%60];
        self.playProgressView.progress = current/duration;
    }
}
- (void)playerItemDidReachEnd:(NSNotification *)noti {
    [self removeObservers];
    
}
- (BOOL)playable {
    BOOL playable = NO;
    NSError *error = nil;
    if ([self.asset statusOfValueForKey:@"playable" error:&error] == AVKeyValueStatusLoaded && !error && self.asset.playable) {
        playable = YES;
    }
    return playable;
}
@end
