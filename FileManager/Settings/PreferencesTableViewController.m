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
@interface PreferencesTableViewController ()
{
    NSArray     *_mainArray;
}
@end

@implementation PreferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainArray = @[@[@{@"title":@"屏幕旋转",@"subTitle":@"应用的所有界面是否支持转屏",@"tag":@"0"}],
  @[@{@"title":@"指纹密码",@"subTitle":@"是否开启指纹验证，保护您的隐私",@"tag":@"1"},
  @{@"title":@"手势密码",@"subTitle":@"是否开启手势密码，保护您的隐私。",@"tag":@"2"},
    @{@"title":@"重置密码",@"subTitle":@"如果已经开启手势密码，点这可以重置",@"tag":@"3"}]];
    
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
            case 0:
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
               switchView.on = XTOOLS.isCanRotation;
            }
                break;
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
        case 0:
        {
            XTOOLS.isCanRotation = switchView.on;
            [kUSerD setObject:[NSNumber numberWithBool:XTOOLS.isCanRotation] forKey:userRotationKey];
        }
            break;
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
                        [kUSerD setBool:YES forKey:kTouchPassWord];
                        [kUSerD synchronize];
                        [self.tableView reloadData];
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
                    
                }];
            }
            else
            {
                [SafeView defaultSafeView].type = PassWordTypeDefault;
                [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
                    [kUSerD removeObjectForKey:KPassWord];
                    [kUSerD removeObjectForKey:kTouchPassWord];
                    [kUSerD synchronize];
                    [self.tableView reloadData];
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
}


@end
