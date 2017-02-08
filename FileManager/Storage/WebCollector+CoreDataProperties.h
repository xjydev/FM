//
//  WebCollector+CoreDataProperties.h
//  FileManager
//
//  Created by xiaodev on Jan/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "WebCollector+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WebCollector (CoreDataProperties)

+ (NSFetchRequest<WebCollector *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *image;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
