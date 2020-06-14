//
//  FaceConnectController.m
//  FileManager
//
//  Created by xiaodev on Mar/14/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "FaceConnectController.h"
#import "FileDetailController.h"
#import "SelectFileViewController.h"
#import "UIColor+Hex.h"
#import "XTools.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define SERVICE_TYPE @"RCserviceType"

@interface FaceConnectController ()<UITableViewDelegate,UITableViewDataSource,MCSessionDelegate,MCBrowserViewControllerDelegate>
{
    __weak IBOutlet UITableView *_mainTableView;
    NSMutableArray              *_transferArray;
    UIBarButtonItem                *_rightBar;
    BOOL                            _isConnected;//是否链接。
    NSString                       *_firstCellTitle;//第一行显示的文字
    NSString                       *_connectedName;
    BOOL                            _isTransfering;
    NSProgress                     *_fileProgress;
    
}
@property (nonatomic, strong) UILabel    *connectView;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCAdvertiserAssistant *assistant;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, assign) MCSessionState state;
@property (nonatomic, strong) MCBrowserViewController *brower;
@end

@implementation FaceConnectController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    FaceConnectController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"FaceConnectController"];
    return VC;
}
- (UILabel *)connectView {
    if (!_connectView) {
        _connectView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
        _connectView.backgroundColor = kDarkCOLOR(0xf7f7f7);
        _connectView.textAlignment = NSTextAlignmentCenter;
        _connectView.font = [UIFont systemFontOfSize:15];
        _connectView.textColor = [UIColor colorWithRed:1.0 green:0.2 blue:0 alpha:1];
        _connectView.text = @"双方都打开此界面才可以连接";
    }
    return _connectView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.folderPath.length == 0) {
        self.folderPath = KDocumentP;
    }
    self.title = @"面对面传输";
    [XTOOLS umengClick:@"facetransfer"];
    _connectedName = @"双方都打开此界面才可以连接传输";
    _transferArray = [NSMutableArray arrayWithCapacity:0];
    _firstCellTitle = @"搜索连接周围用户";
    _rightBar = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Search", nil) style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBar;
  //打开搜索
    self.state = MCSessionStateNotConnected;
    
    self.session = [[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name]];
    self.session.delegate = self;

    MCAdvertiserAssistant *assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_TYPE discoveryInfo:nil
                                                                                  session:self.session];
    self.assistant = assistant;
    [self.assistant start];
    _mainTableView.tableFooterView = [[UIView alloc]init];
    
}
- (void)rightBarButtonAction:(UIBarButtonItem *)bar {
    if (_isConnected) {
        [self.session disconnect];
    }
    else
    {
        
        if (self.assistant != nil) {
            if (!self.brower) {
                self.brower = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:self.session];
                self.brower.delegate = self;
            }
            [self presentViewController:self.brower animated:YES completion:nil];
        }else{
            NSLog(@"设备无法被扫描到.");
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"请重新进入此界面" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *acition = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertCtr addAction:acition];
            [self presentViewController:alertCtr animated:YES completion:nil];
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60.0f;
    }
    return 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 30.0;
    }
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _transferArray.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        self.connectView.text = _connectedName;
       return self.connectView;
    }
    else
    {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        headerView.backgroundColor = kCOLOR(0xf7f7f7, 0x222222);
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 40)];
        label.text = @"已传输文件";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor grayColor];
        [headerView addSubview:label];
        return headerView;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"faceConnectcellId" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.filePath&&_isConnected) {
            cell.textLabel.text = self.filePath.lastPathComponent;
            cell.detailTextLabel.text = @"传输中";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
           cell.textLabel.text = _firstCellTitle;
            cell.detailTextLabel.text = @"连接后才可以传输文件";
           cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        UIButton *accessoryButton =(UIButton *)cell.accessoryView;
        [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
        
        NSString *pathName = _transferArray[indexPath.row];
        cell.textLabel.text = pathName;
        float store = [XTOOLS fileSizeAtPath:[self.folderPath stringByAppendingPathComponent:pathName]];
        
        cell.detailTextLabel.text = [XTOOLS storageSpaceStringWith:store];
        switch ([XTOOLS fileFormatWithPath:pathName]) {
            case FileTypeFolder:
                [cell.imageView setImage:[UIImage imageNamed:@"file_folder"]];
                break;
            case FileTypeAudio:
                [cell.imageView setImage:[UIImage imageNamed:@"file_audio"]];
                break;
            case FileTypeImage:
                [cell.imageView setImage:[UIImage imageNamed:@"file_image"]];
                break;
            case FileTypeVideo:
                [cell.imageView setImage:[UIImage imageNamed:@"file_video"]];
                break;
            case FileTypeCompress:
                [cell.imageView setImage:[UIImage imageNamed:@"file_zip"]];
                break;
            case FileTypeDocument:
                [cell.imageView setImage:[UIImage imageNamed:@"file_document"]];
                break;
            default:
                [cell.imageView setImage:[UIImage imageNamed:@"file_unknow"]];
                break;
        }
        
       
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [self.folderPath stringByAppendingPathComponent:_transferArray[indexPath.row]];
    
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        if (_isConnected) {
            if (self.filePath) {
                //是否断开
                [XTOOLS showAlertTitle:@"是否断开传输" message:@"断开传输将取消" buttonTitles:@[NSLocalizedString(@"Cancel", nil),@"断开"] completionHandler:^(NSInteger num) {
                    if (num == 1) {
                        [self.session disconnect];
                        self.filePath = nil;
                        
                    }
                }];
            }
            else
            {
                SelectFileViewController *transfer = [SelectFileViewController allocFromStoryBoard];
                transfer.title = @"选择传输文件";
                transfer.selectedPath = ^(NSString *path){
                    self.filePath = path;
                    [self sendFile:self.filePath];
                    [self->_mainTableView reloadData];
                };
                [self.navigationController pushViewController:transfer animated:YES];
            }
            
        }
        else
        {
            [self rightBarButtonAction:nil];
        }
        
    }
    else
    {
        NSString *path = [self.folderPath stringByAppendingPathComponent:_transferArray[indexPath.row]];
        [XTOOLS playFileWithPath:path OrigionalWiewController:self];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)sendFile:(NSString *)path {
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    _fileProgress=
    [self.session sendResourceAtURL:fileURL
                           withName:[fileURL lastPathComponent]
                             toPeer:self.peerID
              withCompletionHandler:^(NSError *error)
    {
        NSLog(@"[Error] %@", error);
    }];
    [_fileProgress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionInitial
                  context:@"progress"];
    
}
#pragma mark - MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self.brower dismissViewControllerAnimated:YES completion:nil];
    self.brower = nil;
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self.brower dismissViewControllerAnimated:YES completion:nil];
    self.brower = nil;
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController
      shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info{
    NSLog(@"---已发现设备---peerID: %@", peerID);
    return YES;
}
#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    self.peerID = peerID;
    self.state = state;
    switch (state) {
        case MCSessionStateNotConnected:{
            NSLog(@"未连接!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [XTOOLS showMessage:@"连接断开"];
                [self->_rightBar setTitle:NSLocalizedString(@"Search", nil)];
                [XTOOLS hiddenLoading];
                self->_firstCellTitle = @"搜索周围用户";
                self->_connectedName = @"双方都打开此界面才可以搜索到";
                self->_isConnected = NO;
            });
        }
            break;
        case MCSessionStateConnecting:
        {
            NSLog(@"连接中...");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_rightBar setTitle:NSLocalizedString(@"Search", nil)];
                self->_firstCellTitle = @"连接用户中……";
                self->_connectedName = @"连接用户中……";
                self->_isConnected = NO;
            });
        }
            break;
        case MCSessionStateConnected:
        {
            NSLog(@"已连接.");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.brower) {
                    [self.brower dismissViewControllerAnimated:YES completion:nil];
                    self.brower = nil;
                }
                [self->_rightBar setTitle:@"断开"];
                self->_firstCellTitle = @"选择传输文件";
                self->_connectedName = [NSString stringWithFormat:@"已连接 %@", peerID.displayName];
                self->_isConnected = YES;
            });
            
            if (self.filePath) {
                [self sendFile:self.filePath];
            }
        }
           
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_mainTableView reloadData];
    });
}


- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{

}
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID{
    
}

- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress{
    
    if (!self.filePath) {
        self.filePath = [self.folderPath stringByAppendingPathComponent:resourceName];
//        [NSString stringWithFormat:@"%@/%@",KDocumentP,resourceName];
    }
    _isTransfering = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_mainTableView reloadData];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        [XTOOLS showLoading:@"0.0%"];
    });
    _fileProgress = progress;
    [_fileProgress addObserver:self
               forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                  options:NSKeyValueObservingOptionInitial
                  context:@"progress"];
    NSLog(@"ppp----progress:%@", progress);
}

- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error{
    
   
    if (!error) {
        NSString *path = [self.folderPath stringByAppendingPathComponent:resourceName];
//        [NSString stringWithFormat:@"%@/%@",KDocumentP,resourceName];
        
        NSURL *destinationURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] moveItemAtURL:localURL
                                                     toURL:destinationURL
                                                     error:&error]) {
            NSLog(@"[Error] %@", error);
            
        }
        
    }
    else
    {
        [XTOOLS hiddenLoading];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });

        [XTOOLS showMessage:NSLocalizedString(@"Error", nil)];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == @"progress") {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSProgress *progress = object;
            NSLog(@"pppp==%lld ==%lld == %f",progress.completedUnitCount,progress.completedUnitCount,progress.fractionCompleted);
            dispatch_async(dispatch_get_main_queue(), ^{
                [XTOOLS showLoading:[NSString stringWithFormat:@"%.f%%",progress.fractionCompleted*100]];
                if ([UIApplication sharedApplication].idleTimerDisabled != YES) {
                    [UIApplication sharedApplication].idleTimerDisabled = YES;
                }
            });
            if (progress.fractionCompleted>=1.0) {
                self->_isTransfering = NO;
                if (self->_mainTableView&&self.filePath) {
                    [self->_transferArray addObject:self.filePath.lastPathComponent];
                    self.filePath = nil;
                }
                else
                {
                    [self.assistant stop];
                    self.assistant = nil;
                    self.filePath = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [XTOOLS hiddenLoading];
                    [UIApplication sharedApplication].idleTimerDisabled = NO;
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                    [self->_mainTableView reloadData];
                    [XTOOLS umengClick:@"facecomplete"];
                    [XTOOLS showMessage:@"传输完成"];
                    if (self->_fileProgress) {
                        [self->_fileProgress removeObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                              context:@"progress"];
                        self->_fileProgress = nil;
                    }

                });
            }
        }];
    }
}

- (void)dealloc {
    if (!_isTransfering) {
        [self.assistant stop];
        self.assistant = nil;
    }
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    if ([XTOOLS showAdview]) {
        UIView *adView = [XTOOLS bannerAdViewRootViewController:self];
        adView.center = CGPointMake(kScreen_Width/2, kScreen_Height - 25);
        [self.view addSubview:adView];
        _mainTableView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-50);
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}

@end
