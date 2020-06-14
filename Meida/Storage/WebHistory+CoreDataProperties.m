//
//  WebHistory+CoreDataProperties.m
//  FileManager
//
//  Created by XiaoDev on 2018/1/31.
//  Copyright © 2018年 xiaodev. All rights reserved.
//
//

#import "WebHistory+CoreDataProperties.h"

@implementation WebHistory (CoreDataProperties)

+ (NSFetchRequest<WebHistory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WebHistory"];
}

@dynamic time;
@dynamic title;
@dynamic url;

@end
