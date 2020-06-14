//
//  PreferencesTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/25/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "PreferencesTableViewController.h"
#import "XTools.h"
#import "SafeView.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "RewardViewController.h"
//#import "UIViewController+JY.h"
@interface PreferencesTableViewController ()
{
    NSArray     *_mainArray;
    IBOutlet UITableView *_mainTableView;
}
@end

@implementation PreferencesTableViewController
+ (instancetype)viewControllerStroyBoard {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreferencesTableViewController *info = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PreferencesTableViewController"];
    return info;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"应用设置";
    [self reloadView];
    self.tableView.tableFooterView = [[UIView alloc]init];
//    [self setleftBackButton];
    
}
- (void)reloadView {
    NSString *sStr = kDevice_Is_iPhoneX?@"人脸识别":@"指纹密码";
    _mainArray = @[@[@{@"title":sStr,@"subTitle":[NSString stringWithFormat: @"是否开启%@验证，保护您的隐私",sStr],@"tag":@"1"},
                     @{@"title":@"手势密码",@"subTitle":@"是否开启手势密码，保护您的隐私。",@"tag":@"2"},
                     @{@"title":@"重置密码",@"subTitle":@"如果已经开启手势密码，点这可以重置",@"tag":@"3"}
                     ,
                     @{@"title":[XTOOLS getPravicyPassWord].length>0?@"重置加密密码":@"设置加密密码",@"subTitle":@"设置的加密密码为当前加密的默认密码",@"tag":@"4"}]];
    [_mainTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mainArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_mainArray[section]).count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preferencesCell" forIndexPath:indexPath];
    NSDictionary *dict =_mainArray[indexPath.section][indexPath.row];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"subTitle"];
    UISwitch *switchView = [cell.contentView viewWithTag:301];
    if (switchView) {
        if (switchView.allTargets.count==0) {
            [switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
        }
        switch ([dict[@"tag"]integerValue]) {
            case 1:
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                switchView.on = [kUSerD boolForKey:kTouchPassWord];
            }
                break;
            case 2:
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                switchView.on = ((NSString *)[kUSerD objectForKey:KPassWord]).length>0;
            }
                break;
            case 3:
            {
                switchView.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 4:
            {
                switchView.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 5:
            {
                switchView.hidden = NO;
                switchView.on = [kUSerD boolForKey:kRotating];
            }
                break;
                
                
            default:
                break;
        }
    }
    return cell;
}
- (void)swithAction:(UISwitch *)switchView {
    if (![kUSerD boolForKey:KADBLOCK]) {
        [XTOOLS showAlertTitle:@"会员服务" message:@"订阅会员才可以使用密码服务" buttonTitles:@[@"取消",@"订阅会员"] completionHandler:^(NSInteger num) {
            if (num == 1) {
              RewardViewController *VC = [RewardViewController allocFromStoryBoard];
              [self.navigationController pushViewController:VC animated:YES];
            }
            switchView.on = NO;
        }];
        return;
    }
    UITableViewCell *cell = (UITableViewCell *)switchView.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch ([_mainArray[indexPath.section][indexPath.row][@"tag"] integerValue]) {
        case 1:
        {
            if (switchView.on) {
                
                if ([SafeView defaultSafeView].supportTouchID) {
                    if (![kUSerD objectForKey:KPassWord]) {
                       [SafeView defaultSafeView].type = PassWordTypeSet;
                    }
                    else
                    {
                        [SafeView defaultSafeView].type = PassWordTypeDefault;
                    }
                    [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
                        if (num == 3) {
                            switchView.on = NO;
                        }
                        else {
                            [kUSerD setBool:YES forKey:kTouchPassWord];
                            [kUSerD synchronize];
                            [self.tableView reloadData];
                        }
                    }];
                }
                else
                {
                    [XTOOLS showMessage:kDevice_Is_iPhoneX?@"设备不支持人脸解锁":@"设备不支持指纹解锁"];
                    switchView.on = NO;
                }
            }
            else
            {
                [kUSerD removeObjectForKey:kTouchPassWord];
                [kUSerD synchronize];
            }
        }
            break;
        case 2:
        {
            if (switchView.on) {
                [SafeView defaultSafeView].type = PassWordTypeSet;
                [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
                    if (num == 3) {
                        switchView.on = NO;
                    }
                    
                }];
            }
            else
            {
                [SafeView defaultSafeView].type = PassWordTypeDefault;
                [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
                    if (num == 2) {
                        [kUSerD removeObjectForKey:KPassWord];
                        [kUSerD removeObjectForKey:kTouchPassWord];
                        [kUSerD synchronize];
                        [self.tableView reloadData];
                    }
                }];
            }
            
        }
            break;
        case 5:
        {
            
            [kUSerD setObject:[NSNumber numberWithBool:switchView.on] forKey:kRotating];
        }
            break;
            
        default:
            break;
    }
    
}
- (BOOL)verifyPassWord {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"验证旧密码" message:@"请输入验证旧密码，成功后设置新密码" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"旧加密密码";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            [XTOOLS showMessage:@"密码不能为空"];
            return ;
            
        }
        else
        {
            if ([[XTOOLS getPravicyPassWord]isEqualToString:textField.text]) {
                [self createNewPassWord:NO];
            }
            else{
                [XTOOLS showMessage:@"验证失败"];
                [self verifyPassWord];
            }
            
            
        }
        
        NSLog(@"==%@",textField.text);
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
    return YES;
}
//设置密码
- (void)createNewPassWord:(BOOL)isNew {
    NSString *title = isNew? @"设置密码":@"重置新密码";
    NSString *message = isNew?@"请输入加密解密密码，将用于文件加密的默认密码":@"重置密码后，已加密文件的密码仍为旧密码";
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"加密密码";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            
             [self removePassWord];
            
        }
        else
        {
            if (isNew) {
                [XTOOLS savePravicyPassword:textField.text];
                [XTOOLS showMessage:@"设置成功"];
                [self reloadView];
                
            }
            else
            {
                [XTOOLS savePravicyPassword:textField.text];
                [XTOOLS showMessage:@"重置成功"];
                [self->_mainTableView reloadData];
                
            }
            
            
        }
        
        NSLog(@"==%@",textField.text);
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}
- (void)removePassWord {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"确认去除密码" message:@"去除加密默认密码，每次加密将都需要输入密码" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [XTOOLS savePravicyPassword:nil];
        [XTOOLS showMessage:@"去除成功"];
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![kUSerD boolForKey:KADBLOCK]) {
        [XTOOLS showAlertTitle:@"会员服务" message:@"订阅会员才可以使用密码服务" buttonTitles:@[@"取消",@"订阅会员"] completionHandler:^(NSInteger num) {
            if (num == 1) {
                RewardViewController *VC = [RewardViewController allocFromStoryBoard];
                [self.navigationController pushViewController:VC animated:YES];
            }
        }];
        return;
    }
    if ([_mainArray[indexPath.section][indexPath.row][@"tag"] integerValue] == 3) {
        
        if ([kUSerD objectForKey:KPassWord]) {
           [SafeView defaultSafeView].type = PassWordTypeReset;
        }
        else {
           [SafeView defaultSafeView].type = PassWordTypeSet;
        }

        [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
            [self->_mainTableView reloadData];
        }];
    }
    else if ([_mainArray[indexPath.section][indexPath.row][@"tag"] integerValue] == 4)
    {
        if([XTOOLS getPravicyPassWord].length>0){
            [self verifyPassWord];
        }
        else
        {
            [self createNewPassWord:YES];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    if ([XTOOLS showAdview]) {
        UIView *adView = [XTOOLS bannerAdViewRootViewController:self];
        adView.center = CGPointMake(kScreen_Width/2, CGRectGetHeight(self.view.frame) - 25- KNavitionbarHeight);
        [self.view addSubview:adView];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
@end
