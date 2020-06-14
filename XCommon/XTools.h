//
//  XTools.h
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//
//视频格式：RMVB、WMV、ASF、AVI、3GP、MPG、MKV、MP4、DVD、OGM、MOV、MPEG2、MPEG4
//.rmvb .asf .avi .divx .dv .flv .gxf .m1v .m2v .m2ts .m4v .mkv .mov .mp2 .mp4 .mpeg .mpeg1 .mpeg2 .mpeg4 .mpg .mts .mxf .ogg .ogm .ps .ts .vob .wmv .a52 .aac .ac3 .dts .flac  .m4p .mka .mod .mp1 .mp2 .mp3 .ogg.
//音频格式：MP3、OGG、WAV、APE、CDA、AU、MIDI、MAC、AAC、FLV、SWF、M4V、F4V.m4a
//图片格式：GIF、JPEG、BMP、TIF、JPG、PCD、QTI、QTF、TIFF

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UMAnalytics/MobClick.h>
#import "XMacro.h"
#import "UIColor+Hex.h"
#import "XDFileManager.h"
#import "Record+CoreDataProperties.h"
typedef NS_ENUM(NSInteger ,SHUDType) {
    SHUDTypeLoading,
    SHUDTypeSuccess,
    SHUDTypeFaile,
    SHUDTypeForward,
    SHUDTypeBack,
};


#define XTOOLS [XTools shareXTools]

//userDefaults
#define kUSerD [NSUserDefaults standardUserDefaults]
//观察者
#define kNOtificationC [NSNotificationCenter defaultCenter]

//单例Application
#define APPSHAREAPP [UIApplication sharedApplication]
//是ipad
#define IsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//系统版本号
#define IOSSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
//当前应用版本 版本比较用
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kStatusBar_Height [UIApplication sharedApplication].statusBarFrame.size.height
//屏幕的宽度,支持旋转屏幕
#define kScreen_Width  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)


//屏幕的高度,支持旋转屏幕
#define kScreen_Height                                                                                  \
(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.width                                               \
: [UIScreen mainScreen].bounds.size.height)

#define KNavitionbarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?88:64) // 适配iPhone x 导航高度

#define KBottomSafebarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0) // 适配
#define kDevice_Is_iPhoneX [XTools isiPhoneX]
#define KUIFontNR(font) [UIFont fontWithName:@"PingFangSC-Regular" size:(font)]
#define KUIFontNM(font) [UIFont fontWithName:@"PingFangSC-Medium" size:(font)]
#define KUIFontNS(font) [UIFont fontWithName:@"PingFangSC-Semibold" size:(font)]
#define KUIFontNL(font) [UIFont fontWithName:@"PingFangSC-Light" size:(font)]

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n", \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
__LINE__, \
[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif
/*弱引用宏*/
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif


#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define kNoTrace @"knotracerecod"//是否留下记录
#define KUIFontNR(font) [UIFont fontWithName:@"PingFangSC-Regular" size:(font)]
#define KUIFontNM(font) [UIFont fontWithName:@"PingFangSC-Medium" size:(font)]
#define KUIFontNS(font) [UIFont fontWithName:@"PingFangSC-Semibold" size:(font)]
@interface XTools : NSObject
+ (instancetype)shareXTools;
+ (BOOL)isiPhoneX;
/**
 屏幕旋转方向
 */
//@property (nonatomic, assign)UIInterfaceOrientationMask orientationMask;
//是否可以转屏,默认是YES，可以旋转。
//@property (nonatomic, assign)BOOL isCanRotation;
@property (nonatomic, copy) NSString *hiddenFilePath;
@property (nonatomic, strong)NSDateFormatter *dateFormater;
@property (nonatomic, strong)NSString *dateStr;
@property (nonatomic, strong)NSString *timeStr;


/**
 播放文件

 @param path 文件路径
 @param origionalWiewController 开始播放前的界面
 @return 是否播放成功
 */
- (BOOL)playFileWithPath:(NSString *)path OrigionalWiewController:(UIViewController *)origionalWiewController;

/**
 判断文件类型

 @param path 文件路径
 @return 文件类型
 */
- (FileType)fileFormatWithPath:(NSString *)path;

- (void)showMessage:(NSString *)title;
- (void)showLoading:(NSString *)title;
- (void)hiddenLoading;
- (void)showAlertTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num))completionHandler;
- (void)showAlertTextField:(NSString *)text placeholder:(NSString *)placeHolder title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num,NSString *textValue))completionHandler;
//时间和秒之间字符串的转换
- (double)timeStrToSecWithStr:(NSString *)str;
- (NSString *)timeSecToStrWithSec:(double)sec;

- (float )folderSizeAtPath:(NSString*) folderPath;
//获取单个文件的大小
- (long long) fileSizeAtPath:(NSString*) filePath;
//获取手机存储空间信息
- (float)allStorageSpace;
- (float)freeStorageSpace;
- (NSString *)storageSpaceStringWith:(float)space;
#pragma mark -- 加密md5
- (NSString *)md5Fromstr:(NSString *)str;

/**
 判断是否应该打开vpn
 */
- (void)openVPN;
- (BOOL)goToAppstoreComment;
/**
 判断是否去App Store评论应用
 */
- (void)umengClick:(NSString *)eventId;
- (void)umEvent:(NSString *)event label:(NSString *)label;
- (void)umengPageBegin:(NSString *)pageV;
- (void)umengPageEnd:(NSString *)pageV;

- (BOOL)showAdview;
- (BOOL)showInterstitialAdView;
/**
 横条广告的界面

 @return 界面
 */
- (UIView *)bannerAdViewRootViewController:(UIViewController *)rootViewController;
//添加获取加密密码
- (BOOL)savePravicyPassword:(NSString *)passW;
- (NSString *)getPravicyPassWord;
- (NSString *)timeStrFromDate:(NSDate *)date;
- (NSString *)hmtimeStrFromDate:(NSDate *)date;
- (BOOL)openURLStr:(NSString *)urlStr;
- (BOOL)checkNetworkTitle:(NSString *)title State:(void (^)(BOOL is))complete;
- (UIViewController *)topViewController;
@end
