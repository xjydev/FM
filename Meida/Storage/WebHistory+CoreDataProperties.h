//
//  WebHistory+CoreDataProperties.h
//  FileManager
//
//  Created by XiaoDev on 2018/1/31.
//  Copyright © 2018年 xiaodev. All rights reserved.
//
//

#import "WebHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WebHistory (CoreDataProperties)

+ (NSFetchRequest<WebHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *time;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
