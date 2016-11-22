//
//  UIColor+Hex.h
//
//  Created by wangyuehong on 15/9/6.
//  Copyright (c) 2015年 Oradt. All rights reserved.
//

#import <UIKit/UIKit.h>
//程序需要的主要三个颜色
#define kNavCOLOR [UIColor ora_colorWithHex:0xf5f5f5]
#define kMainCOLOR [UIColor ora_colorWithHex:0xe73649]
#define kBACKCOLOR [UIColor ora_colorWithHex:0xeeeeee]
#define kLINECOLOR [UIColor ora_colorWithHex:0xe5e5e5]
#define kTEXTGRAY [UIColor ora_colorWithHex:0x999999]
@interface UIColor (ora_Hex)

//根据16进制颜色值和alpha值生成UIColor
+ (UIColor *)ora_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;

//根据16进制颜色值和alpha为1生成UIColor
+ (UIColor *)ora_colorWithHex:(UInt32)hex;

//根据16进制颜色字符串生成UIColor
// hexString 支持格式为 OxAARRGGBB / 0xRRGGBB / #AARRGGBB / #RRGGBB / AARRGGBB / RRGGBB
+ (UIColor *)ora_colorWithHexString:(NSString *)hexString;
+ (UIColor *)ora_colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha;

//返回当前对象的16进制颜色值
- (UInt32)ora_hexValue;

@end
