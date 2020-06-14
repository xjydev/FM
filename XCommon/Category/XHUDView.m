//
//  XHUDView.m
//  FileManager
//
//  Created by xiaodev on Nov/27/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XHUDView.h"
static const float viewWidth = 60;
@implementation XHUDView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-viewWidth)/2, ([UIScreen mainScreen].bounds.size.height - viewWidth)/5*2, viewWidth, viewWidth);
        _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 40, 40)];
        [self addSubview:_headerImageView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 60, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
    }
    return self;
}
- (void)setHeaderImage:(UIImage *)headerImage Title:(NSString *)title {
    [_headerImageView setImage:headerImage];
    _titleLabel.text = title;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
