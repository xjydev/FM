//
//  XMacro.h
//  player
//
//  Created by XiaoDev on 2019/5/14.
//  Copyright © 2019 Xiaodev. All rights reserved.
//
#define kENTRICY @"xjyentricy"//加密key
#define KADBLOCK @"xyAdBlock"//广告key

#define kPassWoed @"parvicyPassword"//文件机密解密密码
#define kRetain @"parvicyRetain"//加密解密保留源文件
#define kShowParvicy @"detialshowPravicy" //详情显示加密解密。
#define kSettingParvicy @"settingParvicy"//更多里面的快捷入口
#define kRefreshList @"refreshfileslist"//刷新文件列表
#define kRefreshHome @"refreshHomeList"//刷新首页
#define kADnum @"kadnum" //广告的次数。
#define kRotating @"krotating"
#define kAppeal @"appealkey"
#define kpaystart @"paystartkey"
#define kpayend @"payendkey"
#define kAdUnitId @"ca-app-pub-2119163618927307/2410199512"
#define kBanderAdId @"ca-app-pub-2119163618927307/2059270754"
#define kAppleId @"1469851328"
//程序需要的主要三个颜色
#define kNavCOLOR [UIColor ora_colorWithHex:0xf5f5f5]
#define kMainCOLOR [UIColor ora_colorWithHex:0x1b67f1]
#define kBACKCOLOR [UIColor ora_colorWithHex:0xeeeeee]
#define kLINECOLOR [UIColor ora_colorWithHex:0xe5e5e5]
#define kTEXTGRAY [UIColor ora_colorWithHex:0x999999]
#define kSELECTCOLOR [UIColor ora_colorWithHex:0x0E80FF]
#define kSort @"keysortlist"//排序
#define kHiden @"khidenbutton" //是否隐藏隐藏文件按钮
#define kVolume @"kvolumevo"//音量大小。
#define kGuide @"kguideg"//新手引导

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
