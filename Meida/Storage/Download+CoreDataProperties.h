//
//  Download+CoreDataProperties.h
//  FileManager
//
//  Created by XiaoDev on 2018/1/31.
//  Copyright © 2018年 xiaodev. All rights reserved.
//
//

#import "Download+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Download (CoreDataProperties)

+ (NSFetchRequest<Download *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *path;
@property (nullable, nonatomic, copy) NSNumber * progress;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
