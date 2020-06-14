//
//  HomeFeedCell.m
//  FileManager
//
//  Created by 阿凡树 on 2017/4/7.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import "HomeFeedCell.h"
#import "PlayerView.h"
#import "UIImageView+WebCache.h"
#import "XTools.h"
@interface HomeFeedCell()
@property (strong, nonatomic) IBOutlet PlayerView *playView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@end
@implementation HomeFeedCell
- (void)awakeFromNib {
    [super awakeFromNib];
    _titleLabel.preferredMaxLayoutWidth = kScreen_Width - 30;
    UIView* view = [[UIView alloc] init];
    self.selectedBackgroundView = view;
}
- (void)setModel:(HomeFeedModel*)model {
    _model = model;
    [_playView setOriginState];
    _titleLabel.text = _model.title;
    _countLabel.text = [NSString stringWithFormat:@"观看次数:%zd",_model.count];
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:_model.author]];
    [_playView.bgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://7xnvqo.com1.z0.glb.clouddn.com/%@",_model.videopic]]];
}
- (void)startPlay {
    [self stopPlay];
    [_playView playWithURL:[NSURL URLWithString:_model.videourl]];
}
- (void)stopPlay {
    [_playView setOriginState];
}
@end
