//
//  EncryptDecryptManager.m
//  FileManager
//
//  Created by xiaodev on Sep/11/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "EncryptDecryptManager.h"
//#import"RNCryptor.h"
#import"RNDecryptor.h"
#import"RNEncryptor.h"
#import "ZipArchive.h"
#import "XTools.h"

static EncryptDecryptManager *_manager = nil;
@interface EncryptDecryptManager ()<ZipArchiveDelegate>
{
    BOOL     _unzipError;
}
@property (nonatomic, strong)ZipArchive  *zipArchive;

@end
@implementation EncryptDecryptManager
+ (instancetype)defaultManager {
    if (!_manager) {
        _manager = [[EncryptDecryptManager alloc]init];
    }
    return _manager;
}
- (ZipArchive *)zipArchive {
    if (!_zipArchive) {
        _zipArchive = [[ZipArchive alloc]initWithFileManager:kFileM];
        _zipArchive.delegate = self;
    }
    return _zipArchive;
}
-(void) ErrorMessage:(NSString*) msg {
    NSLog(@"zip error == %@",msg);
    _unzipError = YES;
}
- (void)EncryptWithPath:(NSString *)filePath complete:(void (^)(BOOL result ,NSString *fpath))completeHandler{
    _encryptComplateHander = completeHandler;
    _unzipError = NO;
    NSString *passW =[XTOOLS getPravicyPassWord];
    if (passW.length==0) {
        
        NSString *aletStr = [NSString stringWithFormat:@"请输入%@的加密密码，并牢记此文件的密码。",filePath.lastPathComponent];
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"加密密码" message:aletStr preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            
        }];
        UITextField *textField = aler.textFields.firstObject;
        textField.placeholder = @"请输入加密密码";
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"只使用这一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (textField.text.length<=0) {
                [XTOOLS showMessage:@"密码不能为空"];
                return ;
                
            }
            else
            {
                NSString *pwstr = [NSString stringWithFormat:@"%@的加密密码是\n%@",filePath.lastPathComponent,textField.text];
                [XTOOLS showAlertTitle:@"牢记密码" message:pwstr buttonTitles:@[@"取消",@"加密"] completionHandler:^(NSInteger num) {
                    if (num ==1) {
                      [self encryptFileWithPath:filePath PassWord:textField.text];
                    }
                }];
                
            }
            
            NSLog(@"==%@",textField.text);
            
            
        }];
        UIAlertAction * defAction = [UIAlertAction actionWithTitle:@"使用并设置为默认密码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (textField.text.length<=0) {
                [XTOOLS showMessage:@"密码不能为空"];
                return ;
                
            }
            else
            {
                NSString *pwstr = [NSString stringWithFormat:@"%@的加密密码是\n%@",filePath.lastPathComponent,textField.text];
                [XTOOLS showAlertTitle:@"牢记密码" message:pwstr buttonTitles:@[@"取消",@"加密"] completionHandler:^(NSInteger num) {
                    if (num ==1) {
                        [XTOOLS savePravicyPassword:textField.text];
                        [self encryptFileWithPath:filePath PassWord:textField.text];
                    }
                }];
               
            }
        }];
        [aler addAction:cancleAction];
        [aler addAction:addAction];
        [aler addAction:defAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:aler animated:YES completion:nil];
    }
    else
    {
        NSString *pwstr = [NSString stringWithFormat:@"%@的加密密码是\n默认加密密码",filePath.lastPathComponent];
        [XTOOLS showAlertTitle:@"牢记密码" message:pwstr buttonTitles:@[@"取消",@"加密"] completionHandler:^(NSInteger num) {
            if (num ==1) {
                [self encryptFileWithPath:filePath PassWord:passW];
            }
        }];
        
    }
    
    
}
- (void)encryptFileWithPath:(NSString *)filePath PassWord:(NSString *)passW {
    [XTOOLS showLoading:@"加密中"];
    NSDictionary *dict = [kFileM attributesOfItemAtPath:filePath error:nil];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        if ([[dict objectForKey:NSFileSize] floatValue]>1024*1024*50) {
            NSString *newFilePath = [NSString stringWithFormat:@"%@%@",filePath,@"z.xn"];
            [self.zipArchive CreateZipFile2:newFilePath Password:passW];
            [self.zipArchive addFileToZip:filePath newname:filePath.lastPathComponent];
            BOOL succ = [self.zipArchive CloseZipFile2];
            [XTOOLS hiddenLoading];
            if (self->_unzipError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.encryptComplateHander) {
                      self.encryptComplateHander(NO,@"加密失败");
                    }
                    
                });
            }
            else
            {
                if (succ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.encryptComplateHander) {
                          self.encryptComplateHander(YES,newFilePath);
                        }
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.encryptComplateHander) {
                            self.encryptComplateHander(NO,@"加密失败");
                        }
                        
                    });
                }
            }
            
            
        }
        else
        {
            NSString *newFilePath = [NSString stringWithFormat:@"%@%@",filePath,@".xn"];
            NSError *error;
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            NSData * encryptorDate = [RNEncryptor encryptData:fileData withSettings:kRNCryptorAES256Settings password:passW error:&error];
            
            BOOL write = [encryptorDate writeToFile:newFilePath atomically:YES];
           
            if (write) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [XTOOLS hiddenLoading];
                    if (self.encryptComplateHander) {
                        self.encryptComplateHander(YES,newFilePath);
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [XTOOLS hiddenLoading];
                    if (self.encryptComplateHander) {
                        self.encryptComplateHander(NO,@"加密失败");
                    }
                });
            }
            
        }
    });
}

- (void)DecryptWithPath:(NSString *)filePath complete:(void (^)(BOOL result ,NSString *fpath))completeHandler {
    _unzipError = NO;
    _decryptComplateHander = completeHandler;
    
    NSString *fileStr = [NSString stringWithFormat:@"请输入%@的加密密码",filePath.lastPathComponent];
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"解密密码" message:fileStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"密码";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            [XTOOLS showMessage:@"密码不能为空"];
            return ;
            
        }
        else
        {
            
            [self decryptWithFilePath:filePath PassWord:textField.text];
        }
        
        NSLog(@"==%@",textField.text);
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:aler animated:YES completion:nil];
}
- (void)decryptWithFilePath:(NSString *)filePath PassWord:(NSString *)passw {
    [XTOOLS showLoading:@"解密中"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        if ([filePath hasSuffix:@"z.xn"]) {
            NSString *newFilePath = [filePath substringToIndex:filePath.length-4];
            NSString *unPath = [filePath substringToIndex:filePath.length - (filePath.lastPathComponent.length)];
            [self.zipArchive UnzipOpenFile:filePath Password:passw];
            [self.zipArchive UnzipFileTo:unPath overWrite:YES];
            NSLog(@"===%@\n==%@",unPath,newFilePath);
            BOOL isunzip = [self.zipArchive UnzipCloseFile];
           
            if (self->_unzipError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [XTOOLS hiddenLoading];
                    if (self.decryptComplateHander) {
                        self.decryptComplateHander(NO,@"解密失败");
                    }
                });
            }
            else
            {
                if (isunzip) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [XTOOLS hiddenLoading];
                        if (self.decryptComplateHander) {
                          self.decryptComplateHander(YES,newFilePath);
                        }
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [XTOOLS hiddenLoading];
                        if (self.decryptComplateHander) {
                            self.decryptComplateHander(NO,@"解密失败");
                        }
                    });
                }
            }
            
        }
        else
            if ([filePath hasSuffix:@".xn"]) {
                NSError *error;
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                NSString *newPath = [filePath substringToIndex:filePath.length-3];
                NSData *decryptorData = [RNDecryptor decryptData:fileData withPassword:passw error:&error];
                if (error) {
                    [self.zipArchive UnzipOpenFile:filePath Password:passw];
                    [self.zipArchive UnzipFileTo:newPath overWrite:YES];
                    BOOL isunzip = [self.zipArchive UnzipCloseFile];
                    if (self->_unzipError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [XTOOLS hiddenLoading];
                            if (self.decryptComplateHander) {
                                self.decryptComplateHander(NO,@"解密失败");
                            }
                        });
                    }
                    else
                    {
                        if (isunzip) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [XTOOLS hiddenLoading];
                                if (self.decryptComplateHander) {
                                    self.decryptComplateHander(YES,newPath);
                                }
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [XTOOLS hiddenLoading];
                                if (self.decryptComplateHander) {
                                    self.decryptComplateHander(NO,@"解密失败");
                                }
                            });
                        }
                    }
                    
                    
                }
                else
                {
                    if (decryptorData.length<20) {
                        [XTOOLS hiddenLoading];
                        if (self.decryptComplateHander) {
                            self.decryptComplateHander(NO,@"解密失败");
                        }
                    }
                    else
                    {
                        BOOL write = [decryptorData writeToFile:newPath atomically:YES];
                        if (write) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [XTOOLS hiddenLoading];
                                if (self.decryptComplateHander) {
                                    self.decryptComplateHander(YES,newPath);
                                }
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [XTOOLS hiddenLoading];
                                if (self.decryptComplateHander) {
                                    self.decryptComplateHander(NO,@"解密失败");
                                }
                                
                            });
                        }
                    }
                    
                }
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [XTOOLS hiddenLoading];
                    if (self.decryptComplateHander) {
                        self.decryptComplateHander(NO,@"不支持解密");
                    }
                });
            }
    });
}

@end
