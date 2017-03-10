//
//  FaceTransferViewController.m
//  FileManager
//
//  Created by xiaodev on Feb/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "FaceTransferViewController.h"
#import "FileDetailController.h"
#import "FaceTransferView.h"
#import "XTools.h"
#include "sys/stat.h"
@interface FaceTransferViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *_mainTableView;
    NSMutableArray  *_filesArray;
}
@end

@implementation FaceTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择传输文件";
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithTitle:@"蓝牙" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBar;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
//   [self setAutomaticallyAdjustsScrollViewInsets:NO];
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    [self reloadFilesArray];
}
- (void)rightBarButtonAction:(UIBarButtonItem *)bar {
    
}
- (void)reloadFilesArray {
    NSError *error;
    
    NSArray *array = [kFileM contentsOfDirectoryAtPath:KDocumentP error:&error];
    [_filesArray removeAllObjects];
    for (NSString *name in array) {
        if (![name hasPrefix:@"."]) {
            [_filesArray addObject:name];
        }
        
    }
    [_mainTableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"faceTransferCellId" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    UIButton *accessoryButton =(UIButton *)cell.accessoryView;
    [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
   
    NSString *pathName = _filesArray[indexPath.row];
    cell.textLabel.text = pathName;
    float store = [self fileSizeAtPath:[NSString stringWithFormat:@"%@/%@",KDocumentP,pathName]];
    cell.detailTextLabel.text = [XTOOLS storageSpaceStringWith:store];
    switch ([XTOOLS fileFormatWithPath:pathName]) {
        case FileTypeFolder:
            [cell.imageView setImage:[UIImage imageNamed:@"path_folder"]];
            break;
        case FileTypeAudio:
            [cell.imageView setImage:[UIImage imageNamed:@"header_audio"]];
            break;
        case FileTypeImage:
            [cell.imageView setImage:[UIImage imageNamed:@"header_image"]];
            break;
        case FileTypeVideo:
            [cell.imageView setImage:[UIImage imageNamed:@"header_video"]];
            break;
        case FileTypeCompress:
            [cell.imageView setImage:[UIImage imageNamed:@"header_zip"]];
            break;
        case FileTypeDocument:
            [cell.imageView setImage:[UIImage imageNamed:@"header_document"]];
            break;
        default:
            [cell.imageView setImage:[UIImage imageNamed:@"file_unknow"]];
            break;
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [NSString stringWithFormat:@"%@/%@",KDocumentP,_filesArray[indexPath.row]];
    FileDetailController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"FileDetailController"];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = _filesArray[indexPath.row];
    [[FaceTransferView defaultTransfer]showQRCodeWithStr:path];
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *blueRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"蓝牙" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        }];
    UITableViewRowAction *wifiRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"局域网" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
    }];
    
    return @[wifiRoWAction,blueRoWAction];//最后返回这俩个RowAction 的数组
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
