//
//  MRVLCPlayer.h
//  MRVLCPlayer
//
//  Created by apple on 16/3/5.
//  Copyright © 2016年 Alloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import "MRVideoControlView.h"
@protocol MRVLCPlayerDelegate <NSObject>

@optional
- (void)playerCloseButton:( UIButton * _Nonnull )button ;
- (void)playerNextPrevButton:(UIButton *_Nonnull)button;

@end

@interface MRVLCPlayer : UIView <VLCMediaPlayerDelegate,MRVideoControlViewDelegate>

@property (nonatomic,strong,nonnull) NSURL *mediaURL;
@property (nonatomic,assign) BOOL isFullscreenModel;

@property (nullable, nonatomic,weak) id<MRVLCPlayerDelegate>delegate;
- (void)showInView:(UIView * _Nonnull)view;
- (void)play;
@end


