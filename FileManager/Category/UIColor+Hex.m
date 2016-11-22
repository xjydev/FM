//
//  UIColor+Hex.m
//
//  Created by wangyuehong on 15/9/6.
//  Copyright (c) 2015年 Oradt. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (ora_Hex)

+ (UIColor *)ora_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex)&0xFF;

    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:alpha];
}

+ (UIColor *)ora_colorWithHex:(UInt32)hex {
    return [self ora_colorWithHex:hex andAlpha:1.0];
}

+ (UIColor *)ora_colorWithHexString:(NSString *)hexString{
    
    unsigned int alpha, red, green, blue;
    
    // 获取到的颜色
    if ([[hexString uppercaseString] hasPrefix:@"0X"]) {
        hexString = [hexString substringFromIndex:2];
    } else if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    // 当颜色值少于6个字符时返回黑色
    if (hexString.length < 6) return [UIColor blackColor];
    
    NSRange range = NSMakeRange(0, 2);
    
    // Alpha值 默认为255(1.0f)
    if (6 == hexString.length) {
        alpha = 255;
    } else {
        [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&alpha];
        range.location += 2;
    }
    
    // 红色
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&red];
    range.location += 2;
    
    // 绿色
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&green];
    range.location += 2;
    
    // 蓝色
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha / 255.0f];
}
+ (UIColor *)ora_colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha{

    unsigned int red, green, blue;
    
    // 获取到的颜色
    if ([[hexString uppercaseString] hasPrefix:@"0X"]) {
        hexString = [hexString substringFromIndex:2];
    } else if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    // 当颜色值少于6个字符时返回黑色
    if (hexString.length < 6) return [UIColor blackColor];
    
    NSRange range = NSMakeRange(0, 2);
    // 红色
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&red];
    range.location += 2;
    
    // 绿色
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&green];
    range.location += 2;
    
    // 蓝色
    [[NSScanner scannerWithString:[hexString substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha];
}

- (UInt32)ora_hexValue {
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];

    UInt32 ri = r * 255.0;
    UInt32 gi = g * 255.0;
    UInt32 bi = b * 255.0;

    return (ri << 16) + (gi << 8) + bi;
}

@end
