//
//  Download+CoreDataProperties.m
//  FileManager
//
//  Created by XiaoDev on 2018/1/31.
//  Copyright © 2018年 xiaodev. All rights reserved.
//
//

#import "Download+CoreDataProperties.h"

@implementation Download (CoreDataProperties)

+ (NSFetchRequest<Download *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Download"];
}

@dynamic name;
@dynamic path;
@dynamic progress;
@dynamic url;

@end
