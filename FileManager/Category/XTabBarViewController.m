//
//  XTabBarViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/25/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XTabBarViewController.h"
#import "XTools.h"
@interface XTabBarViewController ()

@end

@implementation XTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate {
 return  XTOOLS.isCanRotation;
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
