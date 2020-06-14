//
//  FaceTransferView.m
//  FileManager
//
//  Created by xiaodev on Feb/21/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//
//优先蓝牙传输，其次socket局域网传输。
#import "FaceTransferView.h"
#import "AppDelegate.h"
#import "XTools.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_TYPE @"serviceType"

static FaceTransferView *backView = nil;
@interface FaceTransferView ()
@property (nonatomic, strong)UIImageView    *QRcodeImageView;
@property (nonatomic, strong)UILabel        *titleLabel;
@property (nonatomic, strong)UILabel        *alertLabel;



@end
@implementation FaceTransferView
+(instancetype)defaultTransfer {
    if (!backView) {
        backView = [[FaceTransferView alloc] initWithFrame:CGRectMake(0, 0,kScreen_Width , kScreen_Height)];
        backView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        backView.QRcodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake((backView.frame.size.width-300)/2, 104, 300, 300)];
        
        [backView addSubview:backView.QRcodeImageView];
        
        backView.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, backView.frame.size.width, 40)];
        backView.titleLabel.font = [UIFont systemFontOfSize:18];
        backView.titleLabel.textColor = [UIColor whiteColor];
        backView.titleLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:backView.titleLabel];
        
        backView.alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 450, kScreen_Width, 20)];
        backView.alertLabel.textAlignment = NSTextAlignmentCenter;
        backView.alertLabel.textColor = [UIColor whiteColor];
        backView.alertLabel.font = [UIFont systemFontOfSize:17];
        backView.alertLabel.text = @"传输未完成前请不要关闭应用";
        [backView addSubview:backView.alertLabel];
        
        
    }
    return backView;
}
- (void)showQRCodeWithStr:(NSString *)str {
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:backView];
    backView.titleLabel.text = [str lastPathComponent];
    [self createCoreImage:str];
    
//    if ([TransferIPManager defaultManager].webServer.serverURL.absoluteString.length>0) {
//        
//        NSString *encodedString = (NSString *)
//        CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                  (CFStringRef)str,
//                                                                  NULL,
//                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                                  kCFStringEncodingUTF8));
//        NSString *downLoadStr = [NSString stringWithFormat:@"%@download?path=%@",[TransferIPManager defaultManager].webServer.serverURL.absoluteString,encodedString];
//       [self createCoreImage:downLoadStr];
//    }
//    else
//    {
//        [XTOOLS showMessage:@"网络错误"];
//    }
    
    
}

- (void)transferServerDidStartOrStop:(BOOL)isStart {
    if (isStart) {
        
    }
    else
    {
        
    }
}

#pragma mark - 生成二维码
- (void)createCoreImage:(NSString *)codeStr{
    
    //1.生成coreImage框架中的滤镜来生产二维码
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    [filter setValue:[codeStr dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    //4.获取生成的图片
    CIImage *ciImg=filter.outputImage;
    //放大ciImg,默认生产的图片很小
    
    //5.设置二维码的前景色和背景颜色
    CIFilter *colorFilter=[CIFilter filterWithName:@"CIFalseColor"];
    //5.1设置默认值
    [colorFilter setDefaults];
    [colorFilter setValue:ciImg forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithRed:0 green:0 blue:0] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithRed:1 green:1 blue:1] forKey:@"inputColor1"];
    //5.3获取生存的图片
    ciImg=colorFilter.outputImage;
    
    CGAffineTransform scale=CGAffineTransformMakeScale(10, 10);
    ciImg=[ciImg imageByApplyingTransform:scale];
    
    //6.在中心增加一张图片
    UIImage *img=[UIImage imageWithCIImage:ciImg];
    //7.生存图片
    CGFloat width = 400;
    CGFloat height = 400;
    //7.1开启图形上下文
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    //7.2将二维码的图片画入
    //BSXPCMessage received error for message: Connection interrupted   why??
    //    [img drawInRect:CGRectMake(10, 10, img.size.width-20, img.size.height-20)];
    [img drawInRect:CGRectMake(0, 0,width , height)];
    //7.3在中心划入其他图片
    UIImage *centerImage = [UIImage imageNamed:@"face_transfer"];
    CGFloat centerW=width/4;
    CGFloat centerH=height/4;
    CGFloat centerX=(width-centerW)*0.5;
    CGFloat centerY=(height -centerH)*0.5;
    
    [centerImage drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];

    
    //7.4获取绘制好的图片
    _QRcodeImageView.image=UIGraphicsGetImageFromCurrentImageContext();
    
    //7.5关闭图像上下文
    UIGraphicsEndImageContext();
    
    
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self removeFromSuperview];
    backView = nil;
    
    
}

@end
