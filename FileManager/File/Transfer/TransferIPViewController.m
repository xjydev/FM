//
//  TransferIPViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/28/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "TransferIPViewController.h"
#import "GCDWebUploader.h"
#import "XTools.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AFNetworking/AFNetworking.h>
#import "UMMobClick/MobClick.h"

@interface TransferIPViewController ()<GCDWebUploaderDelegate,UITableViewDelegate,UITableViewDataSource>
{

    GCDWebUploader* _webServer;
    
    
    __weak IBOutlet UIButton *_webIpButton;
    __weak IBOutlet UITableView *_transferHistoryTableView;
    
    __weak IBOutlet UILabel *_hintLabel;
    
    UIBarButtonItem   *_rightBarButton;
    NSMutableArray    *_fileArray;
    NSString          *_wifiName;
    __weak IBOutlet UIActivityIndicatorView *_activityView;
    BOOL               _isWifi;
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
    _webIpButton.layer.cornerRadius = 4;
    _webIpButton.layer.masksToBounds = YES;
    _webIpButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _webIpButton.layer.borderWidth = 0.5;
//    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    if (_isWifi) {
//        [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
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
//        [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未连接WIFI" message:@"设备未链接到局域网WIFI，是否查看网络设置，检查链接情况？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
   
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }];
        [alert addAction:cancleAction];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
 
    }
    
    
}
- (void)rightDisconnectButtonAction:(UIBarButtonItem *)bar {
    if (_webServer.isRunning) {
      [_webServer stop];
    }
    else
    {
        if ([_webServer start]) {
            [_rightBarButton setImage:[UIImage imageNamed:@"disconnect"]];
        }
    }


   
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:KDocumentP];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    
    if ([_webServer start]) {

     [_webIpButton setTitle:_webServer.serverURL.absoluteString forState:UIControlStateNormal];
    } else {
//        _webIpLabel.text = NSLocalizedString(@"GCDWebServer not running!", nil);
    }
    [MobClick beginLogPageView:@"transfer"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"transfer"];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_webServer.isRunning) {
      [_webServer stop];
    }
    _webServer.delegate = nil;
    _webServer = nil;
}
- (void)webServerDidStart:(GCDWebServer *)server {
    _webIpButton.enabled = YES;
    [_webIpButton setTitle:server.serverURL.absoluteString forState:UIControlStateNormal];
}
- (void)webServerDidStop:(GCDWebServer *)server {
    
    [_rightBarButton setImage:[UIImage imageNamed:@"reconnect"]];
    [_webIpButton setTitle:@"连接已断开" forState:UIControlStateNormal];
    _webIpButton.enabled = NO;
    
}
- (void)webServerDidConnect:(GCDWebServer *)server {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [_activityView startAnimating];
}
- (void)webServerDidDisconnect:(GCDWebServer *)server {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [_activityView stopAnimating];
}
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
    [_fileArray insertObject:@{path.lastPathComponent:@"已上传"} atIndex:0];
    [_transferHistoryTableView reloadData];
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
    [_fileArray insertObject:@{toPath.lastPathComponent:@"已转移"} atIndex:0];
    [_transferHistoryTableView reloadData];
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
    [_fileArray insertObject:@{path.lastPathComponent:@"已删除"} atIndex:0];
    [_transferHistoryTableView reloadData];
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
    [_fileArray insertObject:@{path.lastPathComponent:@"已创建"} atIndex:0];
    BOOL isDirectory = NO;
    [kFileM fileExistsAtPath:path isDirectory:&isDirectory];
    if (isDirectory) {
        self.filesTransferChangeBack(1);
    }
    [_transferHistoryTableView reloadData];
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
