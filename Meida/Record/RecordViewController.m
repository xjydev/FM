//
//  RecordViewController.m
//  FileManager
//
//  Created by xiaodev on Oct/14/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "RecordViewController.h"
#import "XManageCoreData.h"
#import "UIView+xiao.h"
#import "XTools.h"

@interface RecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_recordArray;
    __weak IBOutlet UITableView *_mainTableView;
}
@end

@implementation RecordViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    RecordViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"RecordViewController"];
    return VC;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"播放记录";
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    _mainTableView.tableFooterView = [[UIView alloc]init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Clear", nil) style:UIBarButtonItemStyleDone target:self action:@selector(deleteAllRecords)];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [_mainTableView addSubview:refresh];
    @weakify(self);
    [XTOOLS checkNetworkTitle:@"打开网络，才可以同步获取播放记录" State:^(BOOL is) {
        if (is) {
            @strongify(self);
            [self reloadAllRecords];
        }
    }];
}
- (void)refreshPullUp:(UIRefreshControl *)control {
    [self reloadAllRecords];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}
- (void)reloadAllRecords {
     _recordArray = [NSMutableArray arrayWithArray:[[XManageCoreData manageCoreData]getAllRecord]];
    if (_recordArray.count == 0) {
        [_mainTableView xNoDataThisViewTitle:@"没有历史记录" centerY:198];
    }
    else {
        [_mainTableView xRemoveNoData];
    }
    [_mainTableView reloadData];
}
- (void)deleteAllRecords {
    @weakify(self);
    [XTOOLS showAlertTitle:@"确定清空" message:@"确定清空所有播放记录？" buttonTitles:@[NSLocalizedString(@"Cancel", nil),NSLocalizedString(@"Confirm", nil)] completionHandler:^(NSInteger num) {
        @strongify(self);
        if (num == 1) {
            BOOL is = [[XManageCoreData manageCoreData]clearAllRecord];
            if (is) {
                [self->_recordArray removeAllObjects];
                [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshHome object:nil];
            }
            else
            {
                [XTOOLS showMessage:@"清空失败"];
            }
            [self reloadAllRecords];
        }
    }];
   
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recordArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recodelistcell" forIndexPath:indexPath];
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
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  已播：%@",[XTOOLS timeStrFromDate:rec.modifyDate],[XTOOLS timeSecToStrWithSec:rec.progress.floatValue ]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Record *rec = _recordArray[indexPath.row];
    BOOL isPlay = [XTOOLS playFileWithPath:rec.path OrigionalWiewController:self];
    if (!isPlay) {
        [XTOOLS showMessage:@"格式不支持"];
    }
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        Record *r = self->_recordArray[indexPath.row];
        if ([[XManageCoreData manageCoreData]deleteRecord:r]) {
            [self->_recordArray removeObject:r];
        }
        else
        {
            [XTOOLS showMessage:@"删除失败"];
        }
        [tableView reloadData];
    }];
    
    return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

 In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     Get the new view controller using [segue destinationViewController].
     Pass the selected object to the new view controller.
}
*/

@end
