//
//  WiFiViewController.m
//  QRcreate
//
//  Created by xiaodev on Aug/31/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "WiFiViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import "XTools.h"
@interface WiFiViewController ()
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_passWordLabel;
    NSMutableDictionary *_mainDict;
    __weak IBOutlet UILabel *_typeLabel;
    
}
@end

@implementation WiFiViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"无线局域网";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _mainDict = [NSMutableDictionary dictionaryWithCapacity:0];
//    self.wifiStr = @"WIFI:T:WAP/WPA2;S:DCSJ_GZ;P:dc666;";
    NSString *subStr = [self.wifiStr substringFromIndex:5];
    NSLog(@"sub == %@",subStr);
    NSArray *array = [subStr componentsSeparatedByString:@";"];
    for (NSString * cs in array) {
        NSArray *arr = [cs componentsSeparatedByString:@":"];
        if (arr.count == 2) {
            if (arr.firstObject&&arr.lastObject) {
                [_mainDict setObject:arr.lastObject forKey:arr.firstObject];
            }
        }
    }
    _nameLabel.text = _mainDict[@"S"];
    _passWordLabel.text = [NSString stringWithFormat:@"密码：%@",_mainDict[@"P"]];
    _typeLabel.text = [NSString stringWithFormat:@"加密方式：%@",_mainDict[@"T"]];
    NSLog(@"==%@",_mainDict);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_mainDict[@"P"]];
//    [self scanWifiInfos];
    
//    if ([XTOOLS showAdShow]) {
//        UIView *adview = [XTOOLS bannerAdViewRootViewController:self];
//        adview.center = CGPointMake(kScreen_Width/2, kScreen_Height-25);
//        [self.view addSubview:adview];
//    }
    
}
- (void)backBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)gotoWiFiSetting:(id)sender {
//    NSString * urlString = @"App-Prefs:root=WIFI";
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
//        if (IOSSystemVersion>=10.0) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
//        } else {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
//        }
//    }
    [XTOOLS showAlertTitle:@"打开网络应用设置" message:@"去应用设置，寻找此网络并点击加入，粘贴密码后连接。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
        
    }];
    
}
//- (void)scanWifiInfos{
//    NSLog(@"1.Start");
//    
//    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
//    [options setObject:@"二维码" forKey: kNEHotspotHelperOptionDisplayName];
//    dispatch_queue_t queue = dispatch_queue_create("QRcreate", NULL);
//    
//    NSLog(@"2.Try");
//    BOOL returnType = [NEHotspotHelper registerWithOptions: options queue: queue handler: ^(NEHotspotHelperCommand * cmd) {
//        
//        NSLog(@"4.Finish");
//        NEHotspotNetwork* network;
//        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
//            // 遍历 WiFi 列表，打印基本信息
//            for (network in cmd.networkList) {
//                NSString* wifiInfoString = [[NSString alloc] initWithFormat: @"---------------------------\nSSID: %@\nMac地址: %@\n信号强度: %f\nCommandType:%ld\n---------------------------\n\n", network.SSID, network.BSSID, network.signalStrength, (long)cmd.commandType];
//                NSLog(@"%@", wifiInfoString);
//                
//                // 检测到指定 WiFi 可设定密码直接连接
//                if ([network.SSID isEqualToString: @"测试 WiFi"]) {
//                    [network setConfidence: kNEHotspotHelperConfidenceHigh];
//                    [network setPassword: @"123456789"];
//                    NEHotspotHelperResponse *response = [cmd createResponse: kNEHotspotHelperResultSuccess];
//                    NSLog(@"Response CMD: %@", response);
//                    [response setNetworkList: @[network]];
//                    [response setNetwork: network];
//                    [response deliver];
//                }
//            }
//        }
//    }];
//    
//    // 注册成功 returnType 会返回一个 Yes 值，否则 No
//    NSLog(@"3.Result: %@", returnType == YES ? @"Yes" : @"No");
//}
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
