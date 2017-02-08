//
//  QuickLookViewController.m
//  FileManager
//
//  Created by xiaodev on Dec/10/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "QuickLookViewController.h"
#import <QuickLook/QuickLook.h>
@interface QuickLookViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>
@property(nonatomic, strong)QLPreviewController *qlPreviewC;
@end

@implementation QuickLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.qlPreviewC = [[QLPreviewController alloc]init];
    self.qlPreviewC.view.frame = self.view.bounds;
    self.qlPreviewC.delegate = self;
    self.qlPreviewC.dataSource = self;
}
#pragma mark - 在此代理处加载需要显示的文件
- (NSURL *)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return [NSURL URLWithString:self.path];
}

#pragma mark - 返回文件的个数
-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}
#pragma mark - 即将要退出浏览文件时执行此方法
-(void)previewControllerWillDismiss:(QLPreviewController *)controller {
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
