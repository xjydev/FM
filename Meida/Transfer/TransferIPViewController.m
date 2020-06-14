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
#import "TransferIPManager.h"
#import <UShareUI/UShareUI.h>
#import "ShareView.h"

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
    
    BOOL       _isbigFileHint;//是否是大文件提现。
    NSTimer   *_loopsShowTimer;
    
}
@end

@implementation TransferIPViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    TransferIPViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"TransferIPViewController"];
    return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [kNOtificationC addObserver:self
                                             selector:@selector(backgroundStopContent)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [kNOtificationC addObserver:self
                                             selector:@selector(becomeActiveStartContent)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
//    _showaddNum = 0;
    [XTOOLS umengClick:@"transferip"];
    self.title = @"文件传输";
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(goBackAction)];
    _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"reconnect"] style:UIBarButtonItemStyleDone target:self action:@selector(rightDisconnectButtonAction:)];
    self.navigationItem.rightBarButtonItem = nil;
    _transferHistoryTableView.delegate = self;
    _transferHistoryTableView.dataSource = self;
    _transferHistoryTableView.tableFooterView = [[UIView alloc]init];
    
    _webIpButton.layer.cornerRadius = 4;
    _webIpButton.layer.masksToBounds = YES;
    _webIpButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _webIpButton.layer.borderWidth = 0.5;
    
    _fileArray = [NSMutableArray arrayWithCapacity:0];
   
    //如果系统有WiFi，检测应用能不能链接WiFi。
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            id info = nil;
            NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
            for (NSString *ifnam in ifs) {
                info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
                self->_wifiName = info[@"SSID"];
                
            }
            if (self->_wifiName) {
                self->wifiNameLabel.text = [NSString stringWithFormat:@"手机和电脑必须都连接WiFi：“%@”",self->_wifiName];
            }
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未连接WiFi" message:@"App未获取连接WiFi权限，不能与电脑互相传输。是否检查应用设置，打开网络权限？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                
                //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
            }];
            [alert addAction:cancleAction];
            [alert addAction:sureAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
        [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    }];
    
    if (self.filePath.length == 0) {
        self.filePath = KDocumentP;
    }
    [TransferIPManager defaultManager].delegate = self;
    [TransferIPManager defaultManager].uploadPath = self.filePath;
    [[TransferIPManager defaultManager]startConnect];
    
}
- (void)loopsShowHint {
    NSString *hintStr = @"较大文件建议使用iTunes数据线传输";
    if (_isbigFileHint) {
       hintStr = @"传输过程中请不要关闭应用。";
    }
    [UIView animateWithDuration:1 animations:^{
        self->_hintLabel.alpha = 0;
    }completion:^(BOOL finished) {
        self->_hintLabel.text = hintStr;
        [UIView animateWithDuration:1 animations:^{
            self->_hintLabel.alpha = 1;
        }];
    }];
    _isbigFileHint = !_isbigFileHint;
    
}
- (void)goBackAction {
    
    [self.navigationController popViewControllerAnimated:YES];
//    [XTOOLS goToAppstoreComment];
}
- (void)rightDisconnectButtonAction:(UIBarButtonItem *)bar {
    if ([TransferIPManager defaultManager].webServer.isRunning) {
      [[TransferIPManager defaultManager] stopConnect];
    }
    else
    {
        [[TransferIPManager defaultManager] startConnect];
    }

}
- (void)backgroundStopContent {
    [[TransferIPManager defaultManager] stopConnect];
}
- (void)becomeActiveStartContent {
    [[TransferIPManager defaultManager] startConnect];
}
- (void)transferServerDidStartOrStop:(BOOL)isStart {
    if (isStart) {
       [_webIpButton setTitle:[TransferIPManager defaultManager].webServer.serverURL.absoluteString forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = nil;

    }
    else {
       [_webIpButton setTitle:@"连接已断开" forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = _rightBarButton;
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
                if (self.filesTransferChangeBack) {
                   self.filesTransferChangeBack(1);
                }
                
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
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    if (!_loopsShowTimer) {
      _loopsShowTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(loopsShowHint) userInfo:nil repeats:YES];
    }
    if ([XTOOLS showAdview]) {
        UIView *adView = [XTOOLS bannerAdViewRootViewController:self];
        adView.center = CGPointMake(kScreen_Width/2, kScreen_Height - 25);
        [self.view addSubview:adView];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
    [_loopsShowTimer invalidate];
    _loopsShowTimer = nil;
    if (!_isShare) {
        [kNOtificationC removeObserver:self];
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
        [[ShareView shareView]shareViewWithTitle:@"悦览播放网页传输地址：" Detail:[TransferIPManager defaultManager].webServer.serverURL.absoluteString Image:nil Types:XShareTypeWeChat,XShareTypeQQ,XShareTypeCopy,XShareTypeEnd];
    }
    else
    {
        [XTOOLS showMessage:@"网络未连接"];
    }
    
}
- (void)shareWithPlatform:(UMSocialPlatformType)platformType {
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
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
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
