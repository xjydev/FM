//
//  XTools.h
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//
//视频格式：RMVB、WMV、ASF、AVI、3GP、MPG、MKV、MP4、DVD、OGM、MOV、MPEG2、MPEG4
//.rmvb .asf .avi .divx .dv .flv .gxf .m1v .m2v .m2ts .m4v .mkv .mov .mp2 .mp4 .mpeg .mpeg1 .mpeg2 .mpeg4 .mpg .mts .mxf .ogg .ogm .ps .ts .vob .wmv .a52 .aac .ac3 .dts .flac .m4a .m4p .mka .mod .mp1 .mp2 .mp3 .ogg.
//音频格式：MP3、OGG、WAV、APE、CDA、AU、MIDI、MAC、AAC、FLV、SWF、M4V、F4V
//图片格式：GIF、JPEG、BMP、TIF、JPG、PCD、QTI、QTF、TIFF

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , FileType) {
    FileTypeDefault,
    FileTypeVideo,
    FileTypeAudio,
    FileTypeImage,
    FileTypeDocument,
    FileTypeCompress,
    FileTypeFolder,
    
    
};
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
//文件管理器
#define kFileM    [NSFileManager defaultManager]
//document路径
#define KDocumentP [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kCachesP [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kTmpP NSTemporaryDirectory()
//单例Application
#define APPSHAREAPP [UIApplication sharedApplication]
//是ipad
#define IsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//系统版本号
#define IOSSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
//当前应用版本 版本比较用
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//屏幕的宽度,支持旋转屏幕
#define kScreen_Width  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)


//屏幕的高度,支持旋转屏幕
#define kScreen_Height                                                                                  \
(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.width                                               \
: [UIScreen mainScreen].bounds.size.height)

//#define kUserRotationKey @"canRotationKey"

extern NSString * const userRotationKey ;
@interface XTools : NSObject
+ (instancetype)shareXTools;

/**
 屏幕旋转方向
 */
@property (nonatomic, assign)UIInterfaceOrientationMask orientationMask;
//是否可以转屏,默认是YES，可以旋转。
@property (nonatomic, assign)BOOL isCanRotation;
@property (nonatomic, copy) NSString *hiddenFilePath;
@property (nonatomic, strong)NSArray * videoFormatArray;
@property (nonatomic, strong)NSArray * audioFormatArray;
@property (nonatomic, strong)NSArray * imageFormatArray;
@property (nonatomic, strong)NSArray * documentFormatArray;
@property (nonatomic, strong)NSArray * compressFormatArray;
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
//时间和秒之间字符串的转换
- (double)timeStrToSecWithStr:(NSString *)str;
- (NSString *)timeSecToStrWithSec:(double)sec;
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

/**
 判断是否年满18周岁
 */
- (void)choose18year;

/**
 判断是否去App Store评论应用
 */
- (void)gotoAppStoreComment;
@end
