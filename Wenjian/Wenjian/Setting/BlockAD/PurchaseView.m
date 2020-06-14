//
//  PurchaseView.m
//  Wenjian
//
//  Created by XiaoDev on 2018/7/4.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "PurchaseView.h"
#import "XTools.h"
#import "XDPurchase.h"
#define BUYADID  @"xiaodev.cn.wenjian12BlockAd"//购买广告ID
@interface PurchaseView()
@end
@implementation PurchaseView
- (void)layoutSubviews {
    [super layoutSubviews];
    if ([kUSerD boolForKey:KADBLOCK]) {
        self.hidden = YES;
    }
    else
    {
        self.hidden = NO;
    }
}
- (IBAction)buyBlockAdAction:(UIButton *)sender {
    [kUSerD setBool:YES forKey:kpaystart];
    @weakify(self);
    [[XDPurchase defaultManager]purchaseProductId:BUYADID complete:^(NSDictionary * _Nullable purchaseDict) {
        @strongify(self);
        [self purchaseSuccessWithDict:purchaseDict];
    }];
}
- (void)purchaseSuccessWithDict:(NSDictionary *)dict {
    NSLog(@"purchase == %@",dict);
    if([dict[@"status"] intValue] < 21000){//订单无法验证通过
        [kUSerD setBool:YES forKey:KADBLOCK];
        [kUSerD synchronize];
        self.hidden = YES;
        NSLog(@"购买成功！");
        [XTOOLS umengClick:@"paySucceed"];
        
        [XTOOLS hiddenLoading];
        [XTOOLS showAlertTitle:@"购买成功" message:@"你已经成功购买去除广告,应用重启广告会完全去除。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
        
    }else{
        
        [XTOOLS hiddenLoading];
        [XTOOLS showAlertTitle:@"网络验证失败" message:@"请再次重试，如果扣款成功，不会再次扣款。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
    }
}

- (void)dealloc {
    [XTOOLS hiddenLoading];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
