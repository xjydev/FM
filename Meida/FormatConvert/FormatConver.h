//
//  FormatConver.h
//  FileManager
//
//  Created by xiaodev on Jan/10/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatConver : NSObject
@property (nonatomic, copy)NSString *qualityType;
- (void)converFilePath:(NSString *)sourcePath WithType:(NSString *)type completion:(void(^)(NSString *converFilePath))comepleteBlock;
@end
