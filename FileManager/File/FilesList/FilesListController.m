//
//  FilesListTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "FilesListController.h"
#import "VideoViewController.h"
#import "ZipArchive.h"
#import "XQuickLookController.h"
#import <QuickLook/QuickLook.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "AudioViewController.h"
#import "XProgressView.h"
#import "MoveFilesView.h"
#import "FileDetailController.h"
@interface FilesListController ()<ZipArchiveDelegate,MWPhotoBrowserDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray   *_filesArray;
    UIBarButtonItem  *_rightBarButton;
    BOOL              _isEditing;
    BOOL              _isCompress;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray   *zipArray;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong)ZipArchive  *zipArchive;
//@property (nonatomic, strong)UIView     *bottomView;
@end

@implementation FilesListController
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
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    if (!self.filePath) {
        self.filePath = KDocumentP;
    }
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    
    if (!self.isSelected) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
        self.navigationItem.rightBarButtonItem = _rightBarButton;
        for (UIButton *button in self.bottomView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.adjustsImageWhenHighlighted = NO;
                button.enabled = NO;
            }
        }
        self.bottomView.userInteractionEnabled = NO;
        [self reloadFilesArray];
    }
    else
    {
        self.bottomView.hidden = YES;
        [self reloadVideoAudioArray];
    }
    
    
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.mainTableView addSubview:refresh];
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    return YES;
}
- (void)refreshPullUp:(UIRefreshControl *)control {
    [self reloadFilesArray];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}
- (void)reloadVideoAudioArray {
    NSError *error;
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.filePath error:&error];
    [_filesArray removeAllObjects];
    for (NSString *name in array) {
        if ([XTOOLS fileFormatWithPath:name] == FileTypeAudio || [XTOOLS fileFormatWithPath:name] == FileTypeVideo) {
            [_filesArray addObject:name];
        }
    }
    [self.mainTableView reloadData];
}
- (void)reloadFilesArray {
    NSError *error;
    
    if (self.fileType != FileTypeDefault) {
        NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.filePath error:&error];
        [_filesArray removeAllObjects];
        for (NSString *name in array) {
            if ([XTOOLS fileFormatWithPath:name] == self.fileType  ) {
                [_filesArray addObject:name];
            }
        }
    }
    else
    {
        NSArray *array = [kFileM contentsOfDirectoryAtPath:self.filePath error:&error];
        [_filesArray removeAllObjects];
        for (NSString *name in array) {
            if (![name hasPrefix:@"."]) {
                [_filesArray addObject:name];
            }
            
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
        for (UIButton *button in self.bottomView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.enabled = NO;
            }
        }
        self.bottomView.userInteractionEnabled = NO;
    }
    [self.mainTableView setEditing:_isEditing animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _filesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesListCell" forIndexPath:indexPath];
    if (self.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        UIButton *accessoryButton =(UIButton *)cell.accessoryView;
        [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
 
    }
        NSString *pathName = _filesArray[indexPath.row];
    cell.textLabel.text = pathName;
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
     NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
    FileDetailController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"FileDetailController"];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEditing) {
       NSString *file  = _filesArray[indexPath.row];
        [self tableViewSelectedDeSelectedPath:file selected:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelected) {
        if (self.selectedPath) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
            self.selectedPath(path);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
    if (_isEditing) {
        NSString *file  = _filesArray[indexPath.row];
        [self tableViewSelectedDeSelectedPath:file selected:YES];
        
    }
    else
    {
         NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
        //先是分类列表的时候，是数组查看。如果是所有文档的时候就一个一个查看。
        switch (self.fileType) {
            case FileTypeVideo:
            {
                VideoViewController *video = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
                [video setVideoArray:_filesArray WithIndex:indexPath.row];
                [self presentViewController:video animated:YES completion:^{
                    
                }];
            }
                break;
            case FileTypeAudio:
            {
                AudioViewController *audio = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
                [audio setAudioArray:_filesArray index:indexPath.row];
                [self presentViewController:audio animated:YES completion:^{
                    
                }];
            }
                break;
            case FileTypeImage:
            {
                MWPhotoBrowser *browser = [[MWPhotoBrowser alloc]initWithDelegate:self];
                [browser setCurrentPhotoIndex:indexPath.row ];
                [self.navigationController pushViewController:browser animated:YES];
            }
                break;
            case FileTypeDocument:
            {
                XQuickLookController *xql = [[XQuickLookController alloc]init];
                xql.itemArray = _filesArray;
                xql.currentIndex = indexPath.row;
                [self.navigationController pushViewController:xql animated:YES];
            }
                break;
            
            default:
            {
                
                if ([XTOOLS fileFormatWithPath:path] == FileTypeFolder ) {
                    
                    NSMutableArray *array =[NSMutableArray arrayWithArray: self.moveArray];
                    [array removeObject:_filesArray[indexPath.row]];
                    [array addObject:@""];
                    FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
                    filesList.fileType = 0;
                    filesList.title = _filesArray[indexPath.row];
                    filesList.moveArray = array;
                    filesList.filePath = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
                    filesList.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:filesList animated:YES];
                    
                }
                else {
                    [self gotoDetailWithPath:path];
                }
            }
                break;
        }
  
    }
    }
    
}
- (void)tableViewSelectedDeSelectedPath:(NSString *)path selected:(BOOL)isSelected {
    if (isSelected) {
       [self.zipArray addObject:path];
    }
    else {
        [self.zipArray removeObject:path];
    }
    if (self.zipArray.count>=1&&self.bottomView.userInteractionEnabled == NO) {
        self.bottomView.userInteractionEnabled = YES;
        for (UIButton *button in self.bottomView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.enabled = YES;
            }
        }
    }
    else
        if(self.bottomView.userInteractionEnabled == YES&&self.zipArray.count==0)
        {
            self.bottomView.userInteractionEnabled = NO;
            for (UIButton *button in self.bottomView.subviews) {
                if ([button isKindOfClass:[UIButton class]]) {
                    button.enabled = NO;
                }
            }
            
        }
}
#pragma mark -- tableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelected) {
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSError *error ;
        [kFileM removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [_filesArray removeObjectAtIndex:indexPath.row];
        [self.mainTableView reloadData];
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转移" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
        
        [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
            NSError *error = nil;
            NSString *toPath = [NSString stringWithFormat:@"%@/%@",movePath,path.lastPathComponent];
            if ([kFileM moveItemAtPath:path toPath:toPath error:&error]) {
                [XTOOLS showMessage:@"转移成功"];
                [self.mainTableView reloadData];
            }
            else{
                [XTOOLS showMessage:@"转移失败"];
                NSLog(@"error == %@",error);
            }
        }];
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction,editRowAction];//最后返回这俩个RowAction 的数组
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
- (void)compressToZip {
    NSMutableString *mstr = [NSMutableString stringWithCapacity:0];
    for (NSString *name in self.zipArray) {
        [mstr appendString:name];
        [mstr appendString:@"\n"];
    }
    [mstr appendFormat:@"请输入压缩包名称"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"压缩以下文件" message:mstr preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    UITextField *textField = alert.textFields.firstObject;
    textField.placeholder = @"压缩包名称";
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"压缩" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //压缩文件
        NSString *zipName = textField.text;
        if (zipName.length<=0) {
            zipName = @"压缩";
        }
        NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip",self.filePath,zipName];
        [self.zipArchive CreateZipFile2:zipPath];
        for (NSString *name in self.zipArray) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,name];
            [self.zipArchive addFileToZip:path newname:path.lastPathComponent];
        }
        if ([self.zipArchive CloseZipFile2]) {
            [XTOOLS showMessage:@"压缩成功"];
            [self reloadFilesArray];
            
        }else
        {
            [XTOOLS showMessage:@"压缩失败"];
        }

        
    }];
    [alert addAction:cancleAction];
    [alert addAction:unzipAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
   //    [self showZipProgress];
    
}
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
        [XProgressView defaultProgress].percentage = percentage;
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
    [[XProgressView defaultProgress]removeRelease];
    
}
- (BOOL)OverWriteOperation:(NSString *)file {
    
    return NO;
}

#pragma mark --底部按钮
- (IBAction)compressButtonAction:(id)sender {
    [self compressToZip];
}
//转移按钮
- (IBAction)moveButtonAction:(id)sender {
    MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
                               
    [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
        for (NSString *name in _zipArray) {
            NSString * path = [NSString stringWithFormat:@"%@/%@",self.filePath,name];
            NSString *toPath = [NSString stringWithFormat:@"%@/%@",movePath,name];
            if (![kFileM moveItemAtPath:path toPath:toPath error:nil]) {
                [XTOOLS showMessage:@"转移失败"];
                return ;
            }
        }
        [XTOOLS showMessage:@"转移成功"];
        [self reloadFilesArray];
 }];
}
- (IBAction)deleteButtonAction:(id)sender {
    NSMutableString *mstr = [NSMutableString stringWithCapacity:0];
    for (NSString *name in self.zipArray) {
        [mstr appendString:name];
        [mstr appendString:@"\n"];
    }
    [mstr appendFormat:@"删除以上%ld个文件",self.zipArray.count];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除文件" message:mstr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (NSString *s in self.zipArray) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,s];
            [kFileM removeItemAtPath:path error:nil];
            [_filesArray removeObject:s];
            
        }
        [self.mainTableView reloadData];
        
    }];
    [alert addAction:cancleAction];
    [alert addAction:unzipAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark -- MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _filesArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _filesArray.count) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[index]];
        return [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
    }
    return nil;
}

@end
