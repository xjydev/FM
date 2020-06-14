//
//  RewardViewController.m
//  FileManager
//
//  Created by xiaodev on Aug/13/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "RewardViewController.h"
#import "XYButton.h"
#import "XTools.h"
#import "PravicyViewController.h"
#import "XDPurchase.h"

#define BUYENCRYID @"cnxiaodev.FM18Encrypting"//加密id
#define BUYADID  @"cnxiaodev.FM18AdBlock"//广告id
@interface RewardViewController ()
{
    NSString *_purchaseId;
    NSArray  *_purchaseArray;
    
   
    __weak IBOutlet UILabel *_alertLabel;
    __weak IBOutlet XYButton *_hiddenButton;
    
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
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"safe_forget"] style:UIBarButtonItemStyleDone target:self action:@selector(appealBarAction)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];
    [paragraphStyle setParagraphSpacing:10];  //调整段间距
    [paragraphStyle setHeadIndent:15.0];
    
    if ([kUSerD boolForKey:kENTRICY]) {
        _alertLabel.attributedText = [[NSAttributedString alloc]initWithString:@"1. 如果已经购买过“去广告”、“文件加密”，可以点击“恢复按钮”恢复去除广告和文件加密。\n2. 如果在购买过程中遇到问题可以邮箱（xiaodeve@163.com)联系。\n3. 如果购买后无法恢复，请点击右上角按钮，准备资料申诉。" attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:kCOLOR(0x222222, 0xeeeeee),NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    }
    else
    {
        _alertLabel.attributedText = [[NSAttributedString alloc]initWithString:@"1. 如果已经购买过“去广告”、“文件加密”，可以点击“恢复按钮”恢复去除广告和文件加密。\n2. 购买“文件加密”后，再次点击“文件加密”按钮对文件加密进行设置。\n3. 如果在购买过程中遇到问题可以邮箱（xiaodeve@163.com)联系。\n4. 如果购买后无法恢复，请点击右上角按钮，准备资料申诉。" attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:kCOLOR(0x222222, 0xeeeeee),NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    }
    
}
- (void)appealBarAction {
    [self performSegueWithIdentifier:@"AppealViewController" sender:nil];
}
- (IBAction)rewardButtonAction:(XYButton *)sender {
    
    if (sender.tag == 403) {
        [XTOOLS umengClick:@"restorepay"];
        @weakify(self);
        [[XDPurchase defaultManager]purchaseProductId:nil complete:^(NSDictionary * _Nullable purchaseDict) {
            @strongify(self);
            [self verifyPurchaseWithDict:purchaseDict];
        }];
        
    }
    else {
        [XTOOLS umengClick:@"paystart"];
        if (sender.tag == 401) {
            _purchaseId =  BUYADID;
        }
        else
            if (sender.tag == 402) {
                if ([kUSerD boolForKey:kENTRICY]) {//如果购买过进入隐私界面，不购买了。
                    PravicyViewController *VC = [PravicyViewController allocFromStoryBoard];
                    [self.navigationController pushViewController:VC animated:YES];
                    return;
                }
                _purchaseId = BUYENCRYID;
                
            }
        
        @weakify(self);
        [[XDPurchase defaultManager]purchaseProductId:_purchaseId complete:^(NSDictionary * _Nullable purchaseDict) {
            @strongify(self);
            [self verifyPurchaseWithDict:purchaseDict];
        }];
        [kUSerD setBool:YES forKey:kpaystart];
        [kUSerD synchronize];
    }
    
}
- (void)verifyPurchaseWithDict:(NSDictionary *)dict {
    NSLog(@"verify == %@",dict);
    if([dict[@"status"] intValue]==0){
        NSLog(@"购买成功！");
        [XTOOLS umengClick:@"paySucceed"];
        NSDictionary *dicReceipt= dict[@"receipt"];
        NSArray *inappArray = dicReceipt[@"in_app"] ;
        NSMutableString *inappsStr = [[NSMutableString alloc]initWithFormat:@"您已成功购买，"];
        NSString * titlestr = @"验证失败";
        NSString * contentStr = @"购买信息未验证通过，请重新购买";
        NSInteger buycount = 0;
        for (NSDictionary *inappDict in inappArray) {
            NSString *productIdentifier= inappDict[@"product_id"];//读取产品标识
            //        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
            [XTOOLS hiddenLoading];
    
            if ([productIdentifier isEqualToString:BUYENCRYID] ) {
                titlestr = @"购买成功";
                contentStr = @"您已经成功购买文件加密，点击按钮进行加密设置";
                buycount ++;
                [inappsStr appendString:@"文件加密，"];
                [kUSerD setBool:YES forKey:kENTRICY];
                [kUSerD synchronize];
                [XTOOLS umengClick:@"buyencryid"];
            }
            else if ([productIdentifier isEqualToString:BUYADID]||[productIdentifier isEqualToString:@"cnxiaoblockAdF"]){
                buycount++;
                titlestr = @"去广告成功";
                contentStr = @"我已经去除应用内的广告，感谢您的支持。";
                [inappsStr appendString:@"去除广告，"];
                [kUSerD setBool:YES forKey:KADBLOCK];
                [kUSerD synchronize];
                [XTOOLS umengClick:@"buyblock"];
            }
            
        }
        if (buycount>1) {
            [inappsStr appendString:@"感谢您的支持。"];
            contentStr = inappsStr;
        }
        self.view.userInteractionEnabled = YES;
        [XTOOLS showAlertTitle:titlestr message:contentStr buttonTitles:@[NSLocalizedString(@"Confirm", nil)] completionHandler:^(NSInteger num) {
            
        }];
        
        
        
        
    }else{
        
        [XTOOLS hiddenLoading];
        
        NSString *  errorstr = @"购买验证失败";
        NSString *  contentStr = @"购买失败，可以重新尝试，如果扣款成功，不会重复扣款。";
        self.view.userInteractionEnabled = YES;
        [XTOOLS showAlertTitle:errorstr message:contentStr buttonTitles:@[NSLocalizedString(@"Confirm", nil)] completionHandler:^(NSInteger num) {
            
        }];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    if ([kUSerD boolForKey:kHiden]) {
           [_hiddenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           _hiddenButton.layer.borderColor = [UIColor whiteColor].CGColor;
       }
       else
       {
           [_hiddenButton setTitleColor:kMainCOLOR forState:UIControlStateNormal];
           _hiddenButton.layer.borderColor = kMainCOLOR.CGColor;
       }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [XTOOLS hiddenLoading];
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
