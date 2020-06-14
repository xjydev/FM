//
//  ViewController.m
//  申诉验证码
//
//  Created by XiaoDev on 07/04/2018.
//  Copyright © 2018 appeal. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface ViewController ()
{
    __weak IBOutlet UITextField *_appealTextField;
    __weak IBOutlet UITextField *_verifyTextField;
    __weak IBOutlet UITextView *_logTextView;
    __weak IBOutlet UITextField *_enteryTextField;
    __weak IBOutlet UILabel *_versionLabel;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _versionLabel.text = [NSString stringWithFormat:@"V%@ B%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_appealTextField resignFirstResponder];
    [_verifyTextField resignFirstResponder];
    [_logTextView resignFirstResponder];
    
}
- (IBAction)getVerifyCodeAction:(id)sender {
    if (_appealTextField.text.length == 0) {
        _logTextView.text = @"申诉码为空";
        return;
    }
    NSString *statusStr = @"";
    if ([_appealTextField.text hasPrefix:@"8"]) {
        statusStr = @"购买结束";
    }
    else
        if ([_appealTextField.text hasPrefix:@"6"]) {
          statusStr = @"购买开始";
        }
    else
    {
       statusStr = @"购买无状态";
    }
    NSString *appeal = [NSString stringWithFormat:@"xiao%@",_appealTextField.text];
    NSString *codestr = [self md5Fromstr:appeal];
    _verifyTextField.text = [codestr substringToIndex:6];
    _enteryTextField.text = [codestr substringFromIndex:codestr.length-6];
    _logTextView.text = [NSString stringWithFormat:@"申诉码：%@\n全码：%@\n",_appealTextField.text,codestr];
}

#pragma mark -- 加密md5
- (NSString *)md5Fromstr:(NSString *)str {
    if (str) {
        const char *cStr = [str UTF8String];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        //把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了digest这个空间中
        CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", digest[i]];//x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
        return output;
    }
    return nil;
}
- (IBAction)copyAdcode:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    NSString *pdStr = [NSString stringWithFormat:@"去广告申诉码 %@ 对应的验证码是 %@ ",_appealTextField.text,_verifyTextField.text];
    pboard.string = pdStr ;
    _logTextView.text = [_logTextView.text stringByAppendingString:@"\n复制广告码成功"];
}
- (IBAction)copyEnteryCode:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    NSString *pdStr = [NSString stringWithFormat:@"文件加密申诉码 %@ 对应的验证码是 %@ ",_appealTextField.text,_enteryTextField.text];
    pboard.string = pdStr;
    _logTextView.text = [_logTextView.text stringByAppendingString:@"\n复制加密码成功"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
