//
//  XQuickLookController.m
//  FileManager
//
//  Created by xiaodev on Dec/23/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XQuickLookController.h"
#import "XTools.h"
#import "UMMobClick/MobClick.h"

@interface XQuickLookController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@end

@implementation XQuickLookController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    self.currentPreviewItemIndex = self.currentIndex;
}
#pragma mark -- datasource协议方法
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    
    return self.itemArray.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSString *path = self.itemArray[index];
    if (![path hasPrefix:KDocumentP]) {
        path = [NSString stringWithFormat:@"%@/%@",KDocumentP,self.itemArray[index]];
    }
    if ([path hasSuffix:@"txt"] || [path hasSuffix:@"TXT"]) {
        // 处理txt格式内容显示有乱码的情况
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        // 判断是UNICODE编码
        NSString *isUNICODE = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        // 还是ANSI编码（-2147483623，-2147482591，-2147482062，-2147481296）encoding 任选一个就可以了
        NSString *isANSI = [[NSString alloc] initWithData:fileData encoding:-2147483623];
        if (isUNICODE) {
        } else {
            NSData *data = [isANSI dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:path atomically:YES];
        }
        return [NSURL fileURLWithPath:path];
    } else {
   
    return [NSURL fileURLWithPath:path];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"Document"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Document"];
}

@end
