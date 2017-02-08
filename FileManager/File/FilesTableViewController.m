//
//  FilesTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "FilesTableViewController.h"
#import "FilesListController.h"
#import "ScanViewController.h"
#import "TransferIPViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface FilesTableViewController ()
{
    NSArray        *_tableArray;
    NSMutableArray *_foldersArray;
}
@property (nonatomic,strong)AVPlayer *player;
@end

@implementation FilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableArray = @[@{@"title":@"所有文件",@"type":@"0",@"image":@"path_home"},
  @{@"title":@"视频",@"type":@"1",@"image":@"path_video"},
  @{@"title":@"音频",@"type":@"2",@"image":@"path_audio"},
  @{@"title":@"图片",@"type":@"3",@"image":@"path_image"},
  @{@"title":@"文档",@"type":@"4",@"image":@"path_document"},];
    _foldersArray = [NSMutableArray arrayWithCapacity:0];
   
    UIButton *footButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footButton setImage:[UIImage imageNamed:@"addFile"] forState:UIControlStateNormal];
    footButton.frame = CGRectMake(0, 0, kScreen_Width-40, 44);
    
    footButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    footButton.layer.borderWidth = 0.5;
    [footButton addTarget:self action:@selector(footButtonAddFileAction) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = footButton;
    
    UIBarButtonItem *transferBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"transfer"] style:UIBarButtonItemStyleDone target:self action:@selector(rightTransferButtonAction:)];
    self.navigationItem.rightBarButtonItem = transferBarButton;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];

    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSLog(@"array === %@",array.firstObject);
    [self reloadNewFolders];
    
}
- (void)reloadNewFolders {
    NSArray *fileArray = [kFileM contentsOfDirectoryAtPath:KDocumentP error:nil];
    [_foldersArray removeAllObjects];
    BOOL isFolder = NO;
    for (NSString *folderPath in fileArray) {
        [kFileM fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",KDocumentP,folderPath] isDirectory:&isFolder];
        if (isFolder&&![folderPath hasPrefix:@"."]) {
            [_foldersArray addObject:folderPath];
            isFolder = NO;
        }
    }
    NSLog(@"===%@ ====%@",fileArray,_foldersArray);
    [self.tableView reloadData];
}
- (void)footButtonAddFileAction {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:@"请输入新建文件夹名称" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"新建文件夹";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"新建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            textField.text = @"新建文件夹";
            
        }
        
        NSLog(@"==%@",textField.text);
        NSString *audioPath = [NSString stringWithFormat:@"%@/%@",KDocumentP,textField.text];
        if (![kFileM fileExistsAtPath:audioPath]) {
            if ( [kFileM createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                [XTOOLS showMessage:@"创建成功"];
                [self reloadNewFolders];
            }
            else
            {
                [XTOOLS showMessage:@"创建失败"];
            }
        }
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}
- (void)rightTransferButtonAction:(UIButton *)button {
    TransferIPViewController *transfer = [self.storyboard instantiateViewControllerWithIdentifier:@"TransferIPViewController"];
    transfer.filesTransferChangeBack = ^(int num){
        [self reloadNewFolders];
    };
    [self.navigationController pushViewController:transfer animated:YES];
}
- (void)leftScanButtonAction:(UIBarButtonItem *)button {
    ScanViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return _foldersArray.count;
    }
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesCell" forIndexPath:indexPath];
    if (indexPath.section == 1) {
        cell.textLabel.text = _foldersArray[indexPath.row];
         [cell.imageView setImage:[UIImage imageNamed:@"path_folder"]];
    }
    else
    {
       cell.textLabel.text = _tableArray[indexPath.row][@"title"];
        [cell.imageView setImage:[UIImage imageNamed:_tableArray[indexPath.row][@"image"]]];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
        NSDictionary *dict = _tableArray[indexPath.row];
        filesList.fileType = [dict[@"type"]integerValue];
        filesList.moveArray = _foldersArray;
        filesList.title = dict[@"title"];
        filesList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:filesList animated:YES];
    }
    else
    {
        NSMutableArray *array =[NSMutableArray arrayWithArray: _foldersArray];
        [array removeObjectAtIndex:indexPath.row];
        [array addObject:@""];
        FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
        filesList.fileType = 0;
        filesList.title = _foldersArray[indexPath.row];
        filesList.moveArray = array;
        filesList.filePath = [NSString stringWithFormat:@"%@/%@",KDocumentP,_foldersArray[indexPath.row]];
        filesList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:filesList animated:YES];
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",KDocumentP,_foldersArray[indexPath.row]];
        
        UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
            NSError *error ;
            [kFileM removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"==%@",error);
            }
            NSLog(@"点击删除");
            [_foldersArray removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }];
        
        return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
  
    }
    return nil;
}
@end
