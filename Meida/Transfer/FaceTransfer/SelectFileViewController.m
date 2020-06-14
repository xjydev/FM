//
//  FaceTransferViewController.m
//  FileManager
//
//  Created by xiaodev on Feb/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "SelectFileViewController.h"
#import "FileDetailController.h"
#import "FaceTransferView.h"
#import "XTools.h"
#import "UIView+xiao.h"
@interface SelectFileViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *_mainTableView;
    NSMutableArray  *_filesArray;
}
@end

@implementation SelectFileViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard * mainStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    SelectFileViewController *VC = [mainStory instantiateViewControllerWithIdentifier:@"SelectFileViewController"];
    return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
//    self.title = @"选择传输文件";
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
//   [self setAutomaticallyAdjustsScrollViewInsets:NO];
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    [self reloadFilesArray];
}

- (void)reloadFilesArray {
    NSError *error;
    
    [_filesArray removeAllObjects];
    if (self.showHiddenFiles) {
        NSArray *array = [kFileM contentsOfDirectoryAtPath:KDocumentP error:&error];
        for (NSString *name in array) {
            if ([name hasPrefix:@"."] || [name containsString:@"/."]) {
                [_filesArray addObject:name];
            }
            
        }
    }
    else
    {
        NSArray *array = [kFileM subpathsOfDirectoryAtPath:KDocumentP error:&error];
        if (self.fileType == FileTypemedia) {
            for (NSString *name in array) {
                if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
                    if ([XTOOLS fileFormatWithPath:name] == FileTypeAudio || [XTOOLS fileFormatWithPath:name] == FileTypeVideo) {
                        [_filesArray addObject:name];
                    }
                    
                }
                
            }
        }
        else
        {
            for (NSString *name in array) {
                if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
                    [_filesArray addObject:name];
                }
                
            }
        }
    }
   
    if (_filesArray.count!=0) {
        [_mainTableView xRemoveNoData];
    }
    else
    {
        [_mainTableView xNoDataThisViewTitle:@"无文件" centerY:198];
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
    float store = [XTOOLS fileSizeAtPath:[KDocumentP stringByAppendingPathComponent:pathName]];
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
            [cell.imageView setImage:[UIImage imageNamed:@"file_unknow"]];
            break;
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [KDocumentP stringByAppendingPathComponent:_filesArray[indexPath.row]];
//    [NSString stringWithFormat:@"%@/%@",KDocumentP,_filesArray[indexPath.row]];
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = _filesArray[indexPath.row];
    if (![path hasPrefix:KDocumentP]) {
        path = [KDocumentP stringByAppendingPathComponent:path];
//        [NSString stringWithFormat:@"%@/%@",KDocumentP,path];
    }
    if (self.showHiddenFiles) {
        BOOL isPlay = [XTOOLS playFileWithPath:path OrigionalWiewController:self];
        if (!isPlay) {
            [XTOOLS showMessage:@"格式不支持"];
        }
    }
    else
    {
        
        if (self.selectedPath) {
            self.selectedPath(path);
        }
       
        [self.navigationController popViewControllerAnimated:YES];
    }
   
}

-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *blueRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSError *error ;
        NSString *path = [KDocumentP stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
//        [NSString stringWithFormat:@"%@/%@",KDocumentP,_filesArray[indexPath.row]];
        
        [kFileM removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [self->_filesArray removeObjectAtIndex:indexPath.row];
        [self->_mainTableView reloadData];

        }];
   
    
    return @[blueRoWAction];//最后返回这俩个RowAction 的数组
    
}
- (void)dealloc {
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
