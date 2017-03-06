//
//  XManageCoreData.m
//  ObjectCDemo
//
//  Created by XiaoJingYuan on 8/8/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import "XManageCoreData.h"
#import "WebCollector+CoreDataClass.h"
#import "Record+CoreDataClass.h"
#import "Download+CoreDataProperties.h"
#import "XTools.h"
static XManageCoreData *_manageCoredata = nil;

@implementation XManageCoreData
+ (id)manageCoreData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manageCoredata = [[XManageCoreData alloc]init];
    });
    return _manageCoredata;
}
- (NSManagedObjectModel *)manageObjectModel {
    if (_manageObjectModel != nil) {
        return _manageObjectModel;
    }
    //应用程序中加载模型文件
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"FileModel" withExtension:@"momd"];
    _manageObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:url];
//     _manageObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _manageObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    //根据模型对象初始化NSPersistentStoreCoordinator
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.manageObjectModel];
    NSString *storePath = [NSString stringWithFormat:@"%@/FilesModel.sqlite",XTOOLS.hiddenFilePath];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isDeleteDB2"]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:storePath] error:nil];   //删除数据库
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDeleteDB2"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:
         &error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedFailureReasonErrorKey] = @"coredata 初始化失败";
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        abort();
    }
    return _persistentStoreCoordinator;
}
- (NSManagedObjectContext *)manageObjectContext
{
    if (_manageObjectContext != nil) {
        return _manageObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _manageObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_manageObjectContext setPersistentStoreCoordinator:coordinator];
    return _manageObjectContext;
}
- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.manageObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges]&&! [managedObjectContext save:&error] ) {
            NSLog(@"unresolved error  %@, %@",error,[error userInfo]);
//            abort();
        }
    }
}
#pragma mark -- 网页收藏
- (BOOL)saveWebTitle:(NSString *)title url:(NSString *)url {
    WebCollector *webObject = [NSEntityDescription insertNewObjectForEntityForName:@"WebCollector" inManagedObjectContext:self.manageObjectContext];
    webObject.title = title;
    webObject.url = url;
    NSError *error = nil;
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
//        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    return YES;
}
- (BOOL)deleteWebTitle:(NSString *)title url:(NSString *)url {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"WebCollector"];
        request.predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    NSError *error = nil;
        NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
        if (error) {
//            [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        }
    
        for (WebCollector *object in objets) {
    [self.manageObjectContext deleteObject:object];
        }
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
//        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    return YES;
}
- (BOOL)deleteWeb:(WebCollector *)object {

    NSError *error = nil;
    [self.manageObjectContext deleteObject:object];

    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
//        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    return YES;
}
- (BOOL)searchWebUrl:(NSString *)url {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"WebCollector"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
//        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
    }
    //结果大于0就是包含了。
    return objets.count>0;
}
- (NSArray *)getAllWebUrl {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WebCollector"];

    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
//        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
    }
    return objets;
  
}


- (void)saveObjectsDict:(NSDictionary *)dict forEntityName:(NSString *)name
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.manageObjectContext];
    for (NSString * key in dict.allKeys) {
        [object setValue:dict[key] forKey:key];
    }
    NSError *error = nil;
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
//        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
    }
    
    
}
- (NSArray *)searchSortDescriptors:(NSDictionary *)descriptiors forEntityName:(NSString *)name searchContext:(NSString *)searchContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.manageObjectContext];
    NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:descriptiors.allKeys.count];
    for (NSString *key in descriptiors.allKeys) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:[descriptiors[key] boolValue]];
        [muArray addObject:sort];
    }
    request.sortDescriptors = muArray;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@",@"*1*"];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
//        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        [XTOOLS showMessage:@"查询错误"];
    }
    return objets;
    
}
#pragma mark -- 播放记录
- (BOOL)saveRecordName:(NSString *)name path:(NSString *)path record:(float)rate {
    path = [path substringFromIndex:KDocumentP.length];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@",path];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
//        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        [XTOOLS showMessage:@"查询错误"];
        return NO;
    }
    if (objets.count>0) {
        for (Record *object in objets) {
            object.progress = rate;
        }
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
//            [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
            [XTOOLS showMessage:@"访问错误"];
            return NO;
        }
    }
    else
    {
        Record *recordObject = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:self.manageObjectContext];
        recordObject.name = name;
        recordObject.path = path;
        recordObject.progress = rate;
        NSError *error = nil;
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
//            [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
            [XTOOLS showMessage:@"访问错误"];
            return NO;
        }
        
    }
    
return YES;
    
}
- (float)getRecordWithPath:(NSString *)path {
    path = [path substringFromIndex:KDocumentP.length];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@",path];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
//        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        [XTOOLS showMessage:@"查询错误"];
        return 0.0;
    }
    
    for (Record *object in objets) {
        return object.progress;
    }
    return 0.0;

}
#pragma  mark --下载记录
- (BOOL)saveDownloadUrl:(NSString *)url Progress:(float)progress downLoadPath:(NSString *)path {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        [XTOOLS showMessage:@"查询错误"];
        return NO;
    }
    if (objets.count>0) {
        for (Download *object in objets) {
            object.progress = progress;
            object.path = path;
            object.name = path.lastPathComponent;
        }
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
            //            [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
            [XTOOLS showMessage:@"访问错误"];
            return NO;
        }
    }
    else
    {
        Download *downloadObject = [NSEntityDescription insertNewObjectForEntityForName:@"Download" inManagedObjectContext:self.manageObjectContext];
        downloadObject.name = path.lastPathComponent;
        downloadObject.path = path;
        downloadObject.progress = progress;
        downloadObject.url = url;
//        [self.manageObjectContext insertObject:downloadObject];
        NSError *error = nil;
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
            //            [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
            [XTOOLS showMessage:@"访问错误"];
            return NO;
        }
        
    }
    
    return YES;

}
- (NSArray *)allDownload {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        
    }
    return objets;
}
- (BOOL)deleteDownloadUrl:(NSString *)url {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Download"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        
        [XTOOLS showMessage:@"查询错误"];
        return NO;
    }
    if (objets.count>0) {
        for (Download *object in objets) {
            [self.manageObjectContext deleteObject:object];
        }
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
            
            [XTOOLS showMessage:@"访问错误"];
            return NO;
        }
    }
    return YES;
}
- (BOOL)deleteDownLoadModel:(Download *)model {
    [self.manageObjectContext deleteObject:model];
    NSError *error = nil;
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
        
        [XTOOLS showMessage:@"访问错误"];
        return NO;
    }
    return YES;
}
@end
