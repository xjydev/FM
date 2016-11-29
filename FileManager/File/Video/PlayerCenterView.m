//
//  PlayerCenterView.m
//  iPhone
//
//  Created by xiaojingyuan on 4/22/15.
//  Copyright (c) 2015 优米网. All rights reserved.
//
static float imageViewWidth = 50;

#import "PlayerCenterView.h"

@implementation PlayerCenterView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
       
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageViewWidth, frame.size.width, frame.size.height-imageViewWidth)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
//        _titleLabel.backgroundColor = [UIColor blueColor];
        [self addSubview:_titleLabel];
        
        
        _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerButton.frame=CGRectMake((frame.size.width-imageViewWidth)/2, 10, imageViewWidth, imageViewWidth);
//        _centerButton.backgroundColor = [UIColor redColor];
        [self addSubview:_centerButton];
        
        
        _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake((frame.size.width-imageViewWidth)/2, 10, imageViewWidth, imageViewWidth);
//        _activityView.backgroundColor = [UIColor clearColor];
        _activityView.color = [UIColor grayColor];
        
        _activityView.hidesWhenStopped = YES;
//        _activityView.layer.masksToBounds = YES;
//        _activityView.layer.cornerRadius = 5;
//        self.backgroundColor = [UIColor yellowColor];
        [self addSubview:_activityView];
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
    } 
    return self;
}
- (void)ShowWithType:(PlayerCenterType)playertype Title:(NSString *)title
{
    _playerType = playertype;
    
    switch (_playerType) {
        case PlayerCenterTypeStop:
        {
           self.hidden= NO;
            self.alpha = 1;
            _centerButton.userInteractionEnabled = YES;
            _centerButton.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//            _titleLabel.frame = CGRectMake(0, 70, 185, 30);
//            _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10];
//            _titleLabel.numberOfLines = 0;
            [_centerButton setImage:[UIImage imageNamed:@"play_big"] forState:UIControlStateNormal];
            
            _centerButton.hidden = NO;
            [_activityView stopAnimating];
            _activityView.hidden = YES;
        }
            break;
        case PlayerCenterTypeWaiting:
        {
            self.hidden= NO;
            _centerButton.hidden = YES;
            _activityView.hidden = NO;
//            _titleLabel.frame = CGRectMake(0, 70, 185, 30);
//            _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10];
//            _titleLabel.numberOfLines = 0;
            [_activityView startAnimating];
            
        }
            break;
        case PlayerCenterTypeSpeedForward:
        {
            self.hidden= NO;
//            _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
            _centerButton.frame = CGRectMake((self.frame.size.width-imageViewWidth)/2, 10, imageViewWidth, imageViewWidth);
//            _titleLabel.frame = CGRectMake(0, 50, 185, 30);
            [_centerButton setImage:[UIImage imageNamed:@"play_forward"] forState:UIControlStateNormal];
            _centerButton.userInteractionEnabled = NO;
            _centerButton.hidden = NO;
            [_activityView stopAnimating];
            _activityView.hidden = YES;
            [self centerWillDismiss];
            
        }
            break;
        case PlayerCenterTypeSpeedBack:
        {
            self.hidden= NO;
            _centerButton.frame=CGRectMake((self.frame.size.width-imageViewWidth)/2, 10, imageViewWidth, imageViewWidth);
//            _titleLabel.frame = CGRectMake(0, 50, 185, 30);
//            _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
            [_centerButton setImage:[UIImage imageNamed:@"play_back"] forState:UIControlStateNormal];
            _centerButton.userInteractionEnabled = NO;
            _centerButton.hidden = NO;
            [_activityView stopAnimating];
            _activityView.hidden = YES;
            [self centerWillDismiss];
        }
             break;
        case PlayerCenterTypeBright:
        {
            self.hidden= NO;
            _centerButton.frame=CGRectMake((self.frame.size.width-imageViewWidth)/2, 10, imageViewWidth, imageViewWidth);
            //            _titleLabel.frame = CGRectMake(0, 50, 185, 30);
//            _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
            [_centerButton setImage:[UIImage imageNamed:@"play_bright"] forState:UIControlStateNormal];
            _centerButton.userInteractionEnabled = NO;
            _centerButton.hidden = NO;
            [_activityView stopAnimating];
            _activityView.hidden = YES;
            [self centerWillDismiss];
        }
            break;
        case PlayerCenterTypeVolume:
        {
            self.hidden= NO;
            _centerButton.frame=CGRectMake((self.frame.size.width-imageViewWidth)/2, 10, imageViewWidth, imageViewWidth);
            //            _titleLabel.frame = CGRectMake(0, 50, 185, 30);
//            _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
            [_centerButton setImage:[UIImage imageNamed:@"play_volume"] forState:UIControlStateNormal];
            _centerButton.userInteractionEnabled = NO;
            _centerButton.hidden = NO;
            [_activityView stopAnimating];
            _activityView.hidden = YES;
            [self centerWillDismiss];
        }

            break;
        case PlayerCenterTypeDefaul:
        {
            self.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    _titleLabel.text = title;
}
-(void)centerWillDismiss {
    self.hidden = NO;
    self.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
}
- (void)dismiss{
    if (_playerType == PlayerCenterTypeBright||_playerType == PlayerCenterTypeVolume||_playerType == PlayerCenterTypeSpeedBack ||_playerType == PlayerCenterTypeSpeedForward) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
    
}
- (void)hiddenPlayButton {
    if (_playerType == PlayerCenterTypeStop||_playerType == PlayerCenterTypeWaiting) {
        self.hidden = YES;
    }
}
@end
