//
//  Record+CoreDataProperties.h
//  Wenjian
//
//  Created by XiaoDev on 2019/4/12.
//  Copyright © 2019 XiaoDev. All rights reserved.
//
//

#import "Record+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *iconpath;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *path;
@property (nullable, nonatomic, copy) NSNumber * progress;
@property (nullable, nonatomic, copy) NSDate * time;//观看的时间，
@property (nullable, nonatomic, copy) NSNumber * totalTime;//总时间
@property (nullable, nonatomic, copy) NSNumber * fileType;
@property (nullable, nonatomic, copy) NSNumber * size;
@property (nullable, nonatomic, copy) NSNumber * markInt;
@property (nullable, nonatomic, copy) NSDate *addDate;
@property (nullable, nonatomic, copy) NSDate *modifyDate;
@property (nullable, nonatomic, copy) NSDate *createDate;

@end

NS_ASSUME_NONNULL_END
