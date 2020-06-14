//
//  WebCollector+CoreDataProperties.m
//  FileManager
//
//  Created by XiaoDev on 2018/1/31.
//  Copyright © 2018年 xiaodev. All rights reserved.
//
//

#import "WebCollector+CoreDataProperties.h"

@implementation WebCollector (CoreDataProperties)

+ (NSFetchRequest<WebCollector *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WebCollector"];
}

@dynamic image;
@dynamic time;
@dynamic title;
@dynamic url;

@end
