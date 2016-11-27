//
//  XHUDView.h
//  FileManager
//
//  Created by xiaodev on Nov/27/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHUDView : UIView
@property (nonatomic, strong)UILabel  *titleLabel;
@property (nonatomic, strong)UIImageView *headerImageView;
- (void)setHeaderImage:(UIImage *)headerImage Title:(NSString *)title;
@end
