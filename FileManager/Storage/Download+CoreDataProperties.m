//
//  Download+CoreDataProperties.m
//  FileManager
//
//  Created by xiaodev on Mar/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Download+CoreDataProperties.h"

@implementation Download (CoreDataProperties)

+ (NSFetchRequest<Download *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Download"];
}

@dynamic name;
@dynamic url;
@dynamic path;
@dynamic progress;

@end
