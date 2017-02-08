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
#import "UMMobClick/MobClick.h"
#import "InfoDetailViewController.h"
#import "GuideViewController.h"
@interface SettingsTableViewController ()<MFMailComposeViewControllerDelegate,UMSocialShareMenuViewDelegate>
{
    NSArray        *_tableArray;
}
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableArray = @[@[@{@"title":@"偏好设置",@"class":@"PreferencesTableViewController"}],
  @[@{@"title":@"应用好评",@"class":@"1"},
  @{@"title":@"分享好友",@"class":@"6"},
  @{@"title":@"意见反馈",@"class":@"2"}],
  @[@{@"title":@"设备信息",@"class":@"5"},
  @{@"title":@"应用信息",@"class":@"3"},
    @{@"title":@"应用介绍",@"class":@"AboutAppViewController"},
    @{@"title":@"文件传输介绍",@"class":@"GuideViewController"}]];
    //@{@"title":@"关于我",@"class":@""},@{@"title":@"鼓励",@"class":@""},
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    
}
- (void)refreshPullUp:(UIRefreshControl *)control {
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
    cell.textLabel.text = dict[@"title"];
    if ([dict[@"class"]integerValue] == 3) {
        NSString *version = [NSString stringWithFormat:@"V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        cell.detailTextLabel.text = version;
    }
    else
        if ([dict[@"class"]integerValue] == 5) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@",[XTOOLS storageSpaceStringWith:[XTOOLS freeStorageSpace]],[XTOOLS storageSpaceStringWith:[XTOOLS allStorageSpace]]];
        }
       
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _tableArray[indexPath.section][indexPath.row];
    if ([dict[@"class"] integerValue] == 1) {
        NSString *appleID = @"1184757517";
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
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
                [XTOOLS showMessage:@"此设备不支持邮件发送"];
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
       
        NSString *title = @"悦览播放器-无广告、无内购、好用的视频音频播放器";
        NSString *descr = @"悦览播放器-无广告、无内购、好用的视频音频播放器。支持所有的主流视频音频格式，支持无线局域网传输，iTunes数据线传输。https://itunes.apple.com/cn/app/id1184757517?mt=8";
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

@end
