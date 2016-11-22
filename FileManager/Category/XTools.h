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
    FileTypeVideo,
    FileTypeAudio,
    FileTypeImage,
    FileTypeDocument,
    
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
//单例Application
#define APPSHAREAPP [UIApplication sharedApplication]
//系统版本号
#define IOSSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
//当前应用版本 版本比较用
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//屏幕的宽度,支持旋转屏幕
#define kScreen_Width                                                                                   \
((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)                            \
? (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.height                                              \
: [UIScreen mainScreen].bounds.size.width)                                              \
: [UIScreen mainScreen].bounds.size.width)

//屏幕的高度,支持旋转屏幕
#define kScreen_Height                                                                                  \
((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)                            \
? (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.width                                               \
: [UIScreen mainScreen].bounds.size.height)                                             \
: [UIScreen mainScreen].bounds.size.height)


@interface XTools : NSObject
+ (instancetype)shareXTools;

/**
 播放视频

 @param filePath 文件的本地路径，或者视频的网络地址。
 @return 是否播放
 */
- (BOOL)playWithFilePath:(NSString *)filePath;

/**
 屏幕旋转方向
 */
@property (nonatomic, assign)UIInterfaceOrientationMask orientationMask;
//是否可以转屏,默认是YES，可以旋转。
@property (nonatomic, assign)BOOL isCanRotation;
@property (nonatomic, strong)NSArray * videoFormatArray;
@property (nonatomic, strong)NSArray * audioFormatArray;
@property (nonatomic, strong)NSArray * imageFormatArray;
@property (nonatomic, strong)NSArray * documentFormatArray;
@property (nonatomic, strong)NSArray * compressFormatArray;
+ (FileType)fileFormatWithPath:(NSString *)path;

@end
