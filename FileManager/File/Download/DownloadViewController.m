//
//  DownloadViewController.m
//  FileManager
//
//  Created by xiaodev on Jan/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "DownloadViewController.h"
#import "VideoViewController.h"
#import "XQuickLookController.h"
#import <QuickLook/QuickLook.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "AudioViewController.h"
#import "ZipArchive.h"
#import "UIColor+Hex.h"

#import "FileDetailController.h"
#import "XTools.h"
#import "DownLoadCenter.h"
#import "DownloadCenterCell.h"
#import "XManageCoreData.h"

@interface DownloadViewController ()<ZipArchiveDelegate,MWPhotoBrowserDelegate,UITableViewDelegate,UITableViewDataSource,DownloadCenterDelegate>
{
    NSMutableArray   *_downloadedArray;
    NSMutableArray   *_downloadingArray;
    UIBarButtonItem  *_rightBarButton;
    BOOL              _isEditing;
    BOOL              _isCompress;
    DownloadCenterCell *_downloadingCell;
    __weak IBOutlet UIButton *_allSelectButton;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, strong)NSMutableArray   *zipArray;

@property (nonatomic, copy)NSString *filePath;
@property (nonatomic, strong)NSArray  *moveArray;
@property (nonatomic, strong)ZipArchive  *zipArchive;
@end

@implementation DownloadViewController

- (NSMutableArray *)zipArray {
    if (!_zipArray) {
        _zipArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _zipArray;
}
- (ZipArchive *)zipArchive {
    if (!_zipArchive) {
        _zipArchive = [[ZipArchive alloc]initWithFileManager:kFileM];
        _zipArchive.delegate = self;
    }
    return _zipArchive;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"goBack"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    if (!self.filePath) {
        self.filePath = KDocumentP;
    }
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
//    for (UIButton *button in self.bottomView.subviews) {
//        if ([button isKindOfClass:[UIButton class]]) {
//            button.adjustsImageWhenHighlighted = NO;
//            button.enabled = NO;
//        }
//    }
//    self.bottomView.userInteractionEnabled = NO;
    _downloadedArray = [NSMutableArray arrayWithCapacity:0];
    _downloadingArray = [NSMutableArray arrayWithCapacity:0];
    self.mainTableView.rowHeight = 60;
    [self reloadFilesArray];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.mainTableView addSubview:refresh];
}
- (void)refreshPullUp:(UIRefreshControl *)control {
    [self reloadFilesArray];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}
- (void)reloadFilesArray {
    NSArray *array =[[XManageCoreData manageCoreData]allDownload];
    [_downloadingArray removeAllObjects];
    [_downloadedArray removeAllObjects];
    for (Download *model in array) {
        if (model.progress>=1.0) {
          [_downloadedArray addObject:[[DownloadCenterCellModel alloc]initWithDownloadModel:model]];
        }
        else
        {
            [_downloadingArray addObject:[[DownloadCenterCellModel alloc]initWithDownloadModel:model]];
        }
        
    }
    
    [self.mainTableView reloadData];
}
- (void)leftGoBackButtonAction:(UIBarButtonItem *)bar {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBarButtonAction:(UIBarButtonItem *)bar {
    if (_isEditing) {
        _isEditing = NO;
        self.bottomView.hidden = YES;
        
        self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_rightBarButton setTitle:@"选择"];
        [self.zipArray removeAllObjects];
        
    }
    else
    {
        _isEditing = YES;
        self.bottomView.hidden = NO;
        self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        [_rightBarButton setTitle:@"取消"];
//        for (UIButton *button in self.bottomView.subviews) {
//            if ([button isKindOfClass:[UIButton class]]) {
//                button.enabled = NO;
//            }
//        }
//        self.bottomView.userInteractionEnabled = NO;
    }
    [self.mainTableView setEditing:_isEditing animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView= [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"downloadHeader"];
    if (!headerView) {
        headerView= [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"downloadHeader"];
        headerView.frame = CGRectMake(0, 0, kScreen_Width, 30);
        headerView.backgroundColor= [UIColor ora_colorWithHex:0xf5f5f5];
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, 30)];
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.tag = 301;
        [headerView addSubview:headerLabel];
    }
    UILabel *label = [headerView viewWithTag:301];
    label.text = section == 1?@"已下载":@"下载中";
    return  headerView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return _downloadedArray.count;
    }
    return _downloadingArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadListCell" forIndexPath:indexPath];
    
    DownloadCenterCellModel *model;
    if (indexPath.section == 1) {
        model = _downloadedArray[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        model = _downloadingArray[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    
    if (indexPath.section == 1) {
        [cell setModel:model type:1];
        cell.downloadProgress.hidden = YES;
        cell.lookButton.hidden = YES;
        switch ([XTOOLS fileFormatWithPath:model.path]) {
            case FileTypeFolder:
                [cell setHeaderImage:[UIImage imageNamed:@"path_folder"]];
                break;
            case FileTypeAudio:
                [cell setHeaderImage:[UIImage imageNamed:@"header_audio"]];
                break;
            case FileTypeImage:
                [cell setHeaderImage:[UIImage imageNamed:@"header_image"]];
                break;
            case FileTypeVideo:
                [cell setHeaderImage:[UIImage imageNamed:@"header_video"]];
                break;
            case FileTypeCompress:
                [cell setHeaderImage:[UIImage imageNamed:@"header_zip"]];
                break;
            case FileTypeDocument:
                [cell setHeaderImage:[UIImage imageNamed:@"header_document"]];
                break;
            default:
                [cell setHeaderImage:[UIImage imageNamed:@"file_unknow"]];
                break;
        }
 
    }
    else
    {
        cell.downloadProgress.hidden = NO;
        cell.lookButton.hidden = NO;
        cell.downloadProgress.progress = model.model.progress;
        if ([model.model.url isEqualToString:[DownLoadCenter defaultDownLoad].downLoadUrlStr]) {
            model.isDownloading = YES;
            _downloadingCell = cell;
            [cell setHeaderImage:[UIImage imageNamed:@"downloading"]];
        }
        else
        {
            model.isDownloading = NO;
           [cell setHeaderImage:[UIImage imageNamed:@"stopDownload"]];
        }
    }
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        DownloadCenterCellModel *model = _downloadedArray[indexPath.row];
        
        FileDetailController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"FileDetailController"];
        detail.filePath = model.path;
        [self.navigationController pushViewController:detail animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_isEditing) {
        if (indexPath.section == 1) {
            DownloadCenterCellModel *model  = _downloadedArray[indexPath.row];
            [self tableViewSelectedDeSelectedModel:model selected:YES];
        }
        else
        {
            DownloadCenterCellModel *model  = _downloadingArray[indexPath.row];
            [self tableViewSelectedDeSelectedModel:model selected:YES];
        }
        
        
    }
    else
    {
        //先是分类列表的时候，是数组查看。如果是所有文档的时候就一个一个查看。
        if (indexPath.section == 1) {
            DownloadCenterCellModel *model  = _downloadedArray[indexPath.row];
            [self gotoDetailWithPath:model.path];
        }
        else
        {
            DownloadCenterCellModel *model  = _downloadingArray[indexPath.row];
            model.isDownloading = !model.isDownloading;
            [self.mainTableView reloadData];
        }
        
    }
    
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        DownloadCenterCellModel *model  = _downloadedArray[indexPath.row];
        [self tableViewSelectedDeSelectedModel:model selected:NO];
    }
    else
    {
        DownloadCenterCellModel *model  = _downloadingArray[indexPath.row];
        [self tableViewSelectedDeSelectedModel:model selected:NO];
    }
}
- (void)tableViewSelectedDeSelectedModel:(DownloadCenterCellModel *)model selected:(BOOL)isSelected {
    if (isSelected) {
        [self.zipArray addObject:model];
    }
    else {
        [self.zipArray removeObject:model];
    }
    if (self.zipArray.count ==_downloadingArray.count + _downloadedArray.count) {
        [_allSelectButton setTitle:@"全取消" forState:UIControlStateNormal];
    }
    else
    {
       [_allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
    }

}
#pragma mark -- tableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
    DownloadCenterCellModel *model;
    if (indexPath.section ==1) {
        model = _downloadedArray[indexPath.row];
    }
    else
    {
        model = _downloadingArray[indexPath.row];
    }
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        
        
        if ([[XManageCoreData manageCoreData]deleteDownLoadModel:model.model]) {
            NSLog(@"点击删除");
            if (indexPath.section ==1) {
            [_downloadedArray removeObjectAtIndex:indexPath.row];
            }else
            {
              [_downloadingArray removeObjectAtIndex:indexPath.row];
            }
            [self.mainTableView reloadData];
        }
        else
        {
            NSLog(@"点击删除失败");
        }
        
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
//    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转移" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        
//    }];
//    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEditing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
    
}

- (void)gotoDetailWithPath:(NSString *)path {
    if ([XTOOLS fileFormatWithPath:path] == FileTypeCompress) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解压" message:@"是否解压此文件" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"解压" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //解压文件
            [self deCompressWithPath:path];
            
        }];
        [alert addAction:cancleAction];
        [alert addAction:unzipAction];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    else
    {
        BOOL isPlay = [XTOOLS playFileWithPath:path OrigionalWiewController:self];
        if (!isPlay) {
            
        }
    }
}
#pragma  mark -- 压缩 解压

- (void)deCompressWithPath:(NSString *)path {
    BOOL success = NO;
    if ([self.zipArchive UnzipOpenFile:path] ) {
        if ([self.zipArchive UnzipFileTo:self.filePath overWrite:YES]) {
            if ( [self.zipArchive UnzipCloseFile]) {
                success = YES;
                
            }
        }
    }
    if (success) {
        [XTOOLS showMessage:@"解压成功"];
        [self reloadFilesArray];
    }
    else
    {
        [XTOOLS showMessage:@"解压失败"];
    }
    
}
- (void)showZipProgress {
    self.zipArchive.progressBlock = ^(int percentage, int filesProcessed, unsigned long numFiles){
        
    };
}
#pragma mark -- 解压代理成功失败
- (void)ErrorMessage:(NSString *)msg {
    if (_isCompress) {
        [XTOOLS showMessage:@"压缩失败！"];
    }
    else
    {
        [XTOOLS showMessage:@"解压失败！"];
    }
   
    
}
- (BOOL)OverWriteOperation:(NSString *)file {
    
    return NO;
}

#pragma mark --底部按钮

- (IBAction)deleteButtonAction:(id)sender {
    if (self.zipArray.count<=0) {
        [XTOOLS showMessage:@"请先选择"];
        return;
    }
    NSMutableString *mstr = [NSMutableString stringWithCapacity:0];
    for (DownloadCenterCellModel *model in self.zipArray) {
        [mstr appendString:model.name];
        [mstr appendString:@"\n"];
    }
    [mstr appendFormat:@"删除以上%d个文件",(int)self.zipArray.count];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除文件" message:mstr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (DownloadCenterCellModel *model in self.zipArray) {
            [[XManageCoreData manageCoreData]deleteDownLoadModel:model.model];
            
        }
        [self reloadFilesArray];
        
    }];
    [alert addAction:cancleAction];
    [alert addAction:unzipAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
- (IBAction)selectedAllButtonAction:(id)sender {
    
    if (self.zipArray.count ==_downloadingArray.count + _downloadedArray.count) {
        for (DownloadCenterCellModel *model in self.zipArray) {
            if ([_downloadedArray containsObject:model]) {
                NSInteger index =[_downloadedArray indexOfObject:model];
                [self.mainTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:YES];
            }
            else
                if ([_downloadingArray containsObject:model]) {
                    NSInteger index =[_downloadingArray indexOfObject:model];
                    [self.mainTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
                }
            
        }
        [self.zipArray removeAllObjects];
    }
    else
    {
        for (int i = 0; i<_downloadingArray.count; i++) {
            DownloadCenterCellModel *model = _downloadingArray[i];
            if (![self.zipArray containsObject:model]) {
                [self.zipArray addObject:model];
                [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
            
            
        }
        for (int i = 0; i<_downloadedArray.count; i++) {
            
            DownloadCenterCellModel *model = _downloadedArray[i];
            if (![self.zipArray containsObject:model]) {
                [self.zipArray addObject:model];
                [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
 
    }
    
    if (self.zipArray.count ==_downloadingArray.count + _downloadedArray.count) {
        [_allSelectButton setTitle:@"全取消" forState:UIControlStateNormal];
    }
    else
    {
        [_allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
    }

}
- (IBAction)selectedStopButtonAction:(id)sender {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark -- MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _downloadedArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _downloadedArray.count) {
        DownloadCenterCellModel *model =_downloadedArray[index];
        
        return [MWPhoto photoWithURL:[NSURL fileURLWithPath:model.path]];
    }
    return nil;
}
#pragma mark -- downloadDelegate

- (void)progress:(double)values {
    NSLog(@"p == %f",values);
    _downloadingCell.downloadProgress.progress = values;
}
- (void)finishDown:(BOOL)isfinish filePath:(NSString *)path {
    NSLog(@"finish == %@",path);
    [self reloadFilesArray];
}
@end
