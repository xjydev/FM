//
//  PravicySettingController.m
//  FileManager
//
//  Created by xiaodev on Sep/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "PravicySettingController.h"
#import "PravicySettingCell.h"
#import "XTools.h"
#import"RNCryptor.h"
#import"RNDecryptor.h"
#import"RNEncryptor.h"
#import "SelectFileViewController.h"
#import "EncryptDecryptManager.h"
@interface PravicySettingController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray  *_setttingArray;
    __weak IBOutlet UITableView *_mainTableView;
}
@end

@implementation PravicySettingController
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
    _setttingArray = @[@{@"title":@"默认密码",@"detail":@"设置加密解密时的默认密码",@"type":@"1"},
                       @{@"title":@"快捷入口",@"detail":@"在更多中设置“文件加密”入口",@"type":@"2"},
  @{@"title":@"保留原文件",@"detail":@"加密解密后是否保留原文件",@"type":@"4"},
    @{@"title":@"隐藏文件",@"detail":@"应用内所有的隐藏文件",@"type":@"5"},];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _setttingArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PravicySettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pavicySettingcell" forIndexPath:indexPath];
    NSDictionary *dict = _setttingArray[indexPath.row];
    cell.titleLabel.text = dict[@"title"];
    cell.subTitleLabel.text = dict[@"detail"];
    cell.switchView.tag = 600+[dict[@"type"]integerValue];
    if ([dict[@"type"]integerValue]==5) {
        cell.switchView.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.switchView.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([dict[@"type"]integerValue]==1) {
        if ([XTOOLS getPravicyPassWord]) {
            cell.switchView.on = YES;
        }
        else
        {
            cell.switchView.on = NO;
        }
    }
    else
        if ([dict[@"type"]integerValue]==2) {
            cell.switchView.on = [kUSerD boolForKey:kSettingParvicy];
        }
    else
        if ([dict[@"type"]integerValue]==4) {
           cell.switchView.on = [kUSerD boolForKey:kRetain];
        }
    
    if (cell.switchView.allTargets.count == 0) {
        [cell.switchView addTarget:self
                            action:@selector(cellSwithChange:) forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _setttingArray[indexPath.row];
    if ([dict[@"type"]integerValue] == 1) {
        [self setPravicyPassWord:YES];
    }
    else
        if ([dict[@"type"]integerValue] == 5) {//隐藏文件。
            SelectFileViewController *filesList = [SelectFileViewController allocFromStoryBoard];
            filesList.title = @"隐藏文件";
            filesList.showHiddenFiles = YES;
            [self.navigationController pushViewController:filesList animated:YES];
        }
}
- (void)setPravicyPassWord:(BOOL)isSave {
    if (isSave) {
        if ([XTOOLS getPravicyPassWord]) {//修改密码
            UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"重设默认密码" message:@"重设默认加密密码，已加密文件的密码仍为旧密码。请先输入旧密码验证。" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                
            }];
            UITextField *textField = aler.textFields.firstObject;
            textField.placeholder = @"请输入旧密码验证";
            UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (textField.text.length<=0) {
                    [XTOOLS showMessage:@"密码不能为空"];
                    return ;
                    
                }
                if ([textField.text isEqualToString:[XTOOLS getPravicyPassWord]]) {
                    //密码正确
                    [self createNewPassWord];
                }
                else
                {
                    [XTOOLS showMessage:@"验证失败"];
                    return;
                }
                NSLog(@"==%@",textField.text);
                
                
            }];
            [aler addAction:cancleAction];
            [aler addAction:addAction];
            [self presentViewController:aler animated:YES completion:nil];
        }
        else
        {
            [self createNewPassWord];
 
        }
        
    }
    else
    {
        [XTOOLS showAlertTitle:@"删除密码" message:@"删除默认密码后，加密文件仍需旧密码解密。"buttonTitles:@[NSLocalizedString(@"Cancel", nil),NSLocalizedString(@"Delete", nil)] completionHandler:^(NSInteger num) {
           
            if (num == 1) {
                [self decryPtFiles];
            }
            else
            {
                [self->_mainTableView reloadData];
            }
        }];
    }
}
- (void)createNewPassWord {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"设置密码" message:@"请输入默认加密密码" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"加密密码";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            [XTOOLS showMessage:@"密码不能为空"];
            return ;
            
        }
        else
        {
            if ([XTOOLS getPravicyPassWord]) {
                if ([self exchangeOldPassword:[XTOOLS getPravicyPassWord] toNewPassWord:textField.text]) {
                    [XTOOLS showMessage:@"密码更新成功"];
                   [XTOOLS savePravicyPassword:textField.text];
                }else
                {
                    [XTOOLS showMessage:@"密码更新失败"];
                }
              
            }
            else
            {
              [XTOOLS savePravicyPassword:textField.text];
            }
            
            [self->_mainTableView reloadData];
        }
        
        NSLog(@"==%@",textField.text);
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}
- (void)cellSwithChange:(UISwitch *)switchView {
    if (switchView.tag == 601) {
        [self setPravicyPassWord:switchView.on];
    }
    else if (switchView.tag == 602){
        [kUSerD setBool:switchView.on forKey:kSettingParvicy];
        [kUSerD synchronize];
    }
    else
        if (switchView.tag == 604) {
            [kUSerD setBool:switchView.on forKey:kRetain];
            [kUSerD synchronize];
        }
    
}
- (BOOL)exchangeOldPassword:(NSString *)oldPassw toNewPassWord:(NSString *)newPassw {
    [XTOOLS showLoading:@"更新中"];
    
    NSArray *array = [self getEncryPtFilesArray];
    if (array.count>0) {
       
        NSError *error;
        if (newPassw.length>0&&oldPassw.length>0) {
            for (NSString *name in array) {
                NSString *path = [KDocumentP stringByAppendingPathComponent:name];
//                [NSString stringWithFormat:@"%@/%@",KDocumentP,name];
                NSData *fileData = [NSData dataWithContentsOfFile:path];
                NSData *decryptorData = [RNDecryptor decryptData:fileData withPassword:oldPassw error:&error];
                NSData *newData = [RNEncryptor encryptData:decryptorData withSettings:kRNCryptorAES256Settings password:newPassw error:&error];
                if (error) {
                    [[EncryptDecryptManager defaultManager]DecryptWithPath:path complete:^(BOOL result, NSString *fpath) {
                        if (result) {
                            [kFileM removeItemAtPath:path error:nil];
                        }
                        else
                        {
                            [XTOOLS showMessage:fpath];
                        }
                    }];
                }
                else
                {
                    BOOL write = [newData writeToFile:path atomically:YES];
                    if (!write) {
                        [XTOOLS hiddenLoading];
                        [XTOOLS showMessage:@"解密失败"];
                        return NO;
                    }  
                }
                
                
            }
            [XTOOLS savePravicyPassword:nil];
            
        }
        else
        {
            [XTOOLS hiddenLoading];
            return NO;
        }
    }

    [XTOOLS hiddenLoading];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
- (NSArray *)getEncryPtFilesArray {
    NSError *error;
    NSMutableArray *filesArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:KDocumentP error:&error];
    for (NSString *name in array) {
        if ([name hasSuffix:@".xn"]) {
            [filesArray addObject:name];
        }
        
    }
    return filesArray;
}
- (void)decryPtFiles {
    [[NSNotificationCenter defaultCenter]postNotificationName:krefreshPravicyList object:nil];
    [XTOOLS savePravicyPassword:nil];
    [XTOOLS showMessage:@"密码删除成功"];
//    NSArray *array = [self getEncryPtFilesArray];
//    if (array.count>0) {
//        NSString *passW = [XTOOLS getPravicyPassWord];
//        NSError *error;
//        if (passW.length>0) {
//            for (NSString *name in array) {
//                NSString *path = [KDocumentP stringByAppendingPathComponent:name];
////                [NSString stringWithFormat:@"%@/%@",KDocumentP,name];
//                [[EncryptDecryptManager defaultManager]DecryptWithPath:path complete:^(BOOL result, NSString *fpath) {
//                    if (result) {
//                      [kFileM removeItemAtPath:path error:nil];
//                    }
//                    else
//                    {
//                        [XTOOLS showMessage:fpath];
//                    }
//                }];
//                
//            }
//           
//           
//  
//        }
//        else
//        {
//            
//        }
//    }
    
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
