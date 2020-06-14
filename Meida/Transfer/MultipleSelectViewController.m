//
//  MultipleSelectViewController.m
//  player
//
//  Created by XiaoDev on 2019/11/16.
//  Copyright © 2019 Xiaodev. All rights reserved.
//

#import "MultipleSelectViewController.h"
#import "UIView+xiao.h"
#import "FileDetailController.h"

@interface MultipleSelectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy)MultipleSelectComplete selectComplete;

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *selectMArray;
@property (nonatomic, strong)NSMutableArray *filesArray;
@end

@implementation MultipleSelectViewController
+ (instancetype)allocFromInit {
    MultipleSelectViewController *vc = [[MultipleSelectViewController alloc]init];
    return vc;
}
- (void)selectFileComplete:(MultipleSelectComplete)complete {
    self.selectComplete = complete;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.folderPath.length == 0) {
        self.folderPath = KDocumentP;
    }
    self.filesArray = [NSMutableArray arrayWithCapacity:0];
    self.selectMArray = [NSMutableArray arrayWithCapacity:0];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.editing = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemAction)];
    [self reloadFilesArray];
}
- (void)leftBarButtonItemAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)rightBarButtonItemAction {
    if (self.selectMArray.count > 0) {
        if (self.selectComplete) {
            self.selectComplete(self.selectMArray);
        }
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mselecCellId"];
    }
    return _mainTableView;
}
- (void)reloadFilesArray {
    NSError *error;
    [self.filesArray removeAllObjects];
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.folderPath error:&error];
    
    for (NSString *name in array) {
        if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
            if ([XTOOLS fileFormatWithPath:name]!=FileTypeFolder) {
                [_filesArray addObject:name];
            }
        }
    }
    if (self.filesArray.count!=0) {
        [self.mainTableView xRemoveNoData];
    }
    else {
        [self.mainTableView xNoDataThisViewTitle:@"无文件" centerY:198];
    }
    [self.mainTableView reloadData];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mselecCellId" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    UIButton *accessoryButton =(UIButton *)cell.accessoryView;
    [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
   
    NSString *pathName = self.filesArray[indexPath.row];
    cell.textLabel.text = pathName;
    float store = [XTOOLS fileSizeAtPath:[self.folderPath stringByAppendingPathComponent:pathName]];
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
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pathName = self.filesArray[indexPath.row];
    if ([self.selectMArray containsObject:pathName]) {
        [self.selectMArray removeObject:pathName];
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pathName = self.filesArray[indexPath.row];
    if (![self.selectMArray containsObject:pathName]) {
        [self.selectMArray addObject:pathName];
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [self.folderPath stringByAppendingPathComponent:_filesArray[indexPath.row]];
//    [NSString stringWithFormat:@"%@/%@",KDocumentP,_filesArray[indexPath.row]];
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
