//
//  ShowImageController.m
//  FileManager
//
//  Created by XiaoDev on 2018/1/31.
//  Copyright © 2018年 xiaodev. All rights reserved.
//

#import "ShowImageController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "XTools.h"
@interface ShowImageController ()
{
    UIImageView *_showImageView;
    
}
@end

@implementation ShowImageController
+ (instancetype)returnViewController {
    ShowImageController *controller = [[ShowImageController alloc]init];
    return controller;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _showImageView = [[UIImageView alloc]init];
    [self.view addSubview:_showImageView];
}
- (void)showImageUrl:(NSString *)url {
   __weak UIImageView *imageView =  _showImageView;
    [_showImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        if (image) {
          imageView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        }
        else
        {
            [XTOOLS showMessage:@"加载失败"];
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        [XTOOLS showMessage:NSLocalizedString(@"Error", nil)];
    }];
}
- (BOOL)shouldAutorotate {
    if (IsPad) {
        return YES;
    }
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IsPad) {
       return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
