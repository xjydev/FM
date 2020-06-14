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
#import "XProgressView.h"
#import "MoveFilesView.h"
#import "FileDetailController.h"
#import "UIView+xiao.h"
#import "XManageCoreData.h"

@interface FilesListController ()<ZipArchiveDelegate,XDPhotoBrowerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    NSMutableArray   *_allFilesArray;//本地种类的数据。
    NSMutableArray   *_filesArray;
    UIBarButtonItem  *_rightBarButton;
    BOOL              _isEditing;
    BOOL              _isCompress;
    
    NSArray          *_imageArray;
    __weak IBOutlet UIButton *_allSelectButton;
    __weak IBOutlet UILabel *selectLabel;
    
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray   *zipArray;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UISearchBar *headerSearchBar;
@property (weak, nonatomic) IBOutlet UIView *headerbView;
@property (nonatomic, strong)ZipArchive  *zipArchive;
//@property (nonatomic, strong)UIView     *bottomView;

@property (nonatomic, strong)UILabel *footLabel;

@end

@implementation FilesListController
- (UILabel *)footLabel {
    if (!_footLabel) {
        _footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        _footLabel.textAlignment = NSTextAlignmentCenter;
        _footLabel.font = [UIFont systemFontOfSize:12];
        _footLabel.textColor = [UIColor grayColor];
    }
    return _footLabel;
}
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerSearchBar.center = self.headerbView.center;
    [self.headerbView addSubview:self.headerSearchBar];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"goBack"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    
    self.navigationItem.leftBarButtonItem = leftBarButton;
   self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    if (!self.filePath) {
        self.filePath = KDocumentP;
    }
    _allFilesArray = [NSMutableArray arrayWithCapacity:0];
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    
    _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    [self bottomButtonCanSelect:NO];
    [self reloadFilesArray];
    
    self.headerSearchBar.delegate = self;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerSearchBar.frame)-0.5, kScreen_Width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.headerSearchBar addSubview:lineView];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.mainTableView addSubview:refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadFilesArray) name:kRefreshList object:nil];
    self.mainTableView.tableFooterView = self.footLabel;
    
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
    NSError *error;
    [_zipArray removeAllObjects];
    if (self.fileType != FileTypeDefault) {
        NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.filePath error:&error];
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
        NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
            NSRange range = NSMakeRange(0,obj1.length);
            
            return [obj1 compare:obj2 options:comparisonOptions range:range];

        }];
        
        [_allFilesArray removeAllObjects];
        for (NSString *name in marry) {
            if ([XTOOLS fileFormatWithPath:name] == self.fileType  ) {
                [_allFilesArray addObject:name];
            }
        }
         _filesArray = [NSMutableArray arrayWithArray:_allFilesArray];
    }
    else
    {
        NSArray *array = [kFileM contentsOfDirectoryAtPath:self.filePath error:&error];
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
        NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
            
            return (NSComparisonResult)[obj1 compare:obj2 options:comparisonOptions];
            
        }];
        [_allFilesArray removeAllObjects];
        for (NSString *name in marry) {
            if (![name hasPrefix:@"."]) {
                [_allFilesArray addObject:name];
            }
            
        }
        _filesArray = [NSMutableArray arrayWithArray:_allFilesArray];
    }
    [self reloadNoDataView];
    [self.mainTableView reloadData];
}
- (void)reloadNoDataView {
    if (_filesArray.count !=0) {
        [self.mainTableView xRemoveNoData];
        NSString *tstr = @"文件";
        switch (self.fileType) {
                   case FileTypeAudio:
                      tstr = @"音频";
                       break;
                   case FileTypeVideo:
                       tstr = @"视频";
                       break;
                   case FileTypeImage:
                       tstr = @"图片";
                       break;
                   case FileTypeDocument:
                       tstr = @"文档";
                       break;
                       
                   default:
                       break;
        }
        self.footLabel.text = [NSString stringWithFormat:@"共有%@个%@",@(_filesArray.count),tstr];
    }
    else
    {
        self.footLabel.text = nil;
        NSString *noFileStr = NSLocalizedString(@"NOfiles", nil);
        switch (self.fileType) {
            case FileTypeAudio:
                noFileStr = NSLocalizedString(@"NOaudio", nil);
                break;
            case FileTypeVideo:
                noFileStr = NSLocalizedString(@"NOvideo", nil);
                break;
            case FileTypeImage:
                noFileStr = NSLocalizedString(@"NOpictures", nil);
                break;
            case FileTypeDocument:
                noFileStr = NSLocalizedString(@"NOdocument", nil);
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
        [_rightBarButton setTitle:NSLocalizedString(@"Cancel", nil)];
//        for (UIButton *button in self.bottomView.subviews) {
//            if ([button isKindOfClass:[UIButton class]]) {
//                button.enabled = NO;
//            }
//        }
        [self bottomButtonCanSelect:NO];
        [self showBottomSelectNum:self.zipArray.count];
//        self.bottomView.userInteractionEnabled = NO;
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
//    if (self.isSelected) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    else
//    {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        UIButton *accessoryButton =(UIButton *)cell.accessoryView;
        [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
 
//    }
  
    NSString *pathName = _filesArray[indexPath.row];
    cell.textLabel.text = pathName;
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
    if (indexPath.row < _filesArray.count) {
        NSString *path = _filesArray[indexPath.row];
           if (![path hasPrefix:self.filePath]) {
              path = [self.filePath stringByAppendingPathComponent:path];
           }
           FileDetailController *detail = [FileDetailController allocFromStoryBoard];
           detail.filePath = path;
           
           [self.navigationController pushViewController:detail animated:YES];
    } 
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEditing) {
       NSString *file  = _filesArray[indexPath.row];
        [self tableViewSelectedDeSelectedPath:file selected:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_isEditing) {
        NSString *file  = _filesArray[indexPath.row];
        [self tableViewSelectedDeSelectedPath:file selected:YES];
        
    }
    else
    {
        NSString *path = [self.filePath stringByAppendingPathComponent:_filesArray[indexPath.row]];
        //先是分类列表的时候，是数组查看。如果是所有文档的时候就一个一个查看。
        switch (self.fileType) {
            case FileTypeVideo:
            {
                NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
                video.modalPresentationStyle = UIModalPresentationFullScreen;
                [video setVideoArray:_filesArray WithIndex:indexPath.row];
                [self presentViewController:video animated:YES completion:^{
                    
                }];
            }
                break;
            case FileTypeAudio:
            {
                AudioViewController *audio = [AudioViewController allocFromStoryBoard];
                [audio setAudioArray:_filesArray index:indexPath.row];
                audio.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:audio animated:YES completion:^{
                    
                }];
            }
                break;
            case FileTypeImage:
            {
                _imageArray = _filesArray;
                XDPhotoBrowerViewController *browser = [[XDPhotoBrowerViewController alloc]init];
                browser.delegate = self;
                browser.currentIndex = indexPath.row;
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
                    filesList.filePath = [self.filePath stringByAppendingPathComponent:_filesArray[indexPath.row]];
                    filesList.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:filesList animated:YES];
                    
                }
                else {
                    if ([XTOOLS fileFormatWithPath:path] == FileTypeImage) {//单个文件，如果是图片，就把所有图片找出来。
                        NSMutableArray *imArray = [NSMutableArray arrayWithCapacity:_filesArray.count];
                        for (NSString *impath in _filesArray) {
                            if ([XTOOLS fileFormatWithPath:impath] == FileTypeImage) {
                                [imArray addObject:impath];
                            }
                        }
                        NSString *indexStr = _filesArray[indexPath.row];
                        _imageArray = imArray;
                        NSInteger index = [_imageArray indexOfObject:indexStr];
                        XDPhotoBrowerViewController *browser = [[XDPhotoBrowerViewController alloc]init];
                        browser.delegate = self;
                        browser.currentIndex = index;
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
- (void)tableViewSelectedDeSelectedPath:(NSString *)path selected:(BOOL)isSelected {
    if (isSelected) {
       [self.zipArray addObject:path];
    }
    else {
        [self.zipArray removeObject:path];
    }
    if (self.zipArray.count>=1) {
        [self bottomButtonCanSelect:YES];
    }
    else
        if(self.zipArray.count==0)
        {
            [self bottomButtonCanSelect:NO];
        }
    if (self.zipArray.count == _filesArray.count) {
        _allSelectButton.selected = YES;
    }
    else
    {
        _allSelectButton.selected = NO;
    }
    [self showBottomSelectNum:self.zipArray.count];
}
#pragma mark -- tableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSError *error ;
        NSString *path = [self.filePath stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
//        [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];

        [kFileM removeItemAtPath:path error:&error];
        [[XManageCoreData manageCoreData]deleteRecordPath:path];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [self->_filesArray removeObjectAtIndex:indexPath.row];
        [self reloadNoDataView];
        [self.mainTableView reloadData];
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转移" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
        
        [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
            NSError *error = nil;
            NSString *path = [self.filePath stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
//            [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];

            NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
//            [NSString stringWithFormat:@"%@/%@",movePath,path.lastPathComponent];
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
        UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
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
//    else if ([XTOOLS fileFormatWithPath:path] == FileTypeVideo) {
//        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:_filesArray.count];
//        for (NSString *impath in _filesArray) {
//            if ([XTOOLS fileFormatWithPath:impath] == FileTypeVideo) {
//                NSString *p = [self.filePath stringByAppendingPathComponent:impath];
//                [mArray addObject:p];
//            }
//        }
//        NSInteger index =  [mArray indexOfObject:path];
//        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        NewVideoViewController *video = [mainStory instantiateViewControllerWithIdentifier:@"NewVideoViewController"];
//        [video setVideoArray:mArray WithIndex:index];
//        [self presentViewController:video animated:YES completion:^{
//
//        }];
//    }
//    else if ([XTOOLS fileFormatWithPath:path] == FileTypeAudio) {
//        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:_filesArray.count];
//        for (NSString *impath in _filesArray) {
//            if ([XTOOLS fileFormatWithPath:impath] == FileTypeAudio) {
//                NSString *p = [self.filePath stringByAppendingPathComponent:impath];
//                [mArray addObject:p];
//            }
//        }
//        NSInteger index =  [mArray indexOfObject:path];
//        AudioViewController *audio = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
//        [audio setAudioArray:mArray index:index];
//        [self presentViewController:audio animated:YES completion:^{
//
//        }];
//
//    }
    else
    {
        BOOL isPlay = [XTOOLS playFileWithPath:path OrigionalWiewController:self];
        if (!isPlay) {
            [XTOOLS showMessage:@"格式不支持"];
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
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
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
            NSString *path = [self.filePath stringByAppendingPathComponent:name];
//            [NSString stringWithFormat:@"%@/%@",self.filePath,name];
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
- (void)showBottomSelectNum:(NSInteger)num {
    NSString *numstr = [NSString stringWithFormat:@"%@",@(num)];
    NSMutableAttributedString *sAttri = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@/%@",numstr,@(_filesArray.count)]];
    [sAttri setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, numstr.length+1)];
    selectLabel.attributedText = sAttri;
}
- (void)bottomButtonCanSelect:(BOOL)isCan {
    for (NSInteger i = 501; i<504; i++) {
        UIButton *button = [self.bottomView viewWithTag:i];
        if (button.enabled == isCan) {
            return;
        }
        button.enabled = isCan;
    }
}
- (IBAction)compressButtonAction:(id)sender {
    if (self.zipArray.count >10) {
        [XTOOLS showAlertTitle:@"压缩文件太多" message:@"压缩一次最多选择10个文件" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
        return;
    }
    [self compressToZip];
}
- (IBAction)allSelectButtonAction:(UIButton *)sender {
    if (self.zipArray.count == _filesArray.count) {
        for (int i = 0; i<_filesArray.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            [self.mainTableView deselectRowAtIndexPath:path animated:NO];
        }
        [self.zipArray removeAllObjects];
        sender.selected = NO;
        [self bottomButtonCanSelect:NO];
    }
    else
    {
        self.zipArray = [NSMutableArray arrayWithArray:_filesArray];
        for (int i = 0; i<_filesArray.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
           [self.mainTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        sender.selected = YES;
        [self bottomButtonCanSelect:YES];
    }
    [self showBottomSelectNum:self.zipArray.count];
    
}
//转移按钮
- (IBAction)moveButtonAction:(id)sender {
    MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
                               
    [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
        for (NSString *name in self->_zipArray) {
            NSString * path = [self.filePath stringByAppendingPathComponent:name];
//            [NSString stringWithFormat:@"%@/%@",self.filePath,name];
            NSString *toPath = [movePath stringByAppendingPathComponent:name];
//            [NSString stringWithFormat:@"%@/%@",movePath,name];
            NSError *error = nil;
            if (![kFileM moveItemAtPath:path toPath:toPath error:&error]) {
                [XTOOLS showMessage:@"转移失败"];
                NSLog(@"error == %@",error);
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
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (NSString *s in self.zipArray) {
            NSString *path = [self.filePath stringByAppendingPathComponent:s];
//            [NSString stringWithFormat:@"%@/%@",self.filePath,s];
            [kFileM removeItemAtPath:path error:nil];
            [self->_filesArray removeObject:s];
            
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
        [_filesArray removeAllObjects];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",self.headerSearchBar.text];
        for (NSString *s in _allFilesArray) {
            if ([pre evaluateWithObject:s]) {
                [_filesArray addObject:s];
            }
        }
    }
    else
    {
         _filesArray = [NSMutableArray arrayWithArray:_allFilesArray];
    }
    [_mainTableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar  {
    _filesArray = _allFilesArray;
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
#pragma mark -- xdPhotoBrowserDelegate
- (NSInteger)xdNumberOfAllPhotos {
   return _imageArray.count;
}
- (NSString *)xdPhotoPahtAtIndex:(NSInteger)index {
  if (index < _imageArray.count) {
        NSString *path = _imageArray[index];
        if (![path hasPrefix:self.filePath]) {
           path = [self.filePath stringByAppendingPathComponent:path];
        }
        return path;
    }
    return nil;
}
- (NSAttributedString *)xdTopAttributedTitleAtIndex:(NSInteger)index {
    if (index < _imageArray.count) {
        NSString *indexStr =[NSString stringWithFormat:@"%@ / %@",@(index+1),@(_imageArray.count)];
        NSString *titleStr =[NSString stringWithFormat:@"%@\n%@",indexStr,_imageArray[index]];
        NSMutableAttributedString *mattri = [[NSMutableAttributedString alloc]initWithString:titleStr];
        [mattri setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(indexStr.length+1, titleStr.length - indexStr.length-1)];
        return mattri;
    }
    return nil;
}

@end
