//
//  RewardViewController.m
//  Wenjian
//
//  Created by xiaodev on Oct/24/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "RewardViewController.h"
//#import "UIViewController+JY.h"
#import "XDPurchase.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import <AFNetworking/AFNetworking.h>
#define kBuyAdId @"xiaodev.cn.wenjian12BlockAd"
@interface RewardViewController ()
{
    __weak IBOutlet UIButton *_hidenButton;
}
@end

@implementation RewardViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RewardViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"RewardViewController"];
    return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setleftBackButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"doubt"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction)];
}
- (void)rightBarButtonAction {
    [self performSegueWithIdentifier:@"AppealViewController" sender:nil];
}
- (IBAction)buyButtonAction:(id)sender {
    [kUSerD setBool:YES forKey:kpaystart];
    @weakify(self);
    [[XDPurchase defaultManager]purchaseProductId:kBuyAdId complete:^(NSDictionary * _Nullable purchaseDict) {
        @strongify(self);
       [self purchaseSuccessWithDict:purchaseDict isRecover:NO];
    }];
}
- (IBAction)recoverButtonAction:(id)sender {
    [XTOOLS showLoading:@"恢复中"];
     @weakify(self);
    [[XDPurchase defaultManager]purchaseProductId:nil complete:^(NSDictionary * _Nullable purchaseDict) {
        @strongify(self);
        [XTOOLS hiddenLoading];
        [self purchaseSuccessWithDict:purchaseDict isRecover:YES];
    }];
}
- (void)purchaseSuccessWithDict:(NSDictionary *)dict isRecover:(BOOL)is{
    NSLog(@"verify == %@",dict);
    if([dict[@"status"] intValue] < 21000){//订单无法验证通过
        
        [kUSerD setBool:YES forKey:KADBLOCK];
        [kUSerD setBool:YES forKey:kENTRICY];
        [kUSerD synchronize];
        NSLog(@"购买成功！");
        [XTOOLS umengClick:@"paySucceed"];
        [XTOOLS hiddenLoading];
        NSString *title = @"购买成功";
        if (is) {
            title = @"恢复成功";
        }
        [XTOOLS showAlertTitle:title message:@"你已经成功购买去除广告,应用重启广告会完全去除。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
        
    }else{
        
        [XTOOLS hiddenLoading];
        [XTOOLS showAlertTitle:@"网络验证失败" message:@"请再次重试，如果扣款成功，不会再次扣款。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
    }
}

- (void) viewUserInteractionEnabled:(BOOL)is{
    dispatch_async(dispatch_get_main_queue(), ^{
      [UIApplication sharedApplication].keyWindow.userInteractionEnabled = is;
    });
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([kUSerD boolForKey:kHiden]) {
        [_hidenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _hidenButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        [_hidenButton setTitleColor:kMainCOLOR forState:UIControlStateNormal];
        _hidenButton.layer.borderColor = kMainCOLOR.CGColor;
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    [XTOOLS hiddenLoading];
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
