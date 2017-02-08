//
//  XProgressView.m
//  FileManager
//
//  Created by xiaodev on Dec/15/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XProgressView.h"
#import "XTools.h"
#import "AppDelegate.h"
static XProgressView *_xprogress = nil;
@implementation XProgressView
+(instancetype)defaultProgress {
    if (!_xprogress) {
        _xprogress = [[XProgressView alloc]initWithFrame:CGRectMake((kScreen_Width-100)/2, (kScreen_Height - 200)/2, 100, 100)];
        _xprogress.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        _xprogress.layer.cornerRadius = 10;
        _xprogress.layer.masksToBounds = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:_xprogress];
        
        
    }
    return _xprogress;
}
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 50, 100, 30)];
        [self addSubview:_progressView];
    }
    return _progressView;
}
- (void)setPercentage:(float)percentage {
    if (percentage >=1) {
        [_xprogress removeFromSuperview];
        _xprogress = nil;
    }
    else
    {
        _xprogress.progressView.progress = percentage;
    }
}
- (void)removeRelease {
    [_xprogress removeFromSuperview];
    _xprogress = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
