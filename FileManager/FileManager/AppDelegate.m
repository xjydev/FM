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
#import "UMMobClick/MobClick.h"
#import <UMSocialCore/UMSocialCore.h>
#import "GuideViewController.h"
#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>
#import "SafeView.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
{
    UIBackgroundTaskIdentifier  _bgTaskId;
}
@end
static NSString * UmengKey = @"584a67462ae85b27b7000856";
static NSString *weixinKey = @"wxf6cfb197efafda54";
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UMConfigInstance.appKey = UmengKey;
    UMConfigInstance.channelId = @"App_Store";
    [MobClick startWithConfigure:UMConfigInstance];
    
   [[UMSocialManager defaultManager] setUmSocialAppkey:UmengKey];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:weixinKey appSecret:@"ba38b1018ef912004f5fca36b0949564" redirectURL:@"http://xiaodev.cn/UlearnPlayer/"];
   [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105820767"  appSecret:@"F5vIUKEdcZdHT9L1" redirectURL:@"http://xiaodev.cn/UlearnPlayer/"];
    //推送
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [UMessage startWithAppkey:UmengKey launchOptions:launchOptions httpsenable:YES ];
    if (IOSSystemVersion>=10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate=self;
        UNAuthorizationOptions types10=UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:types10     completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                //这里可以添加一些自己的逻辑
            } else {
                //点击不允许
                //这里可以添加一些自己的逻辑
            }
        }];
    }
    

    if (![[kUSerD objectForKey:@"kversion"]isEqualToString:APP_CURRENT_VERSION]) {
        GuideViewController *guide = [[GuideViewController alloc]init];
        guide.hiddenNav = YES;
         UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:guide];
        self.window.rootViewController = nav;
        [kUSerD setObject:APP_CURRENT_VERSION forKey:@"kversion"];
    }
    //开启调试日志
   [UMessage setLogEnabled:YES];
    
    return YES;
}
#pragma mark -- 推送

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    [UIApplication sharedApplication].applicationIconBadgeNumber+=1;
    
    NSDictionary * userInfo = notification.request.content.userInfo;
//    NSLog(@"push === %@",userInfo);
//    aps =     {
//        URL = http;
//        alert =         {
//            body = urlllllllll;
//            subtitle = fubiaoti;
//            title = zhubiaoti;
//        };
//        "mutable-content" = 1;
//        sound = default;
//    };
//    d = us69331148800672501311;
//    p = 0;
    [self pushUrlWith:userInfo];
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭友盟自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    [self pushUrlWith:userInfo];
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
    
}
- (void)pushUrlWith:(NSDictionary *)userInfo {//推送对网址的处理
    if ([[userInfo objectForKey:@"aps"]objectForKey:@"URL"]) {
        NSString *title = [[[userInfo objectForKey:@"aps"]objectForKey:@"alert"]objectForKey:@"title"];
        NSString *url =[[userInfo objectForKey:@"aps"]objectForKey:@"URL"];
        if ([[XManageCoreData manageCoreData] saveWebTitle:title url:url]) {
            [UMessage setAlias:@"18up1" type:kUMessageAliasTypeSina response:^(id responseObject, NSError *error) {
            }];
        }
    }
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings

{
    [application registerForRemoteNotifications];
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    NSLog(@"device token==%@",[[NSString alloc]initWithData:deviceToken encoding:NSUTF8StringEncoding]);
    [UMessage registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"regsiter fail ==%@",error);
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"url===%@",url);
    if ([url.absoluteString hasPrefix:@"file://"]) {
        NSMutableString *path =[NSMutableString stringWithString: url.absoluteString];
        [path replaceOccurrencesOfString:@"file://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
        NSLog(@"path ==%@",path);
        NSString *toPath = [NSString stringWithFormat:@"%@/%@",KDocumentP,path.lastPathComponent];
        if ([kFileM copyItemAtPath:path toPath:toPath error:nil]) {
            [XTOOLS showMessage:@"已拷贝到应用中"];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if (![VideoAudioPlayer defaultPlayer].isVideo) {
        [[XManageCoreData manageCoreData]saveContext];
        
        //开启后台处理多媒体事件
        //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        _bgTaskId=[AppDelegate backgroundPlayerID:_bgTaskId];
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


- (void)applicationDidBecomeActive:(UIApplication *)application {
   
}
- (void)showSafeView {
    if ([kUSerD objectForKey:KPassWord]) {
        [SafeView defaultSafeView].type = PassWordTypeDefault;
        [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
            
        }];

    }
}
//远程操作播放进度，
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl&&![VideoAudioPlayer defaultPlayer].isVideo) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
            {
                [[VideoAudioPlayer defaultPlayer]play];
            }
                break;
            case UIEventSubtypeRemoteControlPause:
            {
                [[VideoAudioPlayer defaultPlayer]pause];
            }
                break;
            case UIEventSubtypeRemoteControlStop:
            {
                [[VideoAudioPlayer defaultPlayer]stop];
            }
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if ([VideoAudioPlayer defaultPlayer].isPlaying) {
                    [[VideoAudioPlayer defaultPlayer]pause];
                }
                else
                {
                    [[VideoAudioPlayer defaultPlayer]play];
                }
            }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [VideoAudioPlayer defaultPlayer].index+=1;
            }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                 [VideoAudioPlayer defaultPlayer].index -=1;
            }
                break;
           
                
            default:
                break;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //可以转屏的方向
//    NSLog(@"a == %@",@(XTOOLS.orientationMask));
    return XTOOLS.orientationMask;
}

@end
