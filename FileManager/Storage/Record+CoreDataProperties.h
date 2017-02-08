//
//  Record+CoreDataProperties.h
//  FileManager
//
//  Created by xiaodev on Jan/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
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
