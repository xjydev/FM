//
//  PasteViewController.m
//  QRcreate
//
//  Created by xiaodev on Aug/31/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "PasteViewController.h"
#import "XTools.h"
@interface PasteViewController ()

@end

@implementation PasteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描结果";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    _mainTextVIew.layer.cornerRadius = 3;
    _mainTextVIew.layer.masksToBounds = YES;
    _mainTextVIew.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _mainTextVIew.layer.borderWidth = 1.0;
    _mainTextVIew.text = self.pasteStr;
    [_mainTextVIew sizeToFit];
//    if ([XTOOLS showAdShow]) {
//        UIView *adview = [XTOOLS bannerAdViewRootViewController:self];
//        adview.center = CGPointMake(kScreen_Width/2, kScreen_Height-25);
//        [self.view addSubview:adview];
//    }
}
- (void)backBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)pasteButtonAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_mainTextVIew.text];
    [XTOOLS showMessage:@"复制成功"];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_mainTextVIew resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
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
