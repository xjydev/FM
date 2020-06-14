//
//  DrawerViewController.m
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "DrawerViewController.h"
#import "AppInfoTableViewController.h"
#import "PreferencesTableViewController.h"
#import "RecordViewController.h"
#import "RewardViewController.h"
#import "PravicyViewController.h"
#import "LeftViewController.h"
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import "XTools.h"
#import "ShareView.h"
@interface DrawerViewController ()<MFMailComposeViewControllerDelegate>
{
    
}
@property (nonatomic, strong) UIViewController *mainVC;
@property (nonatomic, strong) LeftViewController *leftVC;
@property (nonatomic, assign) CGFloat leftWidth;
@property (nonatomic, strong) UIButton *coverBtn;
@end

@implementation DrawerViewController
+ (instancetype)shareDrawer {
    return (DrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}
- (instancetype)initMainVC:(UIViewController *)mainVC leftVC:(LeftViewController *)leftVC leftWidth:(CGFloat)leftWidth {
    self = [super init];
    self.mainVC = mainVC;
    self.leftVC = leftVC;
    self.leftWidth = leftWidth;
    [self.view addSubview:self.leftVC.view];
    [self.view addSubview:self.mainVC.view];
    [self addChildViewController:self.leftVC];
    [self addChildViewController:self.mainVC];
    return self;
}
- (UIButton *)coverBtn {
    if (!_coverBtn) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverBtn.backgroundColor = [UIColor clearColor];
        _coverBtn.frame = self.mainVC.view.bounds;
        [_coverBtn addTarget:self action:@selector(closeLeftMenu) forControlEvents:UIControlEventTouchUpInside];
        [_coverBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panCloseLeftMenu:)]];
    }
    return _coverBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftVC.view.transform = CGAffineTransformMakeTranslation(-250, 0);
//    for (UIViewController *childVC in self.mainVC.childViewControllers) {
//        [self addScreenEdgePanGestureRecognizerToView:childVC.view];
//    }
    if ([self.mainVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *mainNav = (UINavigationController *)self.mainVC;
      [self addScreenEdgePanGestureRecognizerToView:mainNav.topViewController.view];
    }
    else {
      [self addScreenEdgePanGestureRecognizerToView:self.mainVC.view];
    }
}
- (void)addScreenEdgePanGestureRecognizerToView:(UIView *)view {
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(edgePanGesture:)];
    pan.edges = UIRectEdgeLeft;
    [view addGestureRecognizer:pan];
}

- (void)panCloseLeftMenu:(UIPanGestureRecognizer *)pan {
    float offsetX = [pan translationInView:pan.view].x;
    if (offsetX >0) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateChanged && offsetX >= -self.leftWidth ) {
        
        self.mainVC.view.transform = CGAffineTransformMakeTranslation(self.leftWidth + offsetX, 0);
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(offsetX*0.6, 0);
    }
    else
        if (pan.state == UIGestureRecognizerStateEnded ||pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
            if (offsetX > kScreen_Width *0.4 ) {
                [self openLeftMenu];
            }
            else {
                [self closeLeftMenu];
            }
        }
}
- (void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)pan {
    float offsetX = [pan translationInView:pan.view].x;
    if (pan.state == UIGestureRecognizerStateChanged && offsetX <= self.leftWidth ) {
        self.mainVC.view.transform = CGAffineTransformMakeTranslation(MAX(offsetX, 0), 0);
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(offsetX - self.leftWidth, 0);
    }
    else if (pan.state == UIGestureRecognizerStateEnded ||pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        if (offsetX > kScreen_Width *0.4 ) {
            [self openLeftMenu];
        }
        else {
            [self closeLeftMenu];
        }
    }
}
- (void)openLeftMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(0, 0);
        [self.leftVC willShow];
        self.mainVC.view.transform = CGAffineTransformMakeTranslation(self.leftWidth, 0);
    } completion:^(BOOL finished) {
        [self.mainVC.view addSubview:self.coverBtn];
    }];
}
- (void)closeLeftMenu {
    [self.leftVC viewWillAppear:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth, 0);
        self.mainVC.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.coverBtn removeFromSuperview];
    }];
}
- (void)leftViewDidSelectedtag:(NSInteger )tag {
    UINavigationController *Nav = (UINavigationController *)self.mainVC;
    switch (tag) {
        case 1: {
            PreferencesTableViewController *VC = [PreferencesTableViewController viewControllerStroyBoard];
            [Nav pushViewController:VC animated:YES];
        }
            break;
        case 2: {
            AppInfoTableViewController *VC = [[AppInfoTableViewController alloc]init];
            [Nav pushViewController:VC animated:YES];
        }
            break;
        case 3://分享好友
        {
            NSString *urlstr = [NSString stringWithFormat: @"https://apps.apple.com/cn/app/id%@",kAppleId];
           [[ShareView shareView]shareViewWithTitle:@"简单播放App Store地址：" Detail:urlstr Image:[UIImage imageNamed:@"appQR"] Types:XShareTypeWeChat,XShareTypeTimeLine,XShareTypeQQ,XShareTypeQzone,XShareTypeCopy,XShareTypeEnd];
        }
            break;
        case 4:
        {
            [self gotoSendMail];
        }
            break;
        case 5:
        {
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",kAppleId];
            [XTOOLS openURLStr:str];
        }
            break;
        case 6:
        {
            RecordViewController *VC = [RecordViewController allocFromStoryBoard];
            [Nav pushViewController:VC animated:YES];
        }
            break;
        case 7:
        {
            RewardViewController *VC = [RewardViewController allocFromStoryBoard];
            [Nav pushViewController:VC animated:YES];
        }
            break;
        case 8:
        {
            if ([kUSerD boolForKey:kENTRICY]) {
                PravicyViewController *VC = [PravicyViewController allocFromStoryBoard];
                [Nav pushViewController:VC animated:YES];
            }
            else {
                [XTOOLS showAlertTitle:@"订阅功能" message:@"文件加密需要订阅会员才可以使用" buttonTitles:@[@"取消",@"订阅"] completionHandler:^(NSInteger num) {
                    if (num == 1) {
                        RewardViewController *VC = [RewardViewController allocFromStoryBoard];
                        [Nav pushViewController:VC animated:YES];
                    }
                }];
            }
            
        }
            break;
            
        default:
            break;
    }
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
        [mailVC setSubject:@"简单播放意见反馈"];
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
