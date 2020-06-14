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
#import "RewardViewController.h"
@interface PreferencesTableViewController ()
{
    NSArray     *_mainArray;
}
@end

@implementation PreferencesTableViewController
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
    _mainArray = @[
                   @[@{@"title":kDevice_Is_iPhoneX?@"面容密码":@"指纹密码",@"subTitle":kDevice_Is_iPhoneX?@"是否开启指纹验证，保护您的隐私":@"是否开启指纹验证，保护您的隐私",@"tag":@"1"},
    @{@"title":@"手势密码",@"subTitle":@"是否开启手势密码，保护您的隐私。",@"tag":@"2"},
    @{@"title":@"重置密码",@"subTitle":@"如果已经开启手势密码，点这可以重置",@"tag":@"3"},
    @{@"title":@"设置加密密码",@"subTitle":@"加密密码可以找回解锁密码",@"tag":@"4"},
    @{@"title":@"无痕浏览",@"subTitle":@"视频音频浏览不会再产生或更新历史记录",@"tag":@"6"},
    @{@"title":@"去除网页图标",@"subTitle":@"是否去除网页界面的图标",@"tag":@"7"}]];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
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
            case 6:
            {
                switchView.hidden = NO;
                switchView.on = [kUSerD boolForKey:kNoTrace];
            }
                break;
            case 7:
            {
                switchView.hidden = NO;
                switchView.on = [kUSerD boolForKey:kWebPage];
            }
                break;
                
            default:
                break;
        }
        
    }
   
    
    return cell;
}
- (void)swithAction:(UISwitch *)switchView {
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
                        if (num==3) {
                            switchView.on = !switchView.on;
                        }
                        else
                        {
                            [kUSerD setBool:YES forKey:kTouchPassWord];
                            [kUSerD synchronize];
                            [self.tableView reloadData];
                        }
                        
                    }];
                }
                else
                {
                    [XTOOLS showMessage:@"设备不支持指纹密码"];
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
                        switchView.on = !switchView.on;
                    }
                }];
            }
            else
            {
                [SafeView defaultSafeView].type = PassWordTypeDefault;
                [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
                    if (num == 3) {
                       switchView.on = !switchView.on;
                    }
                    else
                    {
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
            [kUSerD setBool:switchView.on forKey:kRotating];
        }
            break;
        case 6:
        {
            [kUSerD setBool:switchView.on forKey:kNoTrace];
        }
            break;
        case 7:
        {
            [XTOOLS umEvent:@"hiddWebPage" label:@"点击"];
            if ([kUSerD boolForKey:KADBLOCK]) {
                [kUSerD setBool:switchView.on forKey:kWebPage];
                [kNOtificationC postNotificationName:kWebPage object:nil];
                [XTOOLS umEvent:@"hiddWebPage" label:@"成功"];
            }
            else {
                switchView.on = NO;
                [XTOOLS showAlertTitle:@"去广告功能" message:@"购买去广告，才可以去除网页界面所有图标。" buttonTitles:@[@"取消",@"去除"] completionHandler:^(NSInteger num) {
                    if (num == 1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [XTOOLS umEvent:@"hiddWebPage" label:@"去购买"];
                            RewardViewController *vc = [RewardViewController allocFromStoryBoard];
                            [self.navigationController pushViewController:vc animated:YES];
                        });
                    }
                    else {
                        [XTOOLS umEvent:@"hiddWebPage" label:@"取消"];
                    }
                }];
            }
            
        }
            break;
        default:
            break;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_mainArray[indexPath.section][indexPath.row][@"tag"] integerValue] == 3) {
        
        if ([kUSerD objectForKey:KPassWord]) {
           [SafeView defaultSafeView].type = PassWordTypeReset;
        }
        else
        {
           [SafeView defaultSafeView].type = PassWordTypeSet;
        }
        
        
        [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
            
        }];
    }
    else
        if ([_mainArray[indexPath.section][indexPath.row][@"tag"] integerValue] == 4) {
            RewardViewController *re = [self.storyboard instantiateViewControllerWithIdentifier:@"RewardViewController"];
            [self.navigationController pushViewController:re animated:YES];
        }
   
}


@end
