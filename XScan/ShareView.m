//
//  ShareView.m
//  QRcreate
//
//  Created by xiaodev on May/3/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "ShareView.h"
#import "UIColor+Hex.h"
#import <UShareUI/UShareUI.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "XTools.h"
#import <SafariServices/SafariServices.h>
static ShareView*_shareView = nil;
@interface ShareView ()
{
    UIView *_backView;
    NSString *_context;
    NSString *_title;
    UIImage  *_image;
    UIButton   *_testButton;
//    UILabel    *_messageLabel;
    NSInteger _shareType;//1.url 2.text 3.image
}
@property (nonatomic, strong)UILabel *messageLabel;
@end
@implementation ShareView

+(instancetype)shareView {
    if(!_shareView){
        _shareView = [[ShareView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _shareView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        [[UIApplication sharedApplication].keyWindow addSubview:_shareView];
        _shareView.alpha = 0;
    }
    return _shareView;
        
}
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 160, kScreen_Width-40, 80)];
        _messageLabel.numberOfLines = 0;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_messageLabel];
    }
    return _messageLabel;
}
- (void)shareViewWithTitle:(NSString *)title Detail:(NSString *)detail Image:(UIImage *)image Types:(XShareType)types,... {
    _title = title;
    _context = detail;
    if (image) {
        _shareType = 3;
        _image = image;
    }
    else {
      _shareType = 2;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:8];//最多8个按钮。
    va_list typeList;
    va_start(typeList, types);
    {
        for (XShareType t = types;t != XShareTypeEnd; t = va_arg(typeList, XShareType)) {
            switch (t) {
                case XShareTypeWeChat:
                    {
                        if ([WXApi isWXAppInstalled]) {
                         [array addObject:@{@"title":@"微信",@"image":@"share_wechat",@"tag":@"200"}];
                        }
                        
                    }
                    break;
                case XShareTypeTimeLine:
                {
                    if ([WXApi isWXAppInstalled]) {
                      [array addObject:@{@"title":@"朋友圈",@"image":@"share_timeLine",@"tag":@"201"}];
                    }
                   
                }
                    break;
                case XShareTypeQQ:
                {
                    if ([QQApiInterface isQQInstalled]) {
                      [array addObject:@{@"title":@"QQ",@"image":@"share_qq",@"tag":@"202"}];
                    }
                }
                    break;
                case XShareTypeQzone:
                {
                    if ([QQApiInterface isQQInstalled]) {
                       [array addObject:@{@"title":@"QQ空间",@"image":@"share_qzone",@"tag":@"203"}];
                    }
                }
                    break;
                case XShareTypeCopy:
                {
                   [array addObject:@{@"title":@"复制",@"image":@"share_copy",@"tag":@"204"}];
                }
                    break;
                case XShareTypeSaveImage:
                {
                   [array addObject:@{@"title":@"保存到相册",@"image":@"share_save",@"tag":@"207"}];
                }
                    break;
                case XShareTypeSafari:
                {
                   [array addObject:@{@"title":@"Safari打开",@"image":@"share_Safari",@"tag":@"206"}];
                }
                    break;
                case XShareTypeReadList:
                {
                  [array addObject:@{@"title":@"保存到ReadingList",@"image":@"share_Reading",@"tag":@"205"}];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    va_end(typeList);
    [self shareViewWithArray:array];
}
- (void)shareViewWithUrl:(NSString *)urlstr Title:(NSString *)title {
    _title = title;
    _context = urlstr;
    _shareType = 1;
    NSArray *array = @[@{@"title":@"微信",@"image":@"share_wechat",@"tag":@"200"},
                       @{@"title":@"朋友圈",@"image":@"share_timeLine",@"tag":@"201"},
                       @{@"title":@"QQ",@"image":@"share_qq",@"tag":@"202"},
                       @{@"title":@"QQ空间",@"image":@"share_qzone",@"tag":@"203"},
                       @{@"title":@"复制",@"image":@"share_copy",@"tag":@"204"},
                       @{@"title":@"保存到ReadingList",@"image":@"share_Reading",@"tag":@"205"},
                       @{@"title":@"Safari打开",@"image":@"share_Safari",@"tag":@"206"},];
    [self shareViewWithArray:array];
    
}
- (void)shareViewWithText:(NSString *)text Title:(NSString *)title {
    
}
- (void)shareViewVithText:(NSString *)text {
    _title = @"QR二维码连续扫描结果";
    _context = text;
    _shareType = 2;
    NSArray *array = @[@{@"title":@"微信",@"image":@"share_wechat",@"tag":@"200"},
    @{@"title":@"朋友圈",@"image":@"share_timeLine",@"tag":@"201"},
    @{@"title":@"QQ",@"image":@"share_qq",@"tag":@"202"},
    @{@"title":@"QQ空间",@"image":@"share_qzone",@"tag":@"203"},
                       @{@"title":@"复制",@"image":@"share_copy",@"tag":@"204"},];
    [self shareViewWithArray:array];
    
}
- (void)shareViewWithImage:(UIImage *)image {
    _image = image;
    _shareType = 3;
  NSArray * array = @[@{@"title":@"微信",@"image":@"share_wechat",@"tag":@"200"},
              @{@"title":@"朋友圈",@"image":@"share_timeLine",@"tag":@"201"},
              @{@"title":@"QQ",@"image":@"share_qq",@"tag":@"202"},
              @{@"title":@"QQ空间",@"image":@"share_qzone",@"tag":@"203"},
              @{@"title":@"复制",@"image":@"share_copy",@"tag":@"204"},
              @{@"title":@"保存到相册",@"share_image":@"save",@"tag":@"207"},];
    
    [self shareViewWithArray:array];
}
- (void)shareViewWithArray:(NSArray *)array {
   
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-270, self.frame.size.width, 270)];
        _backView.backgroundColor = [UIColor ora_colorWithHex:0xf7f7f7];
        for (int i = 0;i<array.count;i++ ) {
            NSDictionary *dict = array[i];
            UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((kScreen_Width-240)/5+(i%4)*(kScreen_Width/5+12), 20+(i/4)*90, 60, 60);
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 30;
            [button setImage:[UIImage imageNamed:dict[@"image"]] forState:UIControlStateNormal];
            button.tag = [dict[@"tag"] integerValue];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_backView addSubview:button];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreen_Width-240)/5+(i%4)*(kScreen_Width/5+12), 80+(i/4)*90, 60, 20+20*(i/4))];
            titleLabel.text = dict[@"title"];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.numberOfLines = 2;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.font = [UIFont systemFontOfSize:12];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            [_backView addSubview:titleLabel];
        }
        
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame = CGRectMake(1, 220, self.frame.size.width-2, 50);
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton setTitleColor:kMainCOLOR forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancleButtonAction) forControlEvents:UIControlEventTouchUpInside];
        cancleButton.backgroundColor = [UIColor whiteColor];
        [_backView addSubview:cancleButton];
        [self addSubview:_backView];
        if (_shareType == 3) {
            if (!_testButton) {
                _testButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _testButton.frame =CGRectMake(80, 100, kScreen_Width - 160, 44);
                [_testButton setTitle:@"检测二维码" forState:UIControlStateNormal];
                [_testButton setTitleColor:kMainCOLOR forState:UIControlStateNormal];
                _testButton.layer.cornerRadius = 5;
                _testButton.layer.borderColor = kMainCOLOR.CGColor;
                _testButton.layer.borderWidth = 1.0;
                [_testButton addTarget:self action:@selector(testButtonAction) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_testButton];
            }
           
            _testButton.hidden = NO;
        }
        else
        {
            if (_testButton) {
                _testButton.hidden = YES;
            }
            if (_messageLabel) {
                _messageLabel.hidden = YES;
            }
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.alpha = 1.0;
    }];
    
}
- (void)testButtonAction {
    if (_image) {
        NSData *imageData = UIImagePNGRepresentation(_image);
        CIImage *ciImage = [CIImage imageWithData:imageData];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:ciImage];
        if (features.count>=1) {
            CIQRCodeFeature *feature = features.firstObject;
            NSString *scanResult = feature.messageString;
            [_testButton setTitle:@"检测结果" forState:UIControlStateNormal];
            self.messageLabel.text = scanResult;
            
        }
        else
        {
            
            [_testButton setTitle:@"未识别出二维码" forState:UIControlStateNormal];
            self.messageLabel.text = @"系统未检测出二维码，可以返回继续修改调整后再分享保存。";
            
//            [XTOOLS showAlertTitle:@"未识别出二维码" message:@"系统为检测出二维码，可以返回继续修改调整。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
//                
//            }];
        }
    }
    else
    {
        [XTOOLS showMessage:@"没有图片"];
    }
}
- (void)buttonAction:(UIButton *)button {
    switch (button.tag) {
        case 200:
        {
            if (_shareType == 2) {
                if (_context.length>100) {
                    _context = [_context substringToIndex:100];
                }
            }
            [self sharePlatformType:UMSocialPlatformType_WechatSession];
        }
            break;
        case 201:
        {
            if (_shareType == 2) {
                if (_context.length>100) {
                    _context = [_context substringToIndex:100];
                }
            }
            [self sharePlatformType:UMSocialPlatformType_WechatTimeLine];
        }
            break;
        case 202:
        {
            if (_shareType == 2) {
                if (_context.length>100) {
                    _context = [_context substringToIndex:100];
                }
            }
            [self sharePlatformType:UMSocialPlatformType_QQ];
        }
            break;
        case 203:
        {
            if (_shareType == 2) {
                if (_context.length>100) {
                    _context = [_context substringToIndex:100];
                }
            }
            [self sharePlatformType:UMSocialPlatformType_Qzone];
        }
            break;
        case 204:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (_context) {
               pasteboard.string = _context;
            }
            else
                if (_image) {
                  pasteboard.image = _image;
                }
            [XTOOLS showMessage:@"复制成功"];
            [self removeFromSuperviewbeNil];
            
        }
            break;
        case 205:
        {
           
            if (_context.length>0) {
                NSError *error;
              [[SSReadingList defaultReadingList]addReadingListItemWithURL:[NSURL URLWithString:_context] title:_title previewText:nil error:&error];
                if (!error) {
                    [XTOOLS showMessage:@"已保存到ReadingList"];
                    [self removeFromSuperviewbeNil];
                }
            }
            else
            {
                [XTOOLS showMessage:@"链接为空"];
            }
            
            
        }
            break;
        case 206:
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_context]];
            [self removeFromSuperviewbeNil];
        }
            break;
        case 207:
        {
            //保存到相册
            UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
            break;
            
        default:
            break;
    }
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error){
        [XTOOLS showMessage:@"已保存到相册"];
        [self removeFromSuperviewbeNil];
    }else{
        [XTOOLS showMessage:@"保存失败"];
    }
}

- (void)sharePlatformType:(UMSocialPlatformType)platformType {
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    if (_shareType == 2) {
        messageObject.title = _title;
        messageObject.text = _context;
    }
    else
    if (_shareType == 1) {
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"简单扫描" descr:@"简单扫描分享" thumImage:[UIImage imageNamed:@"icon"]];
        //设置网页地址
        shareObject.webpageUrl =_context;
        
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
    }
    else
        if (_image) {
            //创建图片内容对象
            UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
            //如果有缩略图，则设置缩略图
            shareObject.thumbImage = _image;
            shareObject.shareImage = _image;
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
        }
    if (!self.currentViewController) {
        self.currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self.currentViewController completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"share error == %@",error);
            [XTOOLS showMessage:@"分享失败"];
        }else{
            
            [XTOOLS showMessage:@"分享成功"];
            [self removeFromSuperviewbeNil];
        }
    }];

}
- (void)cancleButtonAction {
    [self removeFromSuperviewbeNil];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperviewbeNil];
}
- (void)removeFromSuperviewbeNil {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _shareView = nil;
        [XTOOLS showInterstitialAdView];
    }];
}
@end
