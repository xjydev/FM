//
//  FilesListTableViewController.h
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XTools.h"
#import <UIKit/UIKit.h>

typedef void (^SelectedPath)(NSString *path);
@interface FilesListController : UIViewController

@property (nonatomic, assign) FileType fileType;//文件种类
@property (nonatomic, copy)NSString *filePath;//默认路径
@property (nonatomic, strong)NSArray  *moveArray;
@property (nonatomic, assign)BOOL     isSelected;//进来是为了选择的。
@property (nonatomic, strong)SelectedPath  selectedPath;

@end
