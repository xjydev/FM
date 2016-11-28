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
    
    __weak IBOutlet UILabel *_webIpLabel;
    
}
@end

@implementation TransferIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件传输";
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:KDocumentP];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    if ([_webServer start]) {
        _webIpLabel.text = [NSString stringWithFormat:@"%@:%d", _webServer.serverURL.absoluteString, (int)_webServer.port];
//        NSLog(@"== %@  \n== %@ == %@",_webServer.serverURL.absoluteString,_webServer.bonjourName,_webServer.allowedFileExtensions);
        
    } else {
        _webIpLabel.text = NSLocalizedString(@"GCDWebServer not running!", nil);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_webServer stop];
    _webServer = nil;
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
