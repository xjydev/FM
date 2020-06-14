//
//  RewardViewController.m
//  player
//
//  Created by XiaoDev on 2019/9/8.
//  Copyright © 2019 Xiaodev. All rights reserved.
//

#import "RewardViewController.h"
#import "XDPurchase.h"
#import "HideViewController.h"
#import "XTools.h"
#import "WebViewController.h"
@interface RewardViewController ()
{
    NSString *_purchaseId;
}
@property (weak, nonatomic) IBOutlet UIButton *hiddenButton;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIButton *yearButton;
@property (weak, nonatomic) IBOutlet UIButton *year2Button;

@end

@implementation RewardViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RewardViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"RewardViewController"];
    return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订阅会员";
    UIBarButtonItem *doubtBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"doubt"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction)];
    UIBarButtonItem *reBar = [[UIBarButtonItem alloc]initWithTitle:@"恢复" style:UIBarButtonItemStylePlain target:self action:@selector(restoreButtonAction)];
    self.navigationItem.rightBarButtonItems = @[doubtBar,reBar];
    self.yearButton.layer.cornerRadius = 5;
    self.yearButton.layer.borderColor = kMainCOLOR.CGColor;
    self.yearButton.layer.borderWidth = 1.0;
    
    self.year2Button.layer.cornerRadius = 5;
    self.year2Button.layer.borderColor = kMainCOLOR.CGColor;
    self.year2Button.layer.borderWidth = 1.0;
    
    self.monthButton.layer.cornerRadius = 5;
    self.monthButton.layer.borderColor = kMainCOLOR.CGColor;
    self.monthButton.layer.borderWidth = 1.0;
}
- (void)restoreButtonAction {
    [XTOOLS umengClick:@"restore"];
    [[XDPurchase defaultManager]purchaseProductId:nil complete:^(NSDictionary * _Nullable purchaseDict) {//
        NSLog(@"buy == %@",purchaseDict);
        if (purchaseDict) {
            [kUSerD setBool:YES forKey:kENTRICY];
            [kUSerD setBool:YES forKey:KADBLOCK];
            [kUSerD synchronize];
            [XTOOLS umengClick:@"restoresuccess"];
        }
        else {
            [XTOOLS umengClick:@"restorefail"];
            [XTOOLS showAlertTitle:@"恢复失败" message:@"如果多次无法恢复，你可以点击问号按钮，进行申诉。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                
            }];
        }
    }];
}
- (void)rightBarButtonAction {
    [XTOOLS umengClick:@"appeal"];
    [self performSegueWithIdentifier:@"AppealViewController" sender:nil];
}
- (IBAction)memberButtonAction:(UIButton *)sender {
    
    if (sender.tag == 301) {
        _purchaseId = @"cn.xiaodev.monthMember";
        [XTOOLS umengClick:@"buymonth"];
        
    }
    else if (sender.tag == 302) {
      _purchaseId = @"cn.xiaodev.player.season";
        [XTOOLS umengClick:@"buyseason"];
    }
    else if (sender.tag == 303) {
      _purchaseId = @"cn.xiaodev.player.year";
        [XTOOLS umengClick:@"buyyear"];
    }
    [[XDPurchase defaultManager]purchaseProductId:_purchaseId complete:^(NSDictionary * _Nullable purchaseDict) {//
        NSLog(@"buy == %@",purchaseDict);
        if (purchaseDict) {
            [XTOOLS umengClick:@"buyseuccess"];
            [kUSerD setBool:YES forKey:kENTRICY];
            [kUSerD setBool:YES forKey:KADBLOCK];
            [kUSerD synchronize];
        }
        else {
            [XTOOLS umengClick:@"buyfail"];
            [XTOOLS showAlertTitle:@"订阅失败" message:@"你可以点击按钮重新订阅，不会重复扣费。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                
            }];
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([kUSerD boolForKey:kHiden]) {
        [self.hiddenButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        self.hiddenButton.layer.borderWidth = 0.5;
        self.hiddenButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        [self.hiddenButton setTitleColor:kMainCOLOR forState:UIControlStateNormal];
        self.hiddenButton.layer.borderWidth = 1.0;
        self.hiddenButton.layer.borderColor = kMainCOLOR.CGColor;
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    [XTOOLS hiddenLoading];
}
- (IBAction)clauseButtonAction:(UIButton *)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    if (sender.tag == 300) {
        webViewController.title = @"使用条款";
        webViewController.urlStr = @"http://xiaodev.com/2019/11/19/TermsOfUse/";
    }
    else {
        webViewController.title = @"隐私条款";
        webViewController.urlStr = @"http://xiaodev.com/2018/09/06/privacy/";
    }
    [self.navigationController pushViewController:webViewController animated:YES];
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
