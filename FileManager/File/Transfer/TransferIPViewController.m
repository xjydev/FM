//
//  TransferIPViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/28/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "TransferIPViewController.h"
#import "XTools.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AFNetworking/AFNetworking.h>
#import "UMMobClick/MobClick.h"
#import "TransferIPManager.h"
#import <UShareUI/UShareUI.h>

@interface TransferIPViewController ()<UMSocialShareMenuViewDelegate,TransferIpManagerDelegate, UITableViewDelegate,UITableViewDataSource>
{

    __weak IBOutlet UIButton *_webIpButton;
    __weak IBOutlet UITableView *_transferHistoryTableView;
    
    __weak IBOutlet UILabel *_hintLabel;
    
    UIBarButtonItem   *_rightBarButton;
    NSMutableArray    *_fileArray;
    NSString          *_wifiName;
    __weak IBOutlet UIActivityIndicatorView *_activityView;
    BOOL               _isWifi;
    BOOL               _isShare;
    __weak IBOutlet UILabel *wifiNameLabel;
    
}
@end

@implementation TransferIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件传输";
    _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"disconnect"] style:UIBarButtonItemStyleDone target:self action:@selector(rightDisconnectButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    _transferHistoryTableView.delegate = self;
    _transferHistoryTableView.dataSource = self;
    _transferHistoryTableView.tableFooterView = [[UIView alloc]init];
    
    _webIpButton.layer.cornerRadius = 4;
    _webIpButton.layer.masksToBounds = YES;
    _webIpButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _webIpButton.layer.borderWidth = 0.5;
    
    _fileArray = [NSMutableArray arrayWithCapacity:0];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            if (netType == 5) {
                _isWifi = YES;
            }
        }
    }
   

    if (_isWifi) {
//如果系统有WiFi，检测应用能不能链接WiFi。
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                id info = nil;
                NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
                for (NSString *ifnam in ifs) {
                    info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
                    _wifiName = info[@"SSID"];
                    
                }
                if (_wifiName) {
                    wifiNameLabel.text = [NSString stringWithFormat:@"连接WiFi名称：“%@”",_wifiName];
                }
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未在WiFi环境下" message:@"您的手机或APP未连接局域网WiFi，只有两个设备连接同一局WiFi才可以传输内容。是否检查应用设置。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    
//                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
                }];
                [alert addAction:cancleAction];
                [alert addAction:sureAction];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
  
            }
            [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
        }];
        
    }
    else
    {
        

        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未连接WIFI" message:@"设备未链接到局域网WIFI，是否查看网络设置，检查链接情况？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
   
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
        }];
        [alert addAction:cancleAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
 
    }
    [TransferIPManager defaultManager].delegate = self;
    [[TransferIPManager defaultManager]startConnect];
    
    
}
- (void)rightDisconnectButtonAction:(UIBarButtonItem *)bar {
    if ([TransferIPManager defaultManager].webServer.isRunning) {
      [[TransferIPManager defaultManager].webServer stop];
    }
    else
    {
        [[TransferIPManager defaultManager].webServer start];
    }

}
- (void)transferServerDidStartOrStop:(BOOL)isStart {
    if (isStart) {
       [_webIpButton setTitle:[TransferIPManager defaultManager].webServer.serverURL.absoluteString forState:UIControlStateNormal];
        [_rightBarButton setImage:[UIImage imageNamed:@"disconnect"]];
    }else
    {
       [_webIpButton setTitle:@"连接已断开" forState:UIControlStateNormal];
        [_rightBarButton setImage:[UIImage imageNamed:@"reconnect"]];
    }
    
}
- (void)transferConnectOrDisConnect:(BOOL)isConnect {
    if (isConnect) {
        if (_activityView) {
            [_activityView startAnimating];
        }

    }
    else
    {
        if (_activityView) {
            [_activityView stopAnimating];
        }

    }
}
- (void)transferUploaderType:(UploaderType)type Path:(NSString *)path {
    switch (type) {
        case UploaderTypeDownload:
        {
            [_fileArray insertObject:@{path.lastPathComponent:@"已下载"} atIndex:0];
        }
            break;
        case UploaderTypeUpload:
        {
           [_fileArray insertObject:@{path.lastPathComponent:@"已上传"} atIndex:0];
        }
            break;
        case UploaderTypeMove:
        {
           [_fileArray insertObject:@{path.lastPathComponent:@"已转移"} atIndex:0];
        }
            break;
        case UploaderTypeDelete:
        {
           [_fileArray insertObject:@{path.lastPathComponent:@"已删除"} atIndex:0];
        }
            break;
        case UploaderTypeCreate:
        {
           [_fileArray insertObject:@{path.lastPathComponent:@"已创建"} atIndex:0];
            BOOL isDirectory = NO;
            [kFileM fileExistsAtPath:path isDirectory:&isDirectory];
            if (isDirectory) {
                self.filesTransferChangeBack(1);
            }

        }
            break;
        default:
            break;
    }
    [self reloadTableView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isShare = NO;
    [MobClick beginLogPageView:@"transfer"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"transfer"];
    if (!_isShare) {
        if (![TransferIPManager defaultManager].isUploading) {
            [[TransferIPManager defaultManager] stopConnect];
        }
        [TransferIPManager defaultManager].delegate = nil;
    }
   
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}
- (void)reloadTableView {
    if (_transferHistoryTableView) {
        [_transferHistoryTableView reloadData];
    }
}
#pragma mark -- tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"transfercell" forIndexPath:indexPath];
    NSDictionary *dict = _fileArray[indexPath.row];
    cell.textLabel.text = dict.allKeys.firstObject;
    cell.detailTextLabel.text = dict.allValues.firstObject;
//    cell.detailTextLabel.textColor = [UIColor redColor];
    return cell;
}
- (IBAction)transferIPButtonAction:(id)sender {
    if ([TransferIPManager defaultManager].webServer.isRunning) {
        _isShare = YES;
        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_QQ),
                                                @(UMSocialPlatformType_WechatSession),
                                                   ]];
            [UMSocialUIManager setShareMenuViewDelegate:self];
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            // 根据获取的platformType确定所选平台进行下一步操作
            
            NSString *title = @"悦览播放器局域网传输地址";
            NSString *descr = [TransferIPManager defaultManager].webServer.serverURL.absoluteString;
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            messageObject.title = title;
            //设置文本
            messageObject.text = descr;
            
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
                if (error) {
                    UMSocialLogInfo(@"************Share fail with error %@*********",error);
                    [XTOOLS showMessage:@"分享失败"];
                }else{
                    [XTOOLS showMessage:@"分享成功"];
                    if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                        UMSocialShareResponse *resp = data;
                        //分享结果消息
                        UMSocialLogInfo(@"response message is %@",resp.message);
                        //第三方原始返回的数据
                        UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                        
                    }else{
                        UMSocialLogInfo(@"response data is %@",data);
                    }
                }
                
            }];
            
        }];
  
    }
    else
    {
        [XTOOLS showMessage:@"网络未连接"];
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
