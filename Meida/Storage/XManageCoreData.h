//
//  XManageCoreData.h
//  ObjectCDemo
//
//  Created by XiaoJingYuan on 8/8/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WebCollector+CoreDataClass.h"
#import "Record+CoreDataClass.h"
#import "Download+CoreDataProperties.h"
#import "WebHistory+CoreDataProperties.h"

@interface XManageCoreData : NSObject
@property (nonatomic, strong)NSManagedObjectContext *manageObjectContext;
@property (nonatomic, strong)NSManagedObjectModel *manageObjectModel;
@property (nonatomic, strong)NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

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
- (Record *)createRecordWithPath:(NSString *)path;
- (BOOL)saveRecordName:(NSString *)name path:(NSString *)path record:(float)rate totalTime:(int)totalTime iconPath:(NSString *)iconPath;
- (Record *)getRecordObjectWithPath:(NSString *)path;
- (float)getRecordWithPath:(NSString *)path;
- (NSArray *)getAllRecord;
- (NSArray *)getAllMarkFiles;
- (BOOL)clearAllRecord ;
- (BOOL)deleteRecord:(Record *)object;
- (BOOL)saveRecord:(Record *)object;
- (BOOL)deleteRecordPath:(NSString *)path;
#pragma  mark --下载记录
- (BOOL)saveDownloadUrl:(NSString *)url Progress:(float)progress downLoadPath:(NSString *)path;
- (NSArray *)allDownload;
- (BOOL)deleteDownloadUrl:(NSString *)url;
- (BOOL)deleteDownLoadModel:(Download *)model;
#pragma mark -- 浏览记录
- (BOOL)saveWebHistoryTitle:(NSString *)title url:(NSString *)url;
- (NSArray *)getAllWebHistorypage:(int)page;
- (BOOL)deleteWEbHistory:(WebHistory *)model;
- (BOOL)clearAllHistory;
@end
