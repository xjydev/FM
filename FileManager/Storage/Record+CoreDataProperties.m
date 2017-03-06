//
//  Record+CoreDataProperties.m
//  FileManager
//
//  Created by xiaodev on Mar/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "Record+CoreDataProperties.h"

@implementation Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Record"];
}

@dynamic name;
@dynamic path;
@dynamic progress;

@end
