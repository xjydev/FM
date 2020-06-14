//
//  QRCodelistCell.m
//  QRcreate
//
//  Created by xiaodev on Sep/6/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "QRCodelistCell.h"
#import "XTools.h"
@implementation QRCodelistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
        _contentLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
