//
//  AppDelegate.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "AppDelegate.h"
#import "XTools.h"
#import "XManageCoreData.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoAudioPlayer.h"

#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <UMShare/UMShare.h>
#import <UMAnalytics/MobClick.h>
#import <UserNotifications/UserNotifications.h>

#import "XTabBarViewController.h"
#include <arpa/inet.h>
#import "SafeView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "NewVideoViewController.h"
#import "WebViewController.h"

#import "MainViewController.h"
#import "LeftViewController.h"
#import "DrawerViewController.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
{
    UIBackgroundTaskIdentifier  _bgTaskId;
    BOOL             _isPlaying;//进入后台时，是否在播放。
}
@property (nonatomic, strong)UINavigationController *mainNav;
@end
static NSString * UmengKey = @"59e949a9310c9377ca00004f";
static NSString *weixinKey = @"wx5154b98421f54f1d";
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UMConfigure setLogEnabled:YES];
    [UMConfigure initWithAppkey:UmengKey channel:@"App Store"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:weixinKey appSecret:@"08fc1ab787560d841da35e1084610661" redirectURL:@"https://itunes.apple.com/cn/app/id1241120027?mt=8"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106398567"  appSecret:@"JfVujDEipiVzCyKx" redirectURL:@"https://itunes.apple.com/cn/app/id1241120027?mt=8"];
    
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    } else {
        // Fallback on earlier versions
    }
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }else{
        }
    }];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    NSLog(@"status ==%@",@([UIApplication sharedApplication].statusBarFrame.size.height));
    UIStoryboard *mainStoryB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LeftViewController *leftVC = [mainStoryB instantiateViewControllerWithIdentifier:@"LeftViewController"];
    self.mainNav = [mainStoryB instantiateViewControllerWithIdentifier:@"MainNav"];
    self.window.rootViewController = [[DrawerViewController alloc]initMainVC:self.mainNav leftVC:leftVC leftWidth:250];
    [self.window makeKeyAndVisible];
  
    [GADMobileAds.sharedInstance startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
        
    }];
    [self showSafeView];
    return YES;
}
#pragma mark -- 推送
//iOS10以下使用这两个方法接收通知
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    [UMessage setAutoAlert:YES];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"push 2 == %@",userInfo);
        //应用处于前台时的远程推送接受
        //必须加这句代码
//        [UMessage didReceiveRemoteNotification:userInfo];
        [self pushUserInfo:userInfo];
    }else{
        [self pushUserInfo:userInfo];
        NSLog(@"push 1 == %@",userInfo);
    }
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
//        [UMessage didReceiveRemoteNotification:userInfo];
        [self pushUserInfo:userInfo];
    }else{
        NSLog(@"push == %@",userInfo);
        [self pushUserInfo:userInfo];
        //应用处于后台时的本地推送接受
    }
}
- (void)pushUserInfo:(NSDictionary *)userInfo {
    NSString *url = [userInfo objectForKey:@"url"];
    NSString *title = [userInfo objectForKey:@"title"];
    [[XManageCoreData manageCoreData] saveWebTitle:title url:url];
    [XTOOLS showAlertTitle:title message:@"可以在右上角“网页搜索”-“收藏”中查看" buttonTitles:@[@"取消",@"查看"] completionHandler:^(NSInteger num) {
        if (num == 1) {
            WebViewController *web = [[WebViewController alloc]init];
            web.hidesBottomBarWhenPushed = YES;
            web.urlStr = url;
            [self.mainNav pushViewController:web animated:YES];
            [XTOOLS umengClick:@"notiflook"];
        }
        else {
            [XTOOLS umengClick:@"notifcancel"];
        }
    }];
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken:%@",hexToken);
}
#pragma mark -- 文件拷贝
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
   if ([url.absoluteString hasPrefix:@"file://"]) {
        NSString *rePath =[[url.absoluteString stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];

        NSString *toPath  = [KDocumentP stringByAppendingPathComponent:rePath.lastPathComponent];
        NSLog(@"pat == %@ \ntopath == %@",url.absoluteString,toPath);
        NSError *error = nil;
      BOOL is = [kFileM copyItemAtURL:url toURL:[NSURL fileURLWithPath:toPath] error:&error];
        if (is) {
            [XTOOLS playFileWithPath:toPath OrigionalWiewController:self.window.rootViewController];
            //            [XTOOLS showMessage:@"已拷贝到应用中"];
            [XTOOLS showAlertTitle:@"已拷贝到应用中" message:@"可以在应用中寻找，打开浏览。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {

            }];
        }
        else {
          NSLog(@"copy ==%@",error);
        }
    }
    return YES;
}
//进入前台,变的活跃
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([kUSerD objectForKey:KPassWord]) {//如果没有密码就播放
        return;
    }
    if ([VideoAudioPlayer defaultPlayer].isVideo&&_isPlaying) {//如果是视频，并且进入后台时是播放状态就播放。
        _isPlaying = NO;
        
        [[VideoAudioPlayer defaultPlayer] play];
        if ([VideoAudioPlayer defaultPlayer].backTime >0) {
            [[VideoAudioPlayer defaultPlayer] jumpBackward:[VideoAudioPlayer defaultPlayer].backTime];
            [VideoAudioPlayer defaultPlayer].backTime = 0;
        }
    }
}
//进入后台
- (void)applicationWillResignActive:(UIApplication *)application {
    if ([VideoAudioPlayer defaultPlayer].currentPath) {//如果有播放就做暂停或者继续播放的操作
        if (![VideoAudioPlayer defaultPlayer].isVideo) {
            AVAudioSession *session=[AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            [session setActive:YES error:nil];
            //允许应用程序接收远程控制
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            _bgTaskId=[AppDelegate backgroundPlayerID:_bgTaskId];
        }
        else
        {
            if ([VideoAudioPlayer defaultPlayer].isPlaying) {
                _isPlaying = YES;
                [[VideoAudioPlayer defaultPlayer] pause];
                [VideoAudioPlayer defaultPlayer].backTime = 3;
            }
            
        }
    }
}
//实现一下backgroundPlayerID:这个方法:
+(UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId
{
    //设置并激活音频会话类别
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    //允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self showSafeView];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
   
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

/**
 显示安全锁界面
 */
- (void)showSafeView {
    if ([kUSerD objectForKey:KPassWord]) {
        [SafeView defaultSafeView].type = PassWordTypeDefault;
        [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
            
        }];

    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //如果是iPad都支持转屏，如果是iPhone只有播放界面支持转屏。
    
    if (IsPad||[window.rootViewController.presentedViewController isKindOfClass:[NewVideoViewController class]]) {
        
            return UIInterfaceOrientationMaskAll;
    }

    return UIInterfaceOrientationMaskPortrait;
}
/// Tells the delegate an ad request succeeded.
@end
