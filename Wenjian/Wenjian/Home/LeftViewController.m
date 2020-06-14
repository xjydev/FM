//
//  LeftViewController.m
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "LeftViewController.h"
#import "DrawerViewController.h"
#import "XTools.h"
#import "MarkViewController.h"
#import "RecordViewController.h"
#import "RewardViewController.h"
#import "InfoDetailViewController.h"
#import "PreferencesTableViewController.h"
#import "SortViewController.h"
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import "UIView+badgeValue.h"

#define cellId @"leftcellId"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong)NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kMainCOLOR;
    self.dataArray = @[@{@"应用设置":@"sidebar_secret"},@{@"文件排序":@"sidebar_sort"},@{@"应用好评":@"sidebar_comment"},@{@"去除广告":@"sidebar_ad"},@{@"问题反馈":@"sidebar_feedback"},@{@"关于应用":@"sidebar_app"},@{@"关于设备":@"sidebar_device"}];
}
- (IBAction)markButtonAction:(id)sender {
    MarkViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"MarkViewController"];
    VC.title = @"标记文件";
    [[DrawerViewController shareDrawer]pushViewController:VC];
}
- (IBAction)recordButtonAction:(id)sender {
    RecordViewController *VC = [RecordViewController allocFromStoryBoard];
    VC.title = @"浏览记录";
    [[DrawerViewController shareDrawer]pushViewController:VC];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *dict = self.dataArray[indexPath.row];
    cell.textLabel.text = dict.allKeys.firstObject;
    [cell.imageView setImage:[UIImage imageNamed:dict.allValues.firstObject]];
    if ([dict.allValues.firstObject isEqual:@"sidebar_ad"]) {
        if ([kUSerD boolForKey:kpaystart]) {
          [cell.imageView setAbBadgeValue:@"0"];
        }
        else {
           [cell.imageView setAbBadgeValue:@""];
        }
    }
    else if ([dict.allValues.firstObject isEqual:@"sidebar_comment"]) {
        if ([kUSerD boolForKey:@"kgocommit"]) {
          [cell.imageView setAbBadgeValue:@"0"];
        }
        else {
          [cell.imageView setAbBadgeValue:@""];
        }
    }
    else {
        [cell.imageView setAbBadgeValue:@"0"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataArray[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        PreferencesTableViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"PreferencesTableViewController"];
        VC.title = dict.allKeys.firstObject;
        [[DrawerViewController shareDrawer]pushViewController:VC];
    }
    else
        if (indexPath.row == 1) {
            SortViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"SortViewController"];
            VC.title = dict.allKeys.firstObject;
            [[DrawerViewController shareDrawer]pushViewController:VC];
        }
        else
            if (indexPath.row == 2) {
                [cell.imageView setAbBadgeValue:@"0"];
                [self gotoComment];
            }
            else
                if (indexPath.row == 3) {
                    [cell.imageView setAbBadgeValue:@"0"];
                    RewardViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"RewardViewController"];
                    VC.title = dict.allKeys.firstObject;
                    [[DrawerViewController shareDrawer]pushViewController:VC];
                }
                else
                    if (indexPath.row == 4) {
                        [self gotoSendMail];
                    }
                    else
                        if (indexPath.row == 5 || indexPath.row == 6 ) {
                            InfoDetailViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoDetailViewController"];
                            VC.title = dict.allKeys.firstObject;
                            VC.type = indexPath.row == 5?0:1;
                            [[DrawerViewController shareDrawer]pushViewController:VC];
                        }
    
}
- (void)gotoComment {
    [kUSerD setBool:YES forKey:@"kgocommit"];
    [kUSerD synchronize];
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",kAppleId];
    [XTOOLS openURLStr:str];
    
}
- (void)gotoSendMail {
    if ([MFMailComposeViewController canSendMail] == YES) {
        
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        //  设置代理(与以往代理不同,不是"delegate",千万不能忘记呀,代理有3步)
        mailVC.mailComposeDelegate = self;
        //  收件人
        NSArray *sendToPerson = @[@"xiaodeve@163.com"];
        [mailVC setToRecipients:sendToPerson];
        //  主题
        [mailVC setSubject:@"保密文件意见反馈"];
        [self presentViewController:mailVC animated:YES completion:nil];
        [mailVC setMessageBody:@"填写您想要反馈的问题……" isHTML:NO];
    }else{
        [XTOOLS showAlertTitle:@"此设备不支持邮件发送" message:@"您可以使用其他方式发送信息到邮箱：xiaodeve@163.com,或者设置登录手机邮箱再次操作" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
        NSLog(@"此设备不支持邮件发送");
    }
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IsPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL)shouldAutorotate {
    return YES;
}

@end
