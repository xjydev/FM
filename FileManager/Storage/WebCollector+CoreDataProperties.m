//
//  WebCollector+CoreDataProperties.m
//  FileManager
//
//  Created by xiaodev on Mar/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "WebCollector+CoreDataProperties.h"

@implementation WebCollector (CoreDataProperties)

+ (NSFetchRequest<WebCollector *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WebCollector"];
}

@dynamic image;
@dynamic title;
@dynamic url;

@end
