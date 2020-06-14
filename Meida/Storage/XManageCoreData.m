//
//  XManageCoreData.m
//  ObjectCDemo
//
//  Created by XiaoJingYuan on 8/8/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import "XManageCoreData.h"
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
    @synchronized (self) {
        if (_manageObjectModel != nil) {
            return _manageObjectModel;
        }
        //应用程序中加载模型文件
        NSURL *url = [[NSBundle mainBundle]URLForResource:@"FileModel" withExtension:@"momd"];
        _manageObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:url];
    }
    //     _manageObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _manageObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    @synchronized (self) {
        if (_persistentStoreCoordinator != nil) {
            return _persistentStoreCoordinator;
        }
        //根据模型对象初始化NSPersistentStoreCoordinator
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.manageObjectModel];
        NSString *storePath = [NSString stringWithFormat:@"%@/FilesModel.sqlite",XTOOLS.hiddenFilePath];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isDeleteDB5"]) {
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:storePath] error:nil];   //删除数据库
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDeleteDB5"];
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
    }
    return _persistentStoreCoordinator;
}
- (NSManagedObjectContext *)manageObjectContext
{
    if (IOSSystemVersion>=10.0) {
        if (self.persistentContainer) {
            return self.persistentContainer.viewContext;
        }
        else {
            return nil;
        }  
    }
    else {
        if (!_manageObjectContext) {
            @synchronized (self) {
                NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
                if (!coordinator) {
                    return nil;
                }
                _manageObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                [_manageObjectContext setPersistentStoreCoordinator:coordinator];
            }
        }
        return _manageObjectContext;
    }
    
}
@synthesize persistentContainer = _persistentContainer;
- (NSPersistentContainer *)persistentContainer  API_AVAILABLE(ios(10.0)){
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"FileModel"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    //                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}


- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)saveContext {
    @try {
        NSManagedObjectContext *managedObjectContext = self.manageObjectContext;
        if (managedObjectContext != nil) {
            NSError *error = nil;
            if ([managedObjectContext hasChanges]) {
                [managedObjectContext save:&error];
                NSLog(@"unresolved error  %@, %@",error,[error userInfo]);
                //            abort();
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
   
}
#pragma mark -- 网页收藏
- (BOOL)saveWebTitle:(NSString *)title url:(NSString *)url {
    @try {
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
    } @catch (NSException *exception) {
        NSLog(@"==%@",exception);
        return NO;
    } @finally {
        
    }
    
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
        NSLog(@"allweb %@",error);
    }
    return objets;
  
}


- (void)saveObjectsDict:(NSDictionary *)dict forEntityName:(NSString *)name
{
    @try {
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.manageObjectContext];
        for (NSString * key in dict.allKeys) {
            [object setValue:dict[key] forKey:key];
        }
        NSError *error = nil;
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
            //        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        }
    } @catch (NSException *exception) {
        NSLog(@"save == %@",exception);
    } @finally {
        
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
- (Record *)createRecordWithPath:(NSString *)path {
    NSLog(@"p == %@",path);
    path = kSubDokument(path);
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@",path];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (objets.count > 0) {
        return objets.firstObject;
    }
    else {
        Record *recordObject = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:self.manageObjectContext];
        recordObject.name = path.lastPathComponent;
        recordObject.path = path;
        recordObject.fileType = @([XTOOLS fileFormatWithPath:path]);
        recordObject.modifyDate = [NSDate date];
        recordObject.createDate = [NSDate date];
        NSError *error = nil;
        [self.manageObjectContext insertObject:recordObject];
        [self.manageObjectContext save:&error];
        return recordObject;
    }
}
- (BOOL)saveRecordName:(NSString *)name path:(NSString *)path record:(float)rate totalTime:(int)totalTime iconPath:(NSString *)iconPath {
    @try {
        if ([iconPath hasPrefix:kCachesP]) {
            iconPath = [iconPath substringFromIndex:kCachesP.length];
        }
        path = kSubDokument(path);
        NSError *error = nil;
        
        Record *object = [self createRecordWithPath:path];
        if (![kUSerD boolForKey:kNoTrace]) {//如果无痕浏览，就不更新进程。
            if (rate>0) {
                object.progress = [NSNumber numberWithFloat:rate];
            }
            object.modifyDate = [NSDate date];
        }
        object.totalTime = [NSNumber numberWithInt:totalTime];
        if (iconPath) {
            object.iconpath = iconPath;
        }
        
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
            //            [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
            [XTOOLS showMessage:NSLocalizedString(@"Error", nil)];
            return NO;
        }
        else {
            [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshHome object:nil];
        }
        return YES;
    } @catch (NSException *exception) {
        return NO;
        NSLog(@"saveRecord==%@",exception);
    } @finally {
        
    }
}

- (Record *)getRecordObjectWithPath:(NSString *)path {
    path = kSubDokument(path);
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@",path];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"===%@",error);
        return nil;
    }
    if (objets.count > 0) {
        return objets.firstObject;
    }
    return nil;
}
- (float)getRecordWithPath:(NSString *)path {
    if ([kUSerD boolForKey:kNoTrace]) {//如果无痕浏览，就返回刚开始。
        return 0.0;
    }
    path = kSubDokument(path);
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@",path];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"===%@",error);
//        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        [XTOOLS showMessage:@"查询错误"];
        return 0.0;
    }
    
    for (Record *object in objets) {
        NSLog(@"object == %@",object);
        return object.progress.floatValue;
    }
    return 0.0;

}
- (NSArray *)getAllRecord {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"modifyDate" ascending:NO];
    request.sortDescriptors=@[sort];//按时间排序
    request.predicate = [NSPredicate predicateWithFormat:@"progress > 0.0 and fileType != 6"];//只获取有记录的
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        return nil;
    }
    return objets;

}
- (NSArray *)getAllMarkFiles {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    request.sortDescriptors=@[sort];//按时间排序
    request.predicate = [NSPredicate predicateWithFormat:@"markInt > 0"];//只获取有记录的
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        return nil;
    }
    return objets;
}
- (BOOL)deleteRecord:(Record *)object {
    NSError *error = nil;
    [self.manageObjectContext deleteObject:object];
    
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
        //        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    return YES;
  
}
- (BOOL)saveRecord:(Record *)object {
    if ([kUSerD boolForKey:kNoTrace]) {//如果无痕浏览，就不更新进程。
       return YES;
    }
    NSError *error = nil;
    if ([object.path hasPrefix:KDocumentP]) {
        object.path = kSubDokument(object.path);
    }
    object.modifyDate = [NSDate date];
    [self.manageObjectContext refreshObject:object mergeChanges:YES];
    BOOL success = [self.manageObjectContext save:&error];
    return success;
}
- (BOOL)deleteRecordPath:(NSString *)path {
    path = kSubDokument(path);
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@",path];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"===%@",error);
        //        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        [XTOOLS showMessage:@"查询错误"];
        return NO;
    }
    
    for (Record *object in objets) {
        NSLog(@"object == %@",object);
        [self.manageObjectContext deleteObject:object];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshHome object:nil];
    return YES;
}
- (BOOL)clearAllRecord {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    request.sortDescriptors=@[sort];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    for (Record *r in objets) {
        [self.manageObjectContext deleteObject:r];
    }
    
    if (error) {
        //        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
        //        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    return YES;
}
#pragma  mark --下载记录
- (BOOL)saveDownloadUrl:(NSString *)url Progress:(float)progress downLoadPath:(NSString *)path {
    @try {
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
                object.progress =[NSNumber numberWithFloat: progress];
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
            downloadObject.progress = [NSNumber numberWithFloat:progress];
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
    } @catch (NSException *exception) {
        return NO;
        NSLog(@"saveDownload==%@",exception);
    } @finally {
        
    }
    

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
#pragma mark -- 浏览记录
- (BOOL)saveWebHistoryTitle:(NSString *)title url:(NSString *)url {
//    @try {
    WebHistory *webObject = [NSEntityDescription insertNewObjectForEntityForName:@"WebHistory" inManagedObjectContext:self.manageObjectContext];
//    [NSEntityDescription insertNewObjectForEntityForName:@"WebHistory" inManagedObjectContext:self.manageObjectContext];
        webObject.title = title;
        webObject.url = url;
        webObject.time = [NSDate date];
        NSError *error = nil;
        BOOL success = [self.manageObjectContext save:&error];
        if (!success) {
            //        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
            NSLog(@"save web error");
            return NO;
        }
    NSLog(@"save web == %@ %@",title,url);
        return YES;
//    } @catch (NSException *exception) {
//        NSLog(@"==%@",exception);
//        return NO;
//    } @finally {
//
//    }
}
- (NSArray *)getAllWebHistorypage:(int)page {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WebHistory"];
    [request setFetchLimit:50];
    [request setFetchOffset:page*50];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //        [NSException raise:@"查询错误" format:@"%@",[error localizedDescription]];
        NSLog(@"allhistory == %@",error);
    }
    return objets;
}
- (BOOL)deleteWEbHistory:(WebHistory *)model {
    NSError *error = nil;
    [self.manageObjectContext deleteObject:model];
    
    BOOL success = [self.manageObjectContext save:&error];
    if (!success) {
        //        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
        return NO;
    }
    return YES;
}
- (BOOL)clearAllHistory {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WebHistory"];
    
    NSError *error = nil;
    NSArray *objets = [self.manageObjectContext executeFetchRequest:request error:&error];
    for (WebHistory *m in objets) {
        [self.manageObjectContext deleteObject:m];
    }
    if (error) {
        return NO;
    }
    return YES;
}
@end
