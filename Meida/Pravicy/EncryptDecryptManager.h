//
//  EncryptDecryptManager.h
//  FileManager
//
//  Created by xiaodev on Sep/11/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void((^ComplateHanderBlock)(BOOL ,NSString *)) ;
@interface EncryptDecryptManager : NSObject
@property (nonatomic, copy)ComplateHanderBlock encryptComplateHander;
@property (nonatomic, copy)ComplateHanderBlock decryptComplateHander;
+ (instancetype)defaultManager;
- (void)EncryptWithPath:(NSString *)filePath complete:(ComplateHanderBlock)completeHandler;
- (void)DecryptWithPath:(NSString *)filePath complete:(ComplateHanderBlock)completeHandler;

@end
