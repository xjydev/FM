//
//  NetManager.h
//  NetManager
//
//  Created by 阿凡树 on 17-4-7.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^FinishBlockWithObject)(NSError *error, id resultObject);
@interface NetManager : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)getDataWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                               completion:(FinishBlockWithObject)completionBlock;

/**
 *  网络状况的，这个简单，就不写那么多的注释了
 */
+ (NSString *)networkStatusMode;
+ (BOOL)isReachableNet;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
