//
//  GuideViewController.m
//  FileManager
//
//  Created by xiaodev on Feb/5/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "GuideViewController.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import "AppDelegate.h"
#import "XTabBarViewController.h"
#import "XDPhotoBrowerViewController.h"
@interface GuideViewController ()
{
    UIScrollView *_mainScrollView;
}
@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    _mainScrollView.contentSize = CGSizeMake( width*2,height);
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
//    _mainScrollView.alwaysBounceVertical = NO;
    [self.view addSubview:_mainScrollView];
    NSArray *array = @[@{@"title":@"如果你身边有数据线\n连接电脑，打开iTunes，选择手机->左边的“应用”->往下滚动到“文件共享”，如图所示，选择“悦览播放器”把文件拖拽到右侧框中即可上传到手机。",@"image":@"iTunestranfer"},
  @{@"title":@"如果没有数据线\n电脑和手机连接到同一局域网，点击应用首页右侧按钮，如图所示在浏览器地址栏中输入IP地址，拖拽文件到浏览器窗口中即可上传文件到手机中",@"image":@"wifitransfer"}];
    for (int i=0; i<2; i++) {
        NSDictionary *dict = array[i];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(width *i+ 20, 50, width-40, 150)];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = dict[@"title"];
        [_mainScrollView addSubview:label];
        
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = CGRectMake((width-300)/2+width *i, 220, 300, 200);
        [imageButton setImage:[UIImage imageNamed:dict[@"image"]] forState: UIControlStateNormal];
        [imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_mainScrollView addSubview:imageButton];
    }
    if (self.hiddenNav) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(width +(width -150)/2, height -100, 150, 44);
        button.layer.cornerRadius = 22.0;
        button.layer.borderColor = kMainCOLOR.CGColor;
        button.layer.borderWidth = 1.0;
        [button setTitleColor:kMainCOLOR forState:UIControlStateNormal];
        [button setTitle:@"开始使用" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(begainButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_mainScrollView addSubview:button];
    }
   
}
- (void)imageButtonAction:(UIButton *)button {
    XDPhotoBrowerViewController *photo = [[XDPhotoBrowerViewController alloc]init];
    photo.imagesArray = @[button.imageView.image];
    [self.navigationController pushViewController:photo animated:NO];
 
}
- (void)begainButtonAction {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    XTabBarViewController *bar = [story instantiateInitialViewController];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController = bar;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hiddenNav) {
      self.navigationController.navigationBarHidden = YES;
    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    if (self.hiddenNav) {
      self.navigationController.navigationBarHidden = NO;
    }
    
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
