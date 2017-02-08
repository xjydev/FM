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
@interface AppDelegate ()
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
    if (![[kUSerD objectForKey:@"kversion"]isEqualToString:APP_CURRENT_VERSION]) {
        GuideViewController *guide = [[GuideViewController alloc]init];
        guide.hiddenNav = YES;
         UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:guide];
        self.window.rootViewController = nav;
        [kUSerD setObject:APP_CURRENT_VERSION forKey:@"kversion"];
    }
    
    return YES;
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
    }


- (void)applicationWillEnterForeground:(UIApplication *)application {
   
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

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
