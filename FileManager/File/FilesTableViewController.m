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
#import "SafeView.h"
#import "XManageCoreData.h"
#import "Record+CoreDataProperties.h"
#import "XimageViewController.h"
#import "VideoListController.h"
#import "GuideViewController.h"

@interface FilesTableViewController ()
{
    NSArray        *_tableArray;
    NSMutableArray *_foldersArray;
    NSMutableArray *_recordArray;
    BOOL            _needRefresh;
    
}
//@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic, assign)BOOL isVisible;
@end

@implementation FilesTableViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_needRefresh) {
        _needRefresh = NO;
        [self reloadNewFolders];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isVisible = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isVisible = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([kUSerD objectForKey:KPassWord]){//密码手势
        [SafeView defaultSafeView].type = PassWordTypeDefault;
        [[SafeView defaultSafeView] showSafeViewHandle:^(NSInteger num) {
            
        }];
    }
    if ([XTOOLS showAdview] && ![kUSerD boolForKey:kENTRICY]) {//如果购买了去广告或者加密就去除标识。
        UITabBarController *tab = self.navigationController.tabBarController;
        UINavigationController *nav3 = tab.viewControllers.lastObject;
        nav3.tabBarItem.badgeValue = @"1";
    }
    _tableArray = @[@{@"title":NSLocalizedString(@"All Files", nil),@"type":@"0",@"image":@"path_home"},
  @{@"title":NSLocalizedString(@"Video", nil),@"type":@"1",@"image":@"path_video"},
  @{@"title":NSLocalizedString(@"Audio", nil),@"type":@"2",@"image":@"path_audio"},
  @{@"title":NSLocalizedString(@"Image", nil),@"type":@"3",@"image":@"path_image"},
  @{@"title":NSLocalizedString(@"Documents", nil),@"type":@"4",@"image":@"path_document"},];
    _foldersArray = [NSMutableArray arrayWithCapacity:0];
   
    UIButton *footButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footButton setImage:[UIImage imageNamed:@"addFile"] forState:UIControlStateNormal];
    footButton.frame = CGRectMake(0, 0, kScreen_Width-40, 44);
//    footButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    footButton.layer.borderWidth = 0.5;
    [footButton addTarget:self action:@selector(footButtonAddFileAction) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = footButton;
    
    UIBarButtonItem *transferBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"transfer"] style:UIBarButtonItemStyleDone target:self action:@selector(rightTransferButtonAction:)];
    self.navigationItem.rightBarButtonItem = transferBarButton;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];

    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    [self reloadNewFolders];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needReloadFolders) name:kRefreshHome object:nil];
}
- (void)needReloadFolders {
    if (self.isVisible) {
        [self reloadNewFolders];
    }
    else {
      _needRefresh = YES;
    }
}
- (void)refreshPullUp:(UIRefreshControl *)control {
    [self reloadNewFolders];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}
- (void)reloadNewFolders {
    NSArray *fileArray = [kFileM contentsOfDirectoryAtPath:KDocumentP error:nil];
    if (fileArray.count == 0) {
        [XTOOLS showAlertTitle:@"没有文件" message:@"应用内还没有文件，你可以导入文件开始使用" buttonTitles:@[@"取消",@"导入方法"] completionHandler:^(NSInteger num) {
            if (num == 1) {
                GuideViewController *guide = [self.storyboard instantiateViewControllerWithIdentifier:@"GuideViewController"];
                guide.title = @"导入方法";
                [self.navigationController pushViewController:guide animated:YES];
            }
        }];
    }
     _recordArray = [NSMutableArray arrayWithArray:[[XManageCoreData manageCoreData]getAllRecord]];
    [_foldersArray removeAllObjects];
    BOOL isFolder = NO;
    for (NSString *folderPath in fileArray) {
        [kFileM fileExistsAtPath:[KDocumentP stringByAppendingPathComponent:folderPath] isDirectory:&isFolder];
       
        if (isFolder&&![folderPath hasPrefix:@"."]) {
            [_foldersArray addObject:folderPath];
            isFolder = NO;
        }
    }
    [_foldersArray sortUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
       return [obj1 compare:obj2 options:NSWidthInsensitiveSearch|NSNumericSearch];
    }];
    NSLog(@"record == %@",_recordArray);
    NSLog(@"===%@ ====%@",fileArray,_foldersArray);
    [self.tableView reloadData];
}
- (void)footButtonAddFileAction {
    [XTOOLS umengClick:@"createnew"];
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:@"请输入新建文件夹名称" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
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
        NSString *audioPath = [KDocumentP stringByAppendingPathComponent:textField.text];
//        [NSString stringWithFormat:@"%@/%@",KDocumentP,textField.text];
        if (![kFileM fileExistsAtPath:audioPath]) {
            if ( [kFileM createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                [XTOOLS showMessage:@"创建成功"];
                [self reloadNewFolders];
                [XTOOLS umengClick:@"createnews"];
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
    TransferIPViewController *transfer = [TransferIPViewController allocFromStoryBoard];
    transfer.filesTransferChangeBack = ^(int num){
        self->_needRefresh = YES;
    };
    [self.navigationController pushViewController:transfer animated:YES];
}
- (void)leftScanButtonAction:(UIBarButtonItem *)button {
    ScanViewController *scan = [ScanViewController allocFromStoryBoard];
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
       return _tableArray.count;
    }
    else
    if (section == 2) {
        return _foldersArray.count;
    }
    else
    {
        return MIN(_recordArray.count, 5);
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_recordArray.count == 0) {
        return 0.0;;
    }
    if (section<2) {
        return 30;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_recordArray.count == 0) {
        return nil;
    }
    if (section<2) {
        UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"mainheaderview"];
        if (!headerView) {
            headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"mainheaderview"];
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 30)];
            nameLabel.textColor = [UIColor darkGrayColor];
            nameLabel.tag = 501;
            [headerView addSubview:nameLabel];
        }
        UILabel *label1 = [headerView viewWithTag:501];
        if (section == 0) {
          label1.text = NSLocalizedString(@"Recent Play", nil);
        }
        else {
           label1.text = NSLocalizedString(@"My Files", nil);
        }
        return headerView;
    }
    else
    {
        return nil;
    }
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordlistCell" forIndexPath:indexPath];
        Record *rec = _recordArray[indexPath.row];
        switch ([XTOOLS fileFormatWithPath:rec.path]) {
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
                [cell.imageView setImage:[UIImage imageNamed:@"file_unknow"]];
                break;
        }
        
        
        cell.textLabel.text = rec.name;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  已播：%@",[XTOOLS timeStrFromDate:rec.modifyDate],[XTOOLS timeSecToStrWithSec:rec.progress.floatValue]];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesCell" forIndexPath:indexPath];
        if (indexPath.section == 1) {
            cell.textLabel.text = _tableArray[indexPath.row][@"title"];
            [cell.imageView setImage:[UIImage imageNamed:_tableArray[indexPath.row][@"image"]]];
        }
        else
            if (indexPath.section == 2) {
                cell.textLabel.text = _foldersArray[indexPath.row];
                [cell.imageView setImage:[UIImage imageNamed:@"path_folder"]];
            }
        
        return cell;
    }
        
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        Record *rec = _recordArray[indexPath.row];
        BOOL isPlay = [XTOOLS playFileWithPath:rec.path OrigionalWiewController:self];
        if (!isPlay) {
            [XTOOLS showMessage:@"格式不支持"];
        }
    }
    else
        if (indexPath.section == 1) {
             NSDictionary *dict = _tableArray[indexPath.row];
            if ([dict[@"type"] integerValue] == 3) {
                XimageViewController *ximage = [XimageViewController allocFromStoryBoard];
                ximage.moveArray = _foldersArray;
                ximage.title = dict[@"title"];
                ximage.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ximage animated:YES];
                
            }
            else if ([dict[@"type"] integerValue] == 1){
                VideoListController *videoList = [VideoListController allocFromStoryBoard];
                videoList.moveArray = _foldersArray;
                videoList.title =dict[@"title"];
                videoList.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:videoList animated:YES];
            }
            else
            {
                FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
                
                filesList.fileType = [dict[@"type"]integerValue];
                filesList.moveArray = _foldersArray;
                filesList.title = dict[@"title"];
                filesList.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:filesList animated:YES];
            }
        
    }
    else
        if (indexPath.section == 2) {
            NSMutableArray *array =[NSMutableArray arrayWithArray: _foldersArray];
            [array removeObjectAtIndex:indexPath.row];
            [array addObject:@""];
            FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
            filesList.fileType = 0;
            filesList.title = _foldersArray[indexPath.row];
            filesList.moveArray = array;
            filesList.filePath = [KDocumentP stringByAppendingPathComponent:_foldersArray[indexPath.row]];
//            [NSString stringWithFormat:@"%@/%@",KDocumentP,_foldersArray[indexPath.row]];
            filesList.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:filesList animated:YES];
        }
    
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1) {

        
        UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
            if (indexPath.section == 2) {
                NSString *path = [KDocumentP stringByAppendingPathComponent:self->_foldersArray[indexPath.row]];
//                [NSString stringWithFormat:@"%@/%@",KDocumentP,_foldersArray[indexPath.row]];
                NSError *error ;
                [kFileM removeItemAtPath:path error:&error];
                if (error) {
                    NSLog(@"==%@",error);
                }
                NSLog(@"点击删除");
                [self->_foldersArray removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            }
            else
                if (indexPath.section == 0) {
                    Record *r = self->_recordArray[indexPath.row];
                    if ([[XManageCoreData manageCoreData]deleteRecord:r]) {
                        [self->_recordArray removeObject:r];
                    }
                    else
                    {
                        [XTOOLS showMessage:@"删除失败"];
                    }
                    [self.tableView reloadData];
                }
           
        }];
        if (indexPath.section == 0) {
            return @[deleteRoWAction];
        }
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"Rename", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            NSString *path = [KDocumentP stringByAppendingPathComponent:self->_foldersArray[indexPath.row]];
            UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"重新命名" message:@"请输入新的文件名称" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                
            }];
            UITextField *textField = aler.textFields.firstObject;
            textField.placeholder = @"文件名称";
            textField.text = path.lastPathComponent;
            UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (textField.text.length<=0) {
                    [XTOOLS showMessage:@"名称不能为空"];
                    return ;
                    
                }
                if ([textField.text isEqualToString:path.lastPathComponent]) {
                    return;
                }
                NSLog(@"==%@",textField.text);
                
                if ([kFileM fileExistsAtPath:path]) {
                    
                    NSMutableString *newPath = [NSMutableString stringWithString:path];
                    NSString *oldName = [path lastPathComponent];
                    NSString *formatStr = [path pathExtension];
                    NSString *newName;
                    
                    if (![textField.text hasSuffix:formatStr]&&formatStr.length > 0) {
                        newName = [NSString stringWithFormat:@"%@.%@",textField.text,formatStr];
                    }
                    else
                    {
                        newName = textField.text;
                    }
                    
                    
                    
                    NSRange oldrange = [newPath rangeOfString:oldName];
                    [newPath replaceCharactersInRange:oldrange withString:newName];
                    NSError *error = nil;
                    [kFileM moveItemAtPath:path toPath:newPath error:&error];
                    if (error) {
                        [XTOOLS showMessage:@"修改失败"];
                    }
                    else
                    {
                        [XTOOLS showMessage:@"修改成功"];
                        [self reloadNewFolders];
                    }
                }
                else
                {
                    [XTOOLS showMessage:@"文件不存在"];
                }
                
                
            }];
            [aler addAction:cancleAction];
            [aler addAction:addAction];
            [self presentViewController:aler animated:YES completion:nil];
        }];
        editAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
        return @[deleteRoWAction,editAction];//最后返回这俩个RowAction 的数组
  
    }
    return nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
}

@end
