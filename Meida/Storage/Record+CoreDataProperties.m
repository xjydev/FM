//
//  Record+CoreDataProperties.m
//  Wenjian
//
//  Created by XiaoDev on 2019/4/12.
//  Copyright © 2019 XiaoDev. All rights reserved.
//
//

#import "Record+CoreDataProperties.h"

@implementation Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Record"];
}

@dynamic iconpath;
@dynamic name;
@dynamic path;
@dynamic progress;
@dynamic time;
@dynamic totalTime;
@dynamic fileType;
@dynamic size;
@dynamic markInt;
@dynamic addDate;
@dynamic modifyDate;
@dynamic createDate;

@end
