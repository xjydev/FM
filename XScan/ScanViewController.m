//
//  ScanViewController.m
//  QRcreate
//
//  Created by xiaodev on Mar/25/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QRCodeReaderView.h"
#import "XTools.h"
#import "WebViewController.h"
//#import "SotorageManager.h"
#import "PasteViewController.h"
#import "ContactViewController.h"
#import "WiFiViewController.h"
#import "ScanCircleListController.h"
//#import <ZXingObjC/ZXingObjC.h>
@interface ScanViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    QRCodeReaderView * readview;//二维码扫描对象
    
//    BOOL isFirst;//第一次进入该页面
//    BOOL isPush;//跳转到下一级页面
    
//    UITableView    *_listTableView;
    
}
@property (strong, nonatomic) CIDetector *detector;
@end

@implementation ScanViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"XScan" bundle:nil];
    ScanViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"ScanViewController"];
    return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Scan", nil);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    
    UIBarButtonItem * rbbItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"photos", nil) style:UIBarButtonItemStyleDone target:self action:@selector(alumbBtnEvent)];
    self.navigationItem.rightBarButtonItem = rbbItem;
    
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert", nil) message:@"此设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"do", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [aler addAction:cancelAction];
        [self presentViewController:aler animated:YES completion:nil];
        return;
    }
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"开启相机权限" message:@"请开启此应用访问您相机的权限，才能进行二维码扫描。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [aler addAction:cancelAction];
        [aler addAction:sureAction];
        [self presentViewController:aler animated:YES completion:nil];
        return;
        
    }
    
    
    
    [self InitScan];
}
- (void)backBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[QRCodeReaderView alloc]initWithFrame:self.view.bounds];
    //    readview.is_AnmotionFinished = YES;
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        self->readview.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    
//    [self performSegueWithIdentifier:@"PhotoSelectViewController" sender:nil];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert", nil) message:@"未开启访问相册权限，现在去开启！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"do", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [aler addAction:cancelAction];
        [aler addAction:sureAction];
        [self presentViewController:aler animated:YES completion:nil];
        
        return;
    }
    
//    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        //  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    NSArray *features = [self.detector featuresInImage:ciImage];
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
//            if (![kUSerD boolForKey:kSound]) {
//                SystemSoundID soundID =0;
//                NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
//                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//                AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
//                AudioServicesPlaySystemSound(soundID);
//            }
            
            [self accordingQcode:scannedResult];
        }];
        
    }
    else{
        
        
        [picker dismissViewControllerAnimated:YES completion:^{
            // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            [self->readview start];
            
            UIAlertController *aler = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert", nil) message:@"未识别出二维码/条形码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"do", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [aler addAction:cancelAction];
            [self presentViewController:aler animated:YES completion:nil];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(NSString *)result
{
    //播放扫描二维码的声音
    
    [readview stop];
//    [XTOOLS umengClickEvent:@"scaned"];
    [self accordingQcode:result];
    
}
- (void)readerCircleScanResults:(NSArray *)results {
    if (results.count>0) {
        [self performSegueWithIdentifier:@"ScanCircleListController" sender:results];
    }
}
void soundCompleteCallback(SystemSoundID soundID,void * clientData)
{
    NSLog(@"播放完成...");
    
    AudioServicesRemoveSystemSoundCompletion(soundID);
}
#pragma mark - delegate 扫描结果处理
- (void)accordingQcode:(NSString *)str
{
    NSLog(@"qr ==%@",str);
//    [[SotorageManager manageCoreData]saveScanHistory:str];
    //判断是否是网址
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:str]]) {
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.urlStr = str;
        webViewController.noBackRoot = NO;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    else if ([str hasPrefix:@"WIFI:"]){
       [self performSegueWithIdentifier:@"WiFiViewController" sender:str];
    }
    else
        if ([str hasPrefix:@"MECARD:"]) {
            [self performSegueWithIdentifier:@"ContactViewController" sender:str];
        }
        else
        {
            [self performSegueWithIdentifier:@"PasteViewController" sender:str];
            
        }
}

- (void)reStartScan
{
    
    [readview start];
}

#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
//    if (isFirst || isPush) {
        if (readview) {
            [self reStartScan];
        }
//    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
    if (readview) {
        [readview stop];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if (isFirst) {
//        isFirst = NO;
//    }
//    if (isPush) {
//        isPush = NO;
//    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WiFiViewController"]) {
        WiFiViewController *paste = segue.destinationViewController;
        paste.wifiStr = sender;
    }
    else
        if ([segue.identifier isEqualToString:@"ContactViewController"]) {
            ContactViewController *contact = segue.destinationViewController;
            contact.contactStr = sender;
        }
    else
        if([segue.identifier isEqualToString:@"PasteViewController"])
    {
        PasteViewController *paste = segue.destinationViewController;
        paste.pasteStr = sender;
    }
    else
        if ([segue.identifier isEqualToString:@"ScanCircleListController"]) {
            ScanCircleListController *circle = segue.destinationViewController;
            circle.listArray = [NSMutableArray arrayWithArray:sender];
        }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
