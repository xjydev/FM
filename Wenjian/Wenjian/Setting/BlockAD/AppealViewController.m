//
//  AppealViewController.m
//  FileManager
//
//  Created by XiaoDev on 07/04/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "AppealViewController.h"
#import "XTools.h"
@interface AppealViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet UITextField *_appealCodeTextField;
    IBOutlet UIButton *_rightButton;
    IBOutlet UILabel *_leftLabel;
    
    __weak IBOutlet UITextField *_appealTextField;
    IBOutlet UIButton *_verifyButton;
    IBOutlet UILabel *_verifyLabel;
    __weak IBOutlet UITextView *_atextView;
    
}
@end

@implementation AppealViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"申诉";
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    NSString *appealStr =[kUSerD objectForKey:@"appealkey"];
    if (appealStr.length == 0) {
        appealStr = @"无申诉码";
    }
    
    _appealTextField.leftView = _verifyLabel;
    _appealTextField.rightView = _verifyButton;
    _appealTextField.leftViewMode = UITextFieldViewModeAlways;
    _appealTextField.rightViewMode = UITextFieldViewModeAlways;
    
    _appealCodeTextField.leftView = _leftLabel;
    _appealCodeTextField.rightView = _rightButton;
    _appealCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    _appealCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    _appealCodeTextField.text = appealStr;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
       [paragraphStyle setLineSpacing:8];
       [paragraphStyle setParagraphSpacing:10];  //调整段间距
       [paragraphStyle setHeadIndent:15.0];
    _atextView.attributedText = [[NSAttributedString alloc]initWithString:@"1.每次申诉前请获取最新申诉码。\n 2.申诉时必须填写本界面的申诉码。\n 3.申诉时请附带App Store的扣款成功邮件截图或订单截图。\n 4.申诉码或附带订单资料有问题，申诉将有可能失败。\n 5.申诉材料请发放至xiaodeve@163.com，我们将第一时间为您处理。" attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:kCOLOR(0x222222, 0xeeeeee),NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _appealCodeTextField) {
        return NO;
    }
    return YES;
}
- (IBAction)getAppealCodeButtonAction:(id)sender {
    [XTOOLS showAlertTitle:@"获取申诉码" message:@"在申诉期间请勿重复获取申诉码，以免申诉问题无法解决。" buttonTitles:@[@"取消",@"坚持获取"] completionHandler:^(NSInteger num) {
        if ([kUSerD boolForKey:kpayend]) {
           NSString * appealStr = [NSString stringWithFormat:@"%d",800000+arc4random()%100001];
            [kUSerD setObject:appealStr forKey:@"appealkey"];
            [kUSerD synchronize];
            self->_appealCodeTextField.text = appealStr;
        }
        else
            if ([kUSerD boolForKey:kpaystart]) {
                NSString * appealStr = [NSString stringWithFormat:@"%d",600000+arc4random()%100001];
                [kUSerD setObject:appealStr forKey:@"appealkey"];
                [kUSerD synchronize];
                self->_appealCodeTextField.text = appealStr;
            }
        else
        {
            NSString * appealStr = [NSString stringWithFormat:@"%d",100000+arc4random()%100001];
            [kUSerD setObject:appealStr forKey:@"appealkey"];
            [kUSerD synchronize];
            self->_appealCodeTextField.text = appealStr;
        }
    }];
}
- (IBAction)_verifyButtonAction:(id)sender {
    if (_appealTextField.text.length<6) {
        [XTOOLS showMessage:@"请输入正确验证码"];
        return;
    }
    NSString *appealStr =[kUSerD objectForKey:@"appealkey"];
    if (appealStr.length == 0) {
        [XTOOLS showAlertTitle:@"请申请验证码" message:@"请获取申诉码，根据申诉码重新获取验证码验证" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
            
        }];
        return;
    }
    NSString *codestr = [XTOOLS md5Fromstr:[NSString stringWithFormat:@"xiao%@",appealStr]];
    if ([codestr hasPrefix:_appealTextField.text]) {
       [kUSerD setBool:YES forKey:kENTRICY];
        [kUSerD setBool:YES forKey:KADBLOCK];
        [kUSerD synchronize];
        [XTOOLS showAlertTitle:@"验证成功" message:@"已经获取到所有订阅的功能。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
    }
    else
        if ([codestr hasSuffix:_appealTextField.text]) {
            [kUSerD setBool:YES forKey:kENTRICY];
            [kUSerD setBool:YES forKey:KADBLOCK];
            [kUSerD synchronize];
            [XTOOLS showAlertTitle:@"验证成功" message:@"已经恢复了所有的订阅功能" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                
            }];
        }
    else
    {
        [XTOOLS showAlertTitle:@"验证失败" message:@"请重新获取申诉码，再次申诉获取验证码" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
    }
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_appealTextField resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
