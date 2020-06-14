//
//  PlayerView.h
//  AFCachePlayer
//
//  Created by 阿凡树 on 2017/3/23.
//  Copyright © 2017年 阿凡树. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *bgView;

- (BOOL)isPlaying;

- (void)setOriginState;

- (void)playWithURL:(NSURL *)url;

- (void)stopPlay;

@end
