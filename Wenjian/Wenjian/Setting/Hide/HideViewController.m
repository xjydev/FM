//
//  HideViewController.m
//  Wenjian
//
//  Created by xiaodev on Oct/24/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "HideViewController.h"
#import "XTools.h"
#import "UIView+xiao.h"
#include "sys/stat.h"
#import "FileDetailController.h"
//#import "UIViewController+JY.h"
@interface HideViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *_mainTableView;
   
}
@property (nonatomic, strong) NSMutableArray  *filesArray;

@end

@implementation HideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"隐藏文件";
    if (self.folderPath.length == 0) {
        self.folderPath = KDocumentP;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(settingAction)];
//    [self setleftBackButton];
     self.filesArray = [NSMutableArray arrayWithCapacity:0];
    
    [XTOOLS showAlertTitle:@"注意" message:@"隐藏文件不要轻易修改删除,以免引起应用异常!" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
        
    }];
    
}
- (void)settingAction {
    [self performSegueWithIdentifier:@"HidenSetViewController" sender:nil];
}
- (void)reloadFiles {
    [self.filesArray removeAllObjects];
    NSError *error;
    
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.folderPath error:&error];
    for (NSString *name in array) {
        if ([self.folderPath isEqualToString:KDocumentP]) {//主目录是因为文件，其他目录就全部文件。
            if ([name.lastPathComponent hasPrefix:@"."]) {
                [self.filesArray addObject:name];
            }
        }
        else {
           [self.filesArray addObject:name];
        }
    }
    if (self.filesArray.count!=0) {
        [_mainTableView xRemoveNoData];
    }
    else
    {
        [_mainTableView xNoDataThisViewTitle:@"无文件" centerY:198];
    }
    [_mainTableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hidenfilecell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    UIButton *accessoryButton =(UIButton *)cell.accessoryView;
    [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
    
    NSString *pathName = self.filesArray[indexPath.row];
    cell.textLabel.text = pathName;
    NSString *path = pathName;
    if (![path hasPrefix:self.folderPath]) {
        path = [self.folderPath stringByAppendingPathComponent:path];
    }
    float store = [self fileSizeAtPath:[self.folderPath stringByAppendingPathComponent:path]];
    //[NSString stringWithFormat:@"%@/%@",KDocumentP,pathName]
    cell.detailTextLabel.text = [XTOOLS storageSpaceStringWith:store];
    switch ([XTOOLS fileFormatWithPath:pathName]) {
        case FileTypeFolder:
            [cell.imageView setImage:[UIImage imageNamed:@"file_folder"]];
            break;
        case FileTypeAudio:
            [cell.imageView setImage:[UIImage imageNamed:@"file_audio"]];
            break;
        case FileTypeImage:
            [cell.imageView setImage:[UIImage imageNamed:@"file_image"]];
            break;
        case FileTypeVideo:
            [cell.imageView setImage:[UIImage imageNamed:@"file_video"]];
            break;
        case FileTypeCompress:
            [cell.imageView setImage:[UIImage imageNamed:@"file_zip"]];
            break;
        case FileTypeDocument:
            [cell.imageView setImage:[UIImage imageNamed:@"file_document"]];
            break;
        default:
            [cell.imageView setImage:[UIImage imageNamed:@"file_unknown"]];
            break;
    }
    
    return cell;
}
- (long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *path = self.filesArray[indexPath.row];
    if (![path hasPrefix:self.folderPath]) {
        path = [self.folderPath stringByAppendingPathComponent:path];
    }
    //    [NSString stringWithFormat:@"%@/%@",KDocumentP,_filesArray[indexPath.row]];
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = self.filesArray[indexPath.row];
    if (![path hasPrefix:self.folderPath]) {
        path = [self.folderPath stringByAppendingPathComponent:path];
    }
    BOOL isDir = NO;
    [kFileM fileExistsAtPath:path isDirectory:&isDir];
    if (isDir) {
        HideViewController *hid = [self.storyboard instantiateViewControllerWithIdentifier:@"HideViewController"];
        hid.folderPath = path;
        [self.navigationController pushViewController:hid animated:YES];
    }
    else {
        BOOL isPlay = [XTOOLS playFileWithPath:path OrigionalWiewController:self];
        if (!isPlay) {
            [XTOOLS showMessage:@"格式不支持"];
        }
    }
    
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *blueRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSError *error ;
        NSString *path = self.filesArray[indexPath.row];
        if (![path hasPrefix:self.folderPath]) {
            path = [self.folderPath stringByAppendingPathComponent:path];
        }
        [kFileM removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [self.filesArray removeObjectAtIndex:indexPath.row];
        [_mainTableView reloadData];
        
    }];
    
    return @[blueRoWAction];//最后返回这俩个RowAction 的数组
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFiles];
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
