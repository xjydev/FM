//
//  Record+CoreDataProperties.h
//  FileManager
//
//  Created by xiaodev on Mar/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Record+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *path;
@property (nonatomic) float progress;

@end

NS_ASSUME_NONNULL_END
