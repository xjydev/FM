//
//  Record+CoreDataProperties.m
//  FileManager
//
//  Created by xiaodev on Jan/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
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
