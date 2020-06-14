//
//  SettingsTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "XTools.h"
#import <MessageUI/MessageUI.h>
#import <UShareUI/UShareUI.h>
#import "InfoDetailViewController.h"
#import "GuideViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <StoreKit/StoreKit.h>
#import "FormatConverViewController.h"
#import "FaceConnectController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "RecordViewController.h"
#import "PravicyViewController.h"
@interface SettingsTableViewController ()<MFMailComposeViewControllerDelegate,UMSocialShareMenuViewDelegate,TZImagePickerControllerDelegate>
{
    NSArray        *_tableArray;
    UIView         *_headerView;
    BOOL      _nocommentShow;
    BOOL      _nobuyShow;
    
}
@property (nonatomic, assign)NSInteger nameNum;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.tabBarItem.badgeValue = nil;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [self refreshPullUp:refresh];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
   
    
    
}
// @{@"title":NSLocalizedString(@"High praise", nil),@"class":@"1"},
- (void)refreshPullUp:(UIRefreshControl *)control {
    if ([kUSerD boolForKey:kSettingParvicy]) {
        _tableArray = @[@[@{@"title":NSLocalizedString(@"Recents", nil),@"class":@"7"},
  @{@"title":NSLocalizedString(@"Settings", nil),@"class":@"PreferencesTableViewController"},
                 @{@"title":NSLocalizedString(@"Encrypted", nil),@"class":@"9"}],
                        @[@{@"title":NSLocalizedString(@"Purchasing", nil),@"class":@"4"},
                          @{@"title":NSLocalizedString(@"Share", nil),@"class":@"6"},
                          @{@"title":NSLocalizedString(@"FeedBack", nil),@"class":@"2"},
                          @{@"title":NSLocalizedString(@"Weibo", nil),@"class":@"8"},
                         ],
                        @[@{@"title":NSLocalizedString(@"About Device", nil),@"class":@"5"},
                          @{@"title":NSLocalizedString(@"About App", nil),@"class":@"3"},
                          @{@"title":NSLocalizedString(@"Introduce", nil),@"class":@"AboutAppViewController"},
                          @{@"title":NSLocalizedString(@"Tansfer", nil),@"class":@"GuideViewController"}]];
    }
    else
    {
//  @{@"title":NSLocalizedString(@"High praise", nil),@"class":@"1"},
        _tableArray = @[@[@{@"title":NSLocalizedString(@"Recents", nil),@"class":@"7"},
  @{@"title":NSLocalizedString(@"Settings", nil),@"class":@"PreferencesTableViewController"}],
                        @[@{@"title":NSLocalizedString(@"Purchasing", nil),@"class":@"4"},
                          @{@"title":NSLocalizedString(@"Share", nil),@"class":@"6"},
                          @{@"title":NSLocalizedString(@"FeedBack", nil),@"class":@"2"},
                          @{@"title":NSLocalizedString(@"Weibo", nil),@"class":@"8"},
                          @{@"title":NSLocalizedString(@"High praise", nil),@"class":@"1"},
                          ],
                        @[@{@"title":NSLocalizedString(@"About Device", nil),@"class":@"5"},
                          @{@"title":NSLocalizedString(@"About App", nil),@"class":@"3"},
                          @{@"title":NSLocalizedString(@"Introduce", nil),@"class":@"AboutAppViewController"},
                          @{@"title":NSLocalizedString(@"Tansfer", nil),@"class":@"GuideViewController"}]];
    }
    
    
    [self.tableView reloadData];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}

- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _tableArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _tableArray[section];
     return array.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    NSDictionary *dict =_tableArray[indexPath.section][indexPath.row];
    UILabel *label1= [cell.contentView viewWithTag:301];
    UILabel *label2 = [cell.contentView viewWithTag:302];
    UIView  *tagView = [cell.contentView viewWithTag:303];
    label1.text = dict[@"title"];
    if ([dict[@"class"]integerValue] == 3) {
        NSString *version = [NSString stringWithFormat:@"V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        label2.text = version;
        tagView.hidden = YES;
        
    }
    else
        if ([dict[@"class"]integerValue] == 5) {
            label2.text = [NSString stringWithFormat:@"%@/%@",[XTOOLS storageSpaceStringWith:[XTOOLS freeStorageSpace]],[XTOOLS storageSpaceStringWith:[XTOOLS allStorageSpace]]];
            tagView.hidden = YES;
        }
    else
        if ([dict[@"class"]integerValue] == 1) {//好评
          label2.text = @"";
            if (_nocommentShow) {
                tagView.hidden = YES;
            }
            else
            {
               tagView.hidden = ([kUSerD integerForKey:@"appstorecomment"]>6);
            }
           
        }
    else
        if ([dict[@"class"]integerValue] == 4) {//去广告
           label2.text = @"";
            if (_nobuyShow) {
                tagView.hidden = YES;
            }
            else
            {
                if (![XTOOLS showAdview]||[kUSerD boolForKey:kENTRICY]) {
                  tagView.hidden = YES;
                }
                else {
                  tagView.hidden = NO;
                }
            }
            
        }
    else
    {
       label2.text = @"";
        tagView.hidden = YES;
    }
       
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = _tableArray[indexPath.section][indexPath.row];
    
    if ([dict[@"class"] integerValue] == 1) {
        _nocommentShow = YES;
        [XTOOLS umengClick:@"comment"];
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",kAppleId];
        [XTOOLS openURLStr:str];
        [self performSelector:@selector(commented) withObject:nil afterDelay:10];
        [self.tableView reloadData];
        
    }
    else
        if ([dict[@"class"] integerValue] == 2) {
            if ([MFMailComposeViewController canSendMail] == YES) {
                
                MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
                //  设置代理(与以往代理不同,不是"delegate",千万不能忘记呀,代理有3步)
                mailVC.mailComposeDelegate = self;
                //  收件人
                NSArray *sendToPerson = @[@"xiaodeve@163.com"];
                [mailVC setToRecipients:sendToPerson];
                //  主题
                [mailVC setSubject:@"悦览播放意见反馈"];
                [self presentViewController:mailVC animated:YES completion:nil];
                [mailVC setMessageBody:@"填写您想要反馈的问题……" isHTML:NO];
            }else{
                [XTOOLS showAlertTitle:@"此设备不支持邮件发送" message:@"你可以用其他方式发送信息到邮箱“xiaodeve@163.com”，或者设置登录手机邮箱。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                    
                }];
                NSLog(@"此设备不支持邮件发送");
            }
        }
        else
            if ([dict[@"class"] integerValue] == 3) {//应用版本
                InfoDetailViewController *info = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoDetailViewController"];
                info.type = InfoDetailTypeApp;
                info.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:info animated:YES];
            }
        else
            if ([dict[@"class"] integerValue] == 4) {//购买去广告
                _nobuyShow = YES;
                [self performSegueWithIdentifier:@"RewardViewController" sender:nil];
                [self.tableView reloadData];
            }
    else
        if ([dict[@"class"] integerValue] == 5) {//存储空间
            InfoDetailViewController *info = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoDetailViewController"];
            info.type = InfoDetailTypeDevice;
            info.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:info animated:YES];
        }
    else
        if ([dict[@"class"] integerValue] == 6) {
            [self shareAppContent];
        }
    else
        if ([dict[@"class"] integerValue] == 7) {
            RecordViewController *VC = [RecordViewController allocFromStoryBoard];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
    else
        if ([dict[@"class"] integerValue] == 8) {
            [XTOOLS openURLStr:@"https://weibo.com/u/7170153013"];
        }
    else
        if ([dict[@"class"] integerValue] == 9) {
            UIStoryboard *mediaS = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
            PravicyViewController *VC = [mediaS instantiateViewControllerWithIdentifier:@"PravicyViewController"];
            VC.hidesBottomBarWhenPushed = YES;
            VC.title =dict[@"title"];
            [self.navigationController pushViewController:VC animated:YES];
        }

    else
        if ([dict[@"class"] integerValue] <= 0) {
            if (((NSString *)dict[@"class"]).length>0) {
                UIViewController *subSetViewController = [self.storyboard instantiateViewControllerWithIdentifier:dict[@"class"]];
                subSetViewController.hidesBottomBarWhenPushed = YES;
                subSetViewController.title = dict[@"title"];
                [self.navigationController pushViewController:subSetViewController animated:YES];
            }
        }
    
}
- (void)shareAppContent {
    
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_QQ),
                                               @(UMSocialPlatformType_Qzone),
                                               @(UMSocialPlatformType_WechatSession),
                                               @(UMSocialPlatformType_WechatTimeLine),
                                               @(UMSocialPlatformType_Sms),
                                               @(UMSocialPlatformType_Email),
                                               @(UMSocialPlatformType_WechatFavorite),
                                               @(UMSocialPlatformType_TencentWb),]];
    [UMSocialUIManager setShareMenuViewDelegate:self];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
       
        NSString *title = @"悦览播放器-好用的视频音频播放器";
        NSString *descr = @"悦览播放器-好用的视频音频播放器。支持所有的主流视频音频格式，支持无线局域网传输，iTunes数据线传输。https://itunes.apple.com/cn/app/id1184757517?mt=8";
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        messageObject.title = title;
        //设置文本
        messageObject.text = descr;
        
        //创建图片内容对象
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        
        shareObject.thumbImage = [UIImage imageNamed:@"Player3QR"];
        shareObject.shareImage = [UIImage imageNamed:@"Player3QR"];
//
//        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
        
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
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            [XTOOLS showMessage:@"发送失败"];
            break;
    }
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}
//评论惊喜，如果十秒后用户不是活跃状态就说他在评论。
- (void)commented {
    
    
    if ([UIApplication sharedApplication].applicationState ==UIApplicationStateBackground) {
        [XTOOLS umengClick:@"comover"];
        [kUSerD setInteger:300 forKey:@"appstorecomment"];
        [kUSerD synchronize];
    }
    else
    {
        [XTOOLS showAlertTitle:@"评论失败" message:@"也许是您评论的太短了，再重新评论个长的试试。" buttonTitles:@[@"算了",@"再试试"] completionHandler:^(NSInteger num) {
            if (num == 1) {
                NSString *appleID = kAppleId;
                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str] options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
                }
                //                 [kUSerD setInteger:-200 forKey:@"appstorecomment"];
                [self performSelector:@selector(commented) withObject:nil afterDelay:10];
               

            }
            else
            {
                [kUSerD setInteger:0 forKey:@"appstorecomment"];
                [kUSerD synchronize];
            }
        }];
    }
}
#pragma mark - UMSocialShareMenuViewDelegate
- (void)UMSocialShareMenuViewDidAppear
{
    NSLog(@"UMSocialShareMenuViewDidAppear");
}
- (void)UMSocialShareMenuViewDidDisappear
{
    [self.tableView reloadData];
    NSLog(@"UMSocialShareMenuViewDidDisappear");
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"Settings"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Settings"];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
- (IBAction)formatConvertButtonAction:(id)sender {
    FormatConverViewController *VC = [FormatConverViewController allocFromStoryBoard];
    [self.navigationController pushViewController:VC animated:YES];
}
- (IBAction)photoImportButtonAction:(id)sender {
//    PhotoImportViewController *VC = [PhotoImportViewController allocFromStoryBoard];
//    [self.navigationController pushViewController:VC animated:YES];
    NSInteger columnNum = kScreen_Width/80;
   TZImagePickerController *pickerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:10000 columnNumber:columnNum delegate:self pushPhotoPickerVc:YES];
    pickerVC.isSelectOriginalPhoto = YES;
    pickerVC.allowTakeVideo = YES;
    pickerVC.allowTakePicture = YES;
    [pickerVC setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    pickerVC.allowPickingMultipleVideo = YES;
    pickerVC.sortAscendingByModificationDate = YES;
    pickerVC.showSelectBtn = NO;
    @weakify(self);
    [pickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        @strongify(self);
        [self importPhotoWithArray:assets];
        
    }];
    
    pickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pickerVC animated:YES completion:^{
        
    }];
}
- (void)importPhotoWithArray:(NSArray *) arr {
    [XTOOLS showLoading:@"导入中"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        self.nameNum = [kUSerD integerForKey:@"userdNameNum"];
        for (int i=0;i< arr.count;i++) {
            @autoreleasepool {
                PHAsset *phAsset = arr[i];;

                if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
                    options.networkAccessAllowed = YES;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {

                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            NSURL *pathUrl = ((AVURLAsset *)asset).URL;
                            //                        asset.availableChapterLocales
                            NSString *name =[pathUrl.absoluteString lastPathComponent];
                            if (!name) {
                                self.nameNum ++;
                                name =[NSString stringWithFormat:@"相册视频%d.mov",(int)self.nameNum];
                            }
                            int pa = 1;
                            NSString *pName = name;
                            while ([kFileM fileExistsAtPath:[KDocumentP stringByAppendingPathComponent:pName]]) {
                                pName = [NSString stringWithFormat:@"%@(%d).%@",name.stringByDeletingPathExtension,pa,name.pathExtension];
                                pa++;
                            }
                            name = pName;
                            NSError *error;
                            NSData *moveData = [NSData dataWithContentsOfURL:pathUrl];
                            [moveData writeToFile:[KDocumentP stringByAppendingPathComponent:name] atomically:YES];
                            moveData = nil;
                            if(error){
                                NSLog(@"error == %@",error);
                            }
                        } else {

                        }
                    }];
                }
                else {
                    PHImageRequestOptions *options = [PHImageRequestOptions new];
                    options.networkAccessAllowed = YES;
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    options.synchronous = YES;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {

                    };

                    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                        NSData *imageData ;
                        NSString *imageType;
                        if (UIImagePNGRepresentation(result)) {
                            imageData = UIImagePNGRepresentation(result);
                            imageType = @".png";
                        }
                        else {
                            imageData = UIImageJPEGRepresentation(result, 1.0);
                            imageType = @".jpg";
                        }
                        self.nameNum++;
                        NSString *imagePath = [NSString stringWithFormat:@"%@/相册%d%@",KDocumentP,(int)self.nameNum,imageType];
                        [imageData writeToFile:imagePath  atomically:YES];
                        imageData = nil;
                    }];

                }

            }
            [XTOOLS showLoading:[NSString stringWithFormat:@"%d/%d",i,(int)arr.count]];

        }
        //结束后就保存以前的相册名称序列，防止以后的重名，然后刷新。

       
        if (self.nameNum > 999999) {
            self.nameNum = 0;
        }
        [kUSerD setInteger:self.nameNum forKey:@"userdNameNum"];
        [kUSerD synchronize];
    });
    //完成后通知
    dispatch_group_notify(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [XTOOLS hiddenLoading];
            [XTOOLS showAlertTitle:@"完成" message:@"选择的资源已经导入到应用中，可以在文件列表中查看。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
            }];
        });
    });
}
- (IBAction)faceTransferButtonAction:(id)sender {
    FaceConnectController *VC = [FaceConnectController allocFromStoryBoard];
    [self.navigationController pushViewController:VC animated:YES];
}


@end
