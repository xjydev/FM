//
//  FilesListTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "FilesListController.h"
#import "NewVideoViewController.h"
#import "ZipArchive.h"
#import "XQuickLookController.h"
#import <QuickLook/QuickLook.h>
#import "XDPhotoBrowerViewController.h"
#import "AudioViewController.h"
#import "MoveFilesView.h"
#import "FileDetailController.h"
#import "UIView+xiao.h"
#import "FilesTableCell.h"
#import "XManageCoreData.h"
#import "UIColor+Hex.h"
#import "MakeTagViewController.h"

@interface FilesListController ()<ZipArchiveDelegate,XDPhotoBrowerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIPopoverPresentationControllerDelegate>
{
    UIBarButtonItem  *_rightBarButton;
    BOOL              _isEditing;
    BOOL              _isCompress;
    
    NSArray          *_imageArray;
}
@property (nonatomic, strong)NSMutableArray *allFilesArray;//本地种类的数据。
@property (nonatomic, strong)NSMutableArray *filesArray;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray   *zipArray;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UISearchBar *headerSearchBar;
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
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    _mainTableView.tableFooterView = [[UIView alloc]init];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    if (!self.filePath) {
        if (self.fileType == FileTypeFolder) {
            self.filePath = [KDocumentP stringByAppendingPathComponent:self.title];
        }
        else
        {
            self.filePath = KDocumentP;
        }
    }
    else {
        if (![self.filePath hasPrefix:KDocumentP]) {
            self.filePath = [KDocumentP stringByAppendingPathComponent:self.filePath];
        }
    }
    self.allFilesArray = [NSMutableArray arrayWithCapacity:0];
    self.filesArray = [NSMutableArray arrayWithCapacity:0];
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
    
    self.headerSearchBar.delegate = self;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerSearchBar.frame)-0.5, kScreen_Width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.headerSearchBar addSubview:lineView];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.mainTableView addSubview:refresh];
    [kNOtificationC addObserver:self selector:@selector(reloadFilesArray) name:kRefreshList object:nil];
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
- (void)reloadFilesArray {
    [self.zipArray removeAllObjects];
    NSError *error;
    if (self.fileType != FileTypeDefault&&self.fileType!=FileTypeFolder) {
        NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.filePath error:&error];
        [self.allFilesArray removeAllObjects];
        for (NSString *name in array) {
            if ([XTOOLS fileFormatWithPath:name] == self.fileType ) {
                if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
                    Record *model = [[XManageCoreData manageCoreData]createRecordWithPath:name];
                    [self.allFilesArray addObject:model];
                }
            }
        }
    }
    else
    {
        NSArray *array = [kFileM contentsOfDirectoryAtPath:self.filePath error:&error];
        [self.allFilesArray removeAllObjects];
        for (NSString *name in array) {
            if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {//去除隐藏文件
                 Record *model = [[XManageCoreData manageCoreData]createRecordWithPath:name];
                [self.allFilesArray addObject:model];
            }
            
        }
       
    }
    NSArray *sortArray =[kUSerD arrayForKey:kSort];
    
    if (sortArray.count>0) {
        NSMutableArray *descrArr = [NSMutableArray arrayWithCapacity:sortArray.count];
        for (NSArray *a in sortArray) {
            if ([a.firstObject isEqualToString:@"name"]) {
                NSSortDescriptor* descriptor = [[NSSortDescriptor alloc]initWithKey:a.firstObject ascending:[a.lastObject integerValue]==1 comparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
                    return [obj1 compare:obj2 options:NSWidthInsensitiveSearch|NSNumericSearch];
                }];
                [descrArr addObject:descriptor];
            }
            else {
                NSSortDescriptor *des = [NSSortDescriptor sortDescriptorWithKey:a[1] ascending:[a.lastObject integerValue]==1 ];
                [descrArr addObject:des];
            }
        }
         [self.allFilesArray sortUsingDescriptors:descrArr];
    }
    else {
       NSSortDescriptor* descriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES comparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
            return [obj1 compare:obj2 options:NSWidthInsensitiveSearch|NSNumericSearch];
        }];
        [self.allFilesArray sortUsingDescriptors:@[descriptor]];
    }
   
     self.filesArray = [NSMutableArray arrayWithArray:self.allFilesArray];
    [self reloadNoDataView];
    [self.mainTableView reloadData];
}
- (void)reloadNoDataView {
    if (self.filesArray.count !=0) {
        [self.mainTableView xRemoveNoData];
    }
    else
    {
        NSString *noFileStr = @"还没有文件";
        switch (self.fileType) {
            case FileTypeAudio:
                noFileStr = @"还没有音频";
                break;
            case FileTypeVideo:
                noFileStr = @"还没有视频";
                break;
            case FileTypeImage:
                noFileStr = @"还没有图片";
                break;
            case FileTypeDocument:
                noFileStr = @"还没有文档";
                break;
                
            default:
                break;
        }
        [self.mainTableView xNoDataThisViewTitle:noFileStr centerY:198];
    }
 
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
    return self.filesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilesTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesTableCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        UIButton *accessoryButton =(UIButton *)cell.accessoryView;
        [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
 
    Record *model = self.filesArray[indexPath.row];
    cell.fileModel = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Record *model = self.filesArray[indexPath.row];
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    NSString *path = model.path;
    if (![path hasPrefix:self.filePath]) {
        path = [self.filePath stringByAppendingPathComponent:path];
    }
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEditing) {
        Record *model = self.filesArray[indexPath.row];
        [self tableViewSelectedDeSelectedPath:model selected:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Record *model  = self.filesArray[indexPath.row];
    if (_isEditing) {
        [self tableViewSelectedDeSelectedPath:model selected:YES];
    }
    else
    {
//先是分类列表的时候，是数组查看。如果是所有文档的时候就一个一个查看。
        
         NSString *path = model.path;
        if (![path hasPrefix:self.filePath]) {
            path = [self.filePath stringByAppendingPathComponent:path];
        }
        switch (self.fileType) {
            case FileTypeVideo:
            {
                NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
                [video setVideoArray:self.filesArray WithIndex:indexPath.row];
                [self presentViewController:video animated:YES completion:^{
                    
                }];
            }
                break;
            case FileTypeAudio:
            {
                AudioViewController *audio = [AudioViewController allocFromStoryBoard];
                audio.modalPresentationStyle = UIModalPresentationFullScreen;
                [audio setAudioArray:self.filesArray index:indexPath.row];
                [self presentViewController:audio animated:YES completion:^{
                    
                }];
            }
                break;
            case FileTypeImage:
            {
                _imageArray = self.filesArray;
                XDPhotoBrowerViewController *brower = [[XDPhotoBrowerViewController alloc]init];
                brower.delegate = self;
                [brower setCurrentIndex:indexPath.row ];
                [self.navigationController pushViewController:brower animated:YES];
            }
                break;
            case FileTypeDocument:
            {
                XQuickLookController *xql = [[XQuickLookController alloc]init];
                xql.itemArray = self.filesArray;
                xql.currentIndex = indexPath.row;
                [self.navigationController pushViewController:xql animated:YES];
            }
                break;
            
            default:
            {
                
                if ([XTOOLS fileFormatWithPath:path] == FileTypeFolder ) {
                    
                    NSMutableArray *array =[NSMutableArray arrayWithArray: self.moveArray];
                    [array removeObject:self.filesArray[indexPath.row]];
                    [array addObject:@""];
                    FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
                    filesList.fileType = 0;
//                    FileModel *model =_filesArray[indexPath.row];
                    filesList.title =model.name;
                    filesList.moveArray = array;
                    filesList.filePath = [self.filePath stringByAppendingPathComponent:model.path];
                    filesList.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:filesList animated:YES];
                    
                }
                else {
                    if ([XTOOLS fileFormatWithPath:path] == FileTypeImage) {//单个文件，如果是图片，就把所有图片找出来。
                        NSMutableArray *imArray = [NSMutableArray arrayWithCapacity:self.filesArray.count];
                        for (Record *immodel in self.filesArray) {
                            if ([XTOOLS fileFormatWithPath:immodel.path] == FileTypeImage) {
                                [imArray addObject:immodel];
                            }
                        }
                        Record *indexmodel = self.filesArray[indexPath.row];
                        _imageArray = imArray;
                        NSInteger index = [_imageArray indexOfObject:indexmodel];
                        XDPhotoBrowerViewController *browser = [[XDPhotoBrowerViewController alloc]init];
                        browser.delegate = self;
                        [browser setCurrentIndex:index];
                        [self.navigationController pushViewController:browser animated:YES];
                    }
                    else
                    {
                        [self gotoDetailWithPath:path];
                    }
                }
            }
                break;
        }
  
    }
//    }
    
}
- (void)tableViewSelectedDeSelectedPath:(Record *)model selected:(BOOL)isSelected {
   
    if (isSelected) {
       [self.zipArray addObject:model];
    }
    else {
        [self.zipArray removeObject:model];
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
    @weakify(self)
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        @strongify(self);
        NSError *error ;
        Record *model = self.filesArray[indexPath.row];
        
        NSString *path = model.path;
        if (![path hasPrefix:self.filePath]) {
            path = [self.filePath stringByAppendingPathComponent:path];
        }
        [kFileM removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [self.filesArray removeObjectAtIndex:indexPath.row];
        [[XManageCoreData manageCoreData]deleteRecord:model];
        [self reloadNoDataView];
        [self.mainTableView reloadData];
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转移" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        @strongify(self);
        MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
        
        [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
            NSError *error = nil;
            Record *model =self.filesArray[indexPath.row];
            NSString *path = model.path;
            if (![path hasPrefix:self.filePath]) {
                path = [self.filePath stringByAppendingPathComponent:path];
            }

            NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
            if (![toPath hasPrefix:KDocumentP]) {
                toPath = [KDocumentP stringByAppendingPathComponent:toPath];
            }
            if ([kFileM moveItemAtPath:path toPath:toPath error:&error]) {
                [XTOOLS showMessage:@"转移成功"];
                model.path = toPath;
                 [[XManageCoreData manageCoreData]saveRecord:model];
                if (self.fileType == FileTypeFolder) {
                    [self.filesArray removeObject:model];
                }
                [self.mainTableView reloadData];
            }
            else{
                [XTOOLS showMessage:@"转移失败"];
                NSLog(@"error == %@",error);
            }
            
        }];
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    UITableViewRowAction *signAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"标记" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        @strongify(self);
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        Record *model =self.filesArray[indexPath.row];
        MakeTagViewController *makeTag = [MakeTagViewController viewControllerFromStoryboard];
        makeTag.popoverPresentationController.sourceView =cell;
        makeTag.popoverPresentationController.sourceRect = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width/2, cell.bounds.size.height);
        makeTag.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
        [makeTag makeTagBackHandler:^(int tag) {
            model.markInt = @(tag);
             [[XManageCoreData manageCoreData]saveRecord:model];
            [kNOtificationC postNotificationName:kRefreshList object:nil];
        }];
        makeTag.popoverPresentationController.delegate = self;
        [self presentViewController:makeTag animated:YES completion:^{
            
        }];
    }];
    signAction.backgroundColor = [UIColor ora_colorWithHex:0xf98d12];
    return @[deleteRoWAction,signAction,editRowAction];//最后返回这俩个RowAction 的数组
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
    for (Record *model in self.zipArray) {
        if (model.name) {
            [mstr appendString:model.name];
            [mstr appendString:@"\n"];
        }
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
        for (Record *model in self.zipArray) {
            NSString *path = model.path;
            if (![path hasPrefix:self.filePath]) {
                path = [self.filePath stringByAppendingPathComponent:path];
            }
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
#pragma mark -- 解压代理成功失败
- (void)ErrorMessage:(NSString *)msg {
    if (_isCompress) {
       [XTOOLS showMessage:@"压缩失败！"];
    }
    else
    {
      [XTOOLS showMessage:@"解压失败！"];
    }
//    [[XProgressView defaultProgress]removeRelease];
    
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
    @weakify(self);
    [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
        @strongify(self);
        for (Record *model in self.zipArray) {
            NSString *path = model.path;
            if (![path hasPrefix:self.filePath]) {
                path = [self.filePath stringByAppendingPathComponent:path];
            }
//            [NSString stringWithFormat:@"%@/%@",self.filePath,name];
            NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
            if (![toPath hasPrefix:KDocumentP]) {
                toPath = [KDocumentP stringByAppendingPathComponent:toPath];
            }
            NSError *error = nil;
            if ([kFileM moveItemAtPath:path toPath:toPath error:nil]) {
                model.path = toPath;
                [[XManageCoreData manageCoreData]saveRecord:model];
            }
            else
            {
                [XTOOLS showMessage:@"转移失败"];
                 NSLog(@"path ==%@==%@",toPath,error);
                return ;
            }
        }
        [XTOOLS showMessage:@"转移成功"];
        [self reloadFilesArray];
 }];
}
- (IBAction)deleteButtonAction:(id)sender {
    NSMutableString *mstr = [NSMutableString stringWithCapacity:0];
    for (Record *model in self.zipArray) {
        if (model.name) {
            [mstr appendString:model.name];
            [mstr appendString:@"\n"];
        }
    }
    [mstr appendFormat:@"删除以上%d个文件",(int)(self.zipArray.count)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除文件" message:mstr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    @weakify(self);
    UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (Record *model in self.zipArray) {
            @strongify(self);
            NSString *path = model.path;
            if (![path hasPrefix:self.filePath]) {
                path = [self.filePath stringByAppendingPathComponent:path];
            }
//            [NSString stringWithFormat:@"%@/%@",self.filePath,s];
          BOOL r =  [kFileM removeItemAtPath:path error:nil];
            if (r) {
                BOOL re = [[XManageCoreData manageCoreData]deleteRecord:model];
                if (re) {
                    [self.filesArray removeObject:model];
                }
                else
                {
                    [XTOOLS showMessage:@"删除失败"];
                }
            }
            else
            {
                [XTOOLS showMessage:@"删除失败"];
            }
  
        }
        [self.mainTableView reloadData];
        
    }];
    [alert addAction:cancleAction];
    [alert addAction:unzipAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.headerSearchBar resignFirstResponder];
}
#pragma mark - searchBar 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length>0) {
        [self.filesArray removeAllObjects];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",self.headerSearchBar.text];
        for (Record *model in self.allFilesArray) {
            if ([pre evaluateWithObject:model.name]) {
                [self.filesArray addObject:model];
            }
        }
    }
    else
    {
         self.filesArray = [NSMutableArray arrayWithArray:self.allFilesArray];
    }
    [_mainTableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar  {
    self.filesArray = self.allFilesArray;
     [_mainTableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.headerSearchBar resignFirstResponder];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark -- XDPhotoBrowserDelegate
- (NSInteger)xdNumberOfAllPhotos {
   return _imageArray.count;
}
- (NSString *)xdTopTitleAtIndex:(NSInteger)index {
    if (index < _imageArray.count) {
    NSString *indexStr =[NSString stringWithFormat:@"%@ / %@",@(index+1),@(_imageArray.count)];
    Record *imModel = _imageArray[index];
        return imModel.path.lastPathComponent;
    }
    return nil;
}
- (NSString *)xdPhotoPahtAtIndex:(NSInteger)index {
    if (index < _imageArray.count) {
    Record *model = _imageArray[index];
    NSString *path = model.path;
    if (![path hasPrefix:self.filePath]) {
       path = [self.filePath stringByAppendingPathComponent:path];
    }
        return path;
    }
    return nil;
}
#pragma mark -- UIPopoverPresentationControllerDelegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IsPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL)shouldAutorotate {
    return YES;
}
@end
