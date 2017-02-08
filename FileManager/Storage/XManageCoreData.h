//
//  XManageCoreData.h
//  ObjectCDemo
//
//  Created by XiaoJingYuan on 8/8/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class WebCollector;
@interface XManageCoreData : NSObject
@property (nonatomic, strong)NSManagedObjectContext *manageObjectContext;
@property (nonatomic, strong)NSManagedObjectModel *manageObjectModel;
@property (nonatomic, strong)NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)manageCoreData;
- (void)saveContext;
- (void)saveObjectsDict:(NSDictionary *)dict forEntityName:(NSString *)name;
- (NSArray *)searchSortDescriptors:(NSDictionary *)descriptiors forEntityName:(NSString *)name searchContext:(NSString *)searchContext;
#pragma mark -- 网页收藏
- (BOOL)saveWebTitle:(NSString *)title url:(NSString *)url;
- (BOOL)deleteWebTitle:(NSString *)title url:(NSString *)url;
- (BOOL)deleteWeb:(WebCollector *)object;
- (BOOL)searchWebUrl:(NSString *)url;
- (NSArray *)getAllWebUrl;
#pragma mark -- 播放记录
- (BOOL)saveRecordName:(NSString *)name path:(NSString *)path record:(float)rate;
- (float)getRecordWithPath:(NSString *)path;
@end
