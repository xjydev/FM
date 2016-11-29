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
@interface TransferIPViewController ()<GCDWebUploaderDelegate>
{

    GCDWebUploader* _webServer;
    
    
    __weak IBOutlet UIButton *_webIpButton;
    UIBarButtonItem   *_rightBarButton;
    NSMutableArray    *_fileArray;
    
}
@end

@implementation TransferIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件传输";
    _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"disconnect"] style:UIBarButtonItemStyleDone target:self action:@selector(rightDisconnectButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    
    _fileArray = [NSMutableArray arrayWithCapacity:0];
    
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
    
//    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:KDocumentP];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    
    if ([_webServer start]) {

//        NSLog(@"== %@  \n== %@ == %@ == %@",_webServer.serverURL.absoluteString,_webServer.bonjourName,_webServer.allowedFileExtensions,_webServer.title);
     [_webIpButton setTitle:_webServer.serverURL.absoluteString forState:UIControlStateNormal];
    } else {
//        _webIpLabel.text = NSLocalizedString(@"GCDWebServer not running!", nil);
    }
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
    _webIpButton.enabled = YES;
    [_webIpButton setTitle:server.serverURL.absoluteString forState:UIControlStateNormal];
}
- (void)webServerDidDisconnect:(GCDWebServer *)server {
    
  [_webIpButton setTitle:@"连接已断开" forState:UIControlStateNormal];
   _webIpButton.enabled = NO;
}
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
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
