//
//  MainViewController.m
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "MainViewController.h"
#import "DrawerViewController.h"
#import "PopViewController.h"

#import "MainSectionHeaderView.h"
#import "MainHeaderView.h"
#import "MainTableViewCell.h"
#import "XTools.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import <SDWebImage/SDImageCache.h>
#import "XDPhotoBrowerViewController.h"
#import "XimageViewController.h"
#import "VideoListController.h"
#import "FileDetailController.h"
#import "NewVideoViewController.h"
#import "AudioViewController.h"
#import "XQuickLookController.h"
#import "RecordViewController.h"
#import "TransferIPViewController.h"
#import "FaceConnectController.h"
#import "ScanViewController.h"
#import "SearchViewController.h"
#import "RecordViewController.h"
#import "XManageCoreData.h"
#import "UIView+xiao.h"
#import "ZipArchive.h"
#import "MoveFilesView.h"
#import "MultipleSelectViewController.h"

@interface MainViewController ()<ZipArchiveDelegate,UIPopoverPresentationControllerDelegate,UITableViewDelegate,UITableViewDataSource,XDPhotoBrowerDelegate,TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) MainSectionHeaderView *headerView;
@property (nonatomic, weak) UITextField *currentTextField;
@property (nonatomic, assign) FileType fileType;
@property (nonatomic, assign) NSInteger editType;//0 不编辑，1，排序 2，选择
@property (nonatomic, strong) NSMutableArray *allFilesArray;//全部
@property (nonatomic, strong) NSMutableArray *showFilesArray;//显示的
@property (nonatomic, strong) NSMutableArray *selectedArray;//选择的
@property (nonatomic, strong) NSMutableArray *imageArray;//筛选出来的图片
@property (nonatomic, strong) NSMutableArray *recordArray;//历史记录。
@property (nonatomic, assign)BOOL isCompress;
@property (nonatomic, strong)ZipArchive  *zipArchive;
@property (strong, nonatomic) IBOutlet MainSectionFooterView *bottomView;
@property (nonatomic, assign)NSInteger nameNum;
@end

@implementation MainViewController
- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArray;
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
    
    if (!self.filePath) {
        self.filePath = KDocumentP;
    }
    self.allFilesArray = [NSMutableArray arrayWithCapacity:0];
    self.showFilesArray = [NSMutableArray arrayWithCapacity:0];
    self.selectedArray = [NSMutableArray arrayWithCapacity:0];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_add"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemAction:)];
    
    if (self.isSub) {
        self.title = self.filePath.lastPathComponent;
    }
    else {
        self.title = @"简单播放";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_setting"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonItemAction)]; 
        self.bottomView.frame = CGRectMake(0, 0, kScreen_Width, 70);
        [self.bottomView.moreButton addTarget:self action:@selector(gotoRecordList) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView.headerControl addTarget:self action:@selector(gotoPlayRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.headerView = [[MainSectionHeaderView alloc]initWithReuseIdentifier:@"MainSectionHeaderView"];
    @weakify(self);
    self.headerView.headerSelectedHanlder = ^(NSInteger tag, NSObject *obj) {
        @strongify(self);
        if ([obj isKindOfClass:[UITextField class]]) {
            self.currentTextField = (UITextField *)obj;
            [self searchFilesWithSearchText:self.currentTextField.text];
        }
        else {
            [self headerSelectedTag:tag];
        }
    };
    self.fileType = MAX(0,self.headerView.fileType-11);
    [self reloadAllFiles];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    if (@available(iOS 10.0, *)) {
        self.mainTableView.refreshControl = refresh;
    } else {
        [self.mainTableView addSubview:refresh];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadAllFiles) name:kRefreshList object:nil];
}
- (void)gotoRecordList {
    RecordViewController *VC = [RecordViewController allocFromStoryBoard];
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)gotoPlayRecord {
    Record *model = self.recordArray.firstObject;
    if (model.fileType.integerValue == 0) {
         model.fileType = @([XTOOLS fileFormatWithPath:model.path]);
    }
    if (model.fileType.integerValue == FileTypeAudio) {
        AudioViewController *audio = [AudioViewController allocFromStoryBoard];
        audio.audioPath = model.path;
        [audio getAudioArrayCurrentPath];
        audio.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:audio animated:YES completion:^{
            
        }];
    }
    else if (model.fileType.integerValue == FileTypeVideo) {
        NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
        video.modalPresentationStyle = UIModalPresentationFullScreen;
        video.videoPath = model.path;
        [video getVideoArrayCurrentPath];
        [self presentViewController:video animated:YES completion:^{
            
        }];
    }
    
}
- (void)refreshPullUp:(UIRefreshControl *)rc {
    [self reloadAllFiles];
    [self performSelector:@selector(endRefresh:) withObject:rc afterDelay:0.8];
}
- (void)endRefresh:(UIRefreshControl *)rc {
    [rc endRefreshing];
}
- (void)leftBarButtonItemAction {
    DrawerViewController *drawerVC = (DrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [drawerVC openLeftMenu];
}
- (void)rightBarButtonItemAction:(UIBarButtonItem *)item {
    PopViewController *pop = [PopViewController returnFromStoryBoard];
    pop.isSub = self.isSub;
    pop.modalPresentationStyle = UIModalPresentationPopover;
    pop.popoverPresentationController.barButtonItem = item;
    pop.popoverPresentationController.delegate = self;
    pop.popoverPresentationController.backgroundColor = kCOLOR(0xffffff, 0x111111);
    pop.preferredContentSize = CGSizeMake(160, self.isSub?176:264);
    @weakify(self);
    pop.completeSelectBlock = ^(NSInteger index) {
        @strongify(self);
        switch (index) {
            case 0:
            {
                TransferIPViewController *VC = [TransferIPViewController allocFromStoryBoard];
                VC.filePath = self.filePath;
                [self.navigationController pushViewController:VC animated:YES];
            }
                break;
            case 1:
            {
                FaceConnectController *transfer = [FaceConnectController allocFromStoryBoard];
                transfer.folderPath = self.filePath;
                [self.navigationController pushViewController:transfer animated:YES];
            }
                break;
            case 2:
            {
                TZImagePickerController *pickerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:10000 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
                pickerVC.isSelectOriginalPhoto = YES;
                pickerVC.allowTakeVideo = YES;
                pickerVC.allowTakePicture = YES;
                [pickerVC setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
                    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
                }];
                pickerVC.allowPickingMultipleVideo = YES;
                pickerVC.sortAscendingByModificationDate = YES;
                pickerVC.showSelectBtn = NO;
                @weakify(self);
                [pickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                    @strongify(self);
                    [self importPhotoWithArray:assets];
                    
                }];
                
                pickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:pickerVC animated:YES completion:^{
                    
                }];
            }
                break;
            case 3://新建文件夹
            {
                UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:@"请输入新建文件夹名称" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        
                        
                    }];
                    UITextField *textField = aler.textFields.firstObject;
                    textField.placeholder = @"新建文件夹";
                    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"新建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self createNewFileName:textField.text];
                    }];
                    [aler addAction:cancleAction];
                    [aler addAction:addAction];
                    [self presentViewController:aler animated:YES completion:nil];
            }
                break;
            case 4:
            {
                ScanViewController *VC = [ScanViewController allocFromStoryBoard];
                [self.navigationController pushViewController:VC animated:YES];
            }
                break;
            case 5:
            {
                SearchViewController *VC = [SearchViewController allocFromStoryBoard];
                [self.navigationController pushViewController:VC animated:YES];
            }
                break;
            default:
            {
            }
                break;
        }
       
    };
    [self presentViewController:pop animated:YES completion:^{
        
    }];
}
- (BOOL)createNewFileName:(nullable NSString *)name {
    
    if (name.length == 0) {
        name = @"新建文件夹";
    }
    if (self.filePath.length == 0) {
        self.filePath = KDocumentP;
    }
    NSString *lpath = [self.filePath stringByAppendingPathComponent:name];
    NSString *newPath = lpath;
    int num = 0;
    while ([kFileM fileExistsAtPath:newPath]) {
        num ++;
        newPath = [NSString stringWithFormat:@"%@%d",lpath,num];
    }
    BOOL b = [kFileM createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (b) {
        if (self.fileType == FileTypeDefault) {
            [XTOOLS showMessage:@"创建成功"];
            [self reloadAllFiles];
        }
        else {
            @weakify(self);
            [XTOOLS showAlertTitle:@"是否立即查看新建文件夹" message:@"只有在“全部”中，才可以看到文件夹，点击“查看”会切换到“全部”。" buttonTitles:@[@"取消",@"查看"] completionHandler:^(NSInteger num) {
                if (num == 1) {
                    @strongify(self);
                    self.fileType = FileTypeDefault;
                    self.headerView.fileType = self.fileType+11;
                    [self.headerView reloadHeaderView];
                    [self reloadAllFiles];
                }
            }];
        }
    }
    else {
        [XTOOLS showMessage:@"创建失败"];
    }
    return b;
}
- (void)importPhotoWithArray:(NSArray *) arr {
    [XTOOLS showLoading:@"导入中"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        self.nameNum = [kUSerD integerForKey:@"userdNameNum"];
        for (int i=0;i< arr.count;i++) {
            @autoreleasepool {
                PHAsset *phAsset = arr[i];;

                if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
                    options.networkAccessAllowed = YES;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {

                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            NSURL *pathUrl = ((AVURLAsset *)asset).URL;
                            //                        asset.availableChapterLocales
                            NSString *name =[pathUrl.absoluteString lastPathComponent];
                            if (!name) {
                                self.nameNum ++;
                                name =[NSString stringWithFormat:@"相册视频%d.mov",(int)self.nameNum];
                            }
                            int pa = 1;
                            NSString *pName = name;
                            while ([kFileM fileExistsAtPath:[KDocumentP stringByAppendingPathComponent:pName]]) {
                                pName = [NSString stringWithFormat:@"%@(%d).%@",name.stringByDeletingPathExtension,pa,name.pathExtension];
                                pa++;
                            }
                            name = pName;
                            NSError *error;
                            NSData *moveData = [NSData dataWithContentsOfURL:pathUrl];
                            [moveData writeToFile:[self.filePath stringByAppendingPathComponent:name] atomically:YES];
                            moveData = nil;
                            if(error){
                                NSLog(@"error == %@",error);
                            }
                        } else {

                        }
                    }];
                }
                else {
                    PHImageRequestOptions *options = [PHImageRequestOptions new];
                    options.networkAccessAllowed = YES;
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    options.synchronous = YES;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {

                    };

                    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                        NSData *imageData ;
                        NSString *imageType;
                        if (UIImagePNGRepresentation(result)) {
                            imageData = UIImagePNGRepresentation(result);
                            imageType = @".png";
                        }
                        else {
                            imageData = UIImageJPEGRepresentation(result, 1.0);
                            imageType = @".jpg";
                        }
                        self.nameNum++;
                        
                        NSString *imageName = [NSString stringWithFormat:@"相册%d%@",(int)self.nameNum,imageType];
                        NSString *imagePath = [self.filePath stringByAppendingPathComponent:imageName];
                        [imageData writeToFile:imagePath  atomically:YES];
                        imageData = nil;
                    }];

                }

            }
            [XTOOLS showLoading:[NSString stringWithFormat:@"%d/%d",i,(int)arr.count]];

        }
        //结束后就保存以前的相册名称序列，防止以后的重名，然后刷新。

       
        if (self.nameNum > 999999) {
            self.nameNum = 0;
        }
        [kUSerD setInteger:self.nameNum forKey:@"userdNameNum"];
        [kUSerD synchronize];
    });
    //完成后通知
    dispatch_group_notify(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [XTOOLS hiddenLoading];
            @weakify(self);
            [XTOOLS showAlertTitle:@"完成" message:@"选择的资源已经导入到应用中，可以在文件列表中查看。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
                @strongify(self);
                [self reloadAllFiles];
            }];
        });
    });
}
#pragma mark -- 获取本地数据
- (void)reloadAllFiles {
    NSError *error;
    [self.allFilesArray removeAllObjects];
    [self.showFilesArray removeAllObjects];
    [self.selectedArray removeAllObjects];
    if (!self.isSub) {//非子路径获取记录
        NSArray *carray = [[XManageCoreData manageCoreData]getAllRecord];
        if (carray.count >= 1) {
            self.recordArray = [NSMutableArray arrayWithObject:carray.firstObject];
        }
    }
    NSArray *array ;
    if (self.headerView.fileType == 11) {//全部的时候子目录
      array = [kFileM contentsOfDirectoryAtPath:self.filePath error:&error];
    }
    else {
        array = [kFileM subpathsOfDirectoryAtPath:self.filePath error:&error];
    }
    for (NSString *name in array) {
        if (![name.lastPathComponent hasPrefix:@"."]) {
            NSString *fPath = name;
            if (![fPath hasPrefix:self.filePath]) {
                fPath = [self.filePath stringByAppendingPathComponent:fPath];
            }
            Record *model = [[XManageCoreData manageCoreData]createRecordWithPath:fPath];
            [self.allFilesArray addObject:model];
        }
    }
    
    self.showFilesArray = [self sortAllFilesWithArray:self.allFilesArray forType:self.fileType];
    if (self.fileType != FileTypeDefault) {//全部文件的时候有自定义的图
       [self reloadNoDataView];
    }
    else {
        [self.mainTableView xRemoveNoData];
    }
    [self.mainTableView reloadData];
}
- (NSMutableArray *)sortAllFilesWithArray:(NSArray *)arr forType:(FileType)type {
    NSMutableArray *sortArray = [NSMutableArray arrayWithCapacity:arr.count];
    for (Record *model in arr) {
        if (type == FileTypeDefault) {
            [sortArray addObject:model];
        }
        else {
            if ([XTOOLS fileFormatWithPath:model.path] == type) {
                [sortArray addObject:model];
            }
        }
    }
    NSString *key = @"name";
    BOOL ascending = YES;
    switch (self.headerView.sortType) {
        case 21:
        {
            key = @"name";
            ascending = YES;
        }
            break;
        case 22:
        {
            key = @"markInt";
            ascending = YES;
        }
            break;
        case 23:
        {
            key = @"size";
            ascending = NO;
        }
            break;
        case 24:
        {
            key = @"modifyDate";
            ascending = YES;
        }
            break;
        case 25:
        {
            key = @"createDate";
            ascending = NO;
        }
            break;
            
        default:
            
            break;
    }
    NSSortDescriptor *descriptor = nil;
    if ([key isEqualToString:@"name"]) {
        descriptor = [[NSSortDescriptor alloc]initWithKey:key ascending:ascending comparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
            return [obj1 compare:obj2 options:NSWidthInsensitiveSearch|NSNumericSearch];
        }];
    }
    else {
        descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    }
    [sortArray sortUsingDescriptors:@[descriptor]];
    return sortArray;
}
- (void)reloadNoDataView {
    if (self.showFilesArray.count == 0) {
        NSString *str = @"没有文件";
        switch (self.fileType) {
            case FileTypeAudio:
                str = @"没有音频";
                break;
            case FileTypeVideo:
                str = @"没有视频";
                break;
            case FileTypeImage:
                str = @"没有图片";
                break;
            case FileTypeDocument:
                str = @"没有文档";
                break;
                
            default:
                str = @"没有文件";
                break;
        }
        [self.mainTableView xNoDataThisViewTitle:str centerY:198];
    }
    else {
        [self.mainTableView xRemoveNoData];
    }
}
#pragma mark -- header 操作 tag search
- (void)searchFilesWithSearchText:(NSString *)text {
    NSLog(@"search == %@",text);
    if (self.allFilesArray.count > 0) {
        if (text.length > 0) {
            [self.showFilesArray removeAllObjects];
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",text];
            for (Record *model in self.allFilesArray) {
                if ([pre evaluateWithObject:model.name]) {
                    [self.showFilesArray addObject:model];
                }
            }
            [self.mainTableView reloadData];
        }
        else
        {
            [self reloadAllFiles];
        }
    }
}
- (void)headerSelectedTag:(NSInteger)tag {
    
    switch (tag) {
        case 0: {//取消按钮
            if (self.currentTextField.text.length != 0) {
                self.currentTextField.text = @"";
                [self.currentTextField resignFirstResponder];
            }
            if (self.editType != 0) {
                if (self.editType == 1) {
                    [self showManualSortAlertView];
                }
                else if (self.editType == 2) {
                    self.editType = 0;
                    [self.mainTableView setEditing:NO animated:YES];
                    [self.selectedArray removeAllObjects];
                    [self.mainTableView reloadData];
                }
            }
            else {
              [self.mainTableView reloadData];
            }
        }
            break;
            case 1:
            case 2:
            [self.mainTableView reloadData];
            break;
        case 3: {//编辑
            self.editType = 2;
            [self.mainTableView setEditing:YES animated:YES];
            [self.mainTableView reloadData];
        }
            break;
        case 11: {//全部
            if (self.fileType != FileTypeDefault) {
                self.fileType = FileTypeDefault;
                [self reloadAllFiles];
            }
        }
            break;
        case 12: {//视频
            if (self.fileType != FileTypeVideo) {
                self.fileType = FileTypeVideo;
                [self reloadAllFiles];
            }
        }
            break;
        case 13: {//音频
            if (self.fileType != FileTypeAudio) {
                self.fileType = FileTypeAudio;
                [self reloadAllFiles];
            }
        }
            break;
        case 14: {//图片
            if (self.fileType != FileTypeImage) {
                self.fileType = FileTypeImage;
                [self reloadAllFiles];
            }
        }
            break;
        case 15: {//文档
            if (self.fileType != FileTypeDocument) {
                self.fileType = FileTypeDocument;
                [self reloadAllFiles];
            }
        }
            break;
        case 21: {//名称排序
            self.editType = 0;
            self.mainTableView.editing = NO;
            [self reloadAllFiles];
        }
            break;
        case 22: {//手动排序
            self.editType = 1;
            [self.mainTableView setEditing:YES animated:YES];
            [self.mainTableView reloadData];
        }
            break;
        case 23: {//文件大小
            self.editType = 0;
            self.mainTableView.editing = NO;
            [self reloadAllFiles];
        }
            break;
        case 24: {//创建时间排序
            self.editType = 0;
            self.mainTableView.editing = NO;
            [self reloadAllFiles];
        }
            break;
        case 25: {//修改日期
            self.editType = 0;
            self.mainTableView.editing = NO;
            [self reloadAllFiles];
        }
            break;
        case 31: {//搜索框
            
        }
            break;
        case 32: {//搜索
            [self.currentTextField resignFirstResponder];
        }
            break;
        case 41: {//删除
            [self deleteSelectedFiles];
        }
            break;
        case 42: {//压缩
            [self compressSelectedFiles];
        }
            break;
        case 43: {//全选
            if (self.selectedArray.count == self.showFilesArray.count) {
                for (NSInteger i = 0; i<self.selectedArray.count; i++) {
                    [self.mainTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
                }
                [self.selectedArray removeAllObjects];
            }
            else {
                self.selectedArray = [NSMutableArray arrayWithArray:self.showFilesArray];
                for (NSInteger i = 0; i<self.selectedArray.count; i++) {
                    [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
            break;
        case 44: {//转移
            [self moveOut];
        }
            break;
        case 45: {//转入
            [self moveIn];
        }
            break;
            
        default: {
            
        }
            break;
    }
}
- (void)moveOut {
    if (self.selectedArray.count == 0) {
        [XTOOLS showMessage:@"未选择"];
        return;
    }
    MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
        @weakify(self);
        [fileView showWithFolderArray:nil withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
            @strongify(self);
            for (Record *model in self.selectedArray) {
                NSString *path = model.path;
                if (![path hasPrefix:KDocumentP]) {
                    path = [KDocumentP stringByAppendingPathComponent:path];
                }
    //            [NSString stringWithFormat:@"%@/%@",self.filePath,name];
                NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
                if (![toPath hasPrefix:KDocumentP]) {
                    toPath = [KDocumentP stringByAppendingPathComponent:toPath];
                }
                NSError *error = nil;
                if ([kFileM moveItemAtPath:path toPath:toPath error:&error]) {
                    model.path = toPath;
                    [[XManageCoreData manageCoreData]saveRecord:model];
                }
                else
                {
                    [XTOOLS showMessage:@"转移失败"];
                     NSLog(@"path == %@==%@==%@",path,toPath,error);
                    return ;
                }
            }
            [XTOOLS showMessage:@"转移成功"];
            [self reloadAllFiles];
     }];
    
}
- (void)moveIn {
    MultipleSelectViewController *selectVC = [MultipleSelectViewController allocFromInit];
    @weakify(self);
    [selectVC selectFileComplete:^(NSArray * _Nonnull selectArray) {
        @strongify(self);
        [self moveInWithArray:selectArray];
        
    }];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
- (void)moveInWithArray:(NSArray *)array {
    [XTOOLS showLoading:@"转入中"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *name in array) {
            NSString *oldPath = name;
            if (![name hasPrefix:KDocumentP]) {
              oldPath = [KDocumentP stringByAppendingPathComponent:name];
            }
            NSString *toPath = [self.filePath stringByAppendingPathComponent:oldPath.lastPathComponent];
            NSError *error = nil;
            if ([kFileM moveItemAtPath:oldPath toPath:toPath error:nil]) {
                Record *model = [[XManageCoreData manageCoreData]getRecordObjectWithPath:oldPath];
                if (model) {
                    model.path = toPath;
                    [[XManageCoreData manageCoreData]saveRecord:model];
                }
            }
            else {
                [XTOOLS showMessage:@"转移失败"];
                 NSLog(@"path ==%@==%@",toPath,error);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [XTOOLS hiddenLoading];
            [XTOOLS showMessage:@"转入完成"];
            [self reloadAllFiles];
        });
    });
    
}
- (void)deleteSelectedFiles {
    if (self.selectedArray.count == 0) {
        [XTOOLS showMessage:@"未选择"];
        return;
    }
    else {
        @weakify(self);
        NSString *message = [NSString stringWithFormat:@"确认删除选择的%d个文件？",(int)self.showFilesArray.count];
        [XTOOLS showAlertTitle:@"确认删除" message:message buttonTitles:@[@"取消",@"删除"] completionHandler:^(NSInteger num) {
            @strongify(self);
            if (num == 1) {
                for (Record *model in self.selectedArray) {
                    [self deleteFileRecordModel:model];
                }
                [self reloadAllFiles];
            }
        }];
    }
}
- (BOOL)deleteFileRecordModel:(Record *)model {
    NSString *path = model.path;
    if (![path hasPrefix:KDocumentP]) {
        path = [KDocumentP stringByAppendingPathComponent:path];
    }
    BOOL r =  [kFileM removeItemAtPath:path error:nil];
    if (r) {
        BOOL re = [[XManageCoreData manageCoreData]deleteRecord:model];
        if (re) {
            [self.showFilesArray removeObject:model];
        }
    }
    return r;
}

- (void)showManualSortAlertView {
    [XTOOLS showAlertTitle:@"确认排序" message:@"确定保存手动排列的文件顺序？" buttonTitles:@[@"取消排序",@"确定"] completionHandler:^(NSInteger num) {
        if (num == 1) {
            for (NSInteger i = 0; i<self.showFilesArray.count; i++) {
                Record *model = self.showFilesArray[i];
                model.markInt = @(i);
                [[XManageCoreData manageCoreData]saveRecord:model];
            }
            self.editType = 0;
            self.mainTableView.editing = NO;
            NSLog(@"保存排序顺序");
        }
        else {
            self.mainTableView.editing = NO;
            self.editType = 0;
            self.headerView.sortType = 0;
            [self reloadAllFiles];
        }
    }];
}
#pragma mark -- TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
#pragma mari -- header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}
#pragma mark -- footer
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!self.isSub && self.headerView.headerType == XMainHeaderTypeDefault) {
        if (self.recordArray.count > 0) {
          return 70.0;
        }
    }
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!self.isSub && self.headerView.headerType == XMainHeaderTypeDefault) {
        if (self.recordArray.count > 0) {
            self.bottomView.model = self.recordArray.firstObject;
            return self.bottomView;
        }
    }
    return nil;
}
#pragma mark cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.allFilesArray.count == 0&&self.fileType == FileTypeDefault) {//如果全部的时候没有问题显示引导。
        return 2;
    }
    return self.showFilesArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allFilesArray.count == 0&&self.fileType == FileTypeDefault) {
        return 420.0;
    }
    return 70.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allFilesArray.count == 0&&self.fileType == FileTypeDefault) {
        MainNoDataViewCell *nCell = [tableView dequeueReusableCellWithIdentifier:@"MainNoDataViewCell" forIndexPath:indexPath];
        nCell.indexPath = indexPath;
        return nCell;
    }
    else {
        MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
        Record *model = self.showFilesArray[indexPath.row];
        cell.model = model;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self gotoFileDetailWithIndex:indexPath.row];
}
- (void)gotoFileDetailWithIndex:(NSInteger)index {
    if (index < self.showFilesArray.count) {
        Record *model = self.showFilesArray[index];
        NSString *path = model.path;
        if (![path hasPrefix:KDocumentP]) {
            path = [KDocumentP stringByAppendingPathComponent:path];
        }
        FileDetailController *detail = [FileDetailController allocFromStoryBoard];
        detail.filePath = path;
        [self.navigationController pushViewController:detail animated:YES];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.currentTextField resignFirstResponder];
}
#pragma mark -- 选择。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.showFilesArray.count) {
        Record *model =[self.showFilesArray objectAtIndex:indexPath.row];
        if (self.headerView.headerType == XMainHeaderTypeEdit) {//编辑的时候
            if (![self.selectedArray containsObject:model]) {
                [self.selectedArray addObject:model];
            }
        }
        else {
            [self gotoPlayerWithRecordModel:model index:indexPath.row];
        }
    }
}
- (void)gotoPlayerWithRecordModel:(Record *)model index:(NSInteger)index {
    NSString *path = model.path;
    if (![path hasPrefix:KDocumentP]) {
        path = [KDocumentP stringByAppendingPathComponent:path];
    }
    switch (self.fileType) {
        case FileTypeDefault:
        {
          if ([XTOOLS fileFormatWithPath:path] == FileTypeFolder ) {
              MainViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
              v.filePath = path;
              v.isSub = YES;
              [self.navigationController pushViewController:v animated:YES];
          }
          else if ([XTOOLS fileFormatWithPath:path] == FileTypeImage){
              [self.imageArray removeAllObjects];
              self.imageArray = [self sortAllFilesWithArray:self.showFilesArray forType:FileTypeImage];
              NSInteger currentIndex = [self.imageArray indexOfObject:model];
              XDPhotoBrowerViewController *browser = [[XDPhotoBrowerViewController alloc]init];
              browser.delegate = self;
              browser.currentIndex = currentIndex;
              [self.navigationController pushViewController:browser animated:YES];
          }
          else if ([XTOOLS fileFormatWithPath:path] == FileTypeCompress){
              @weakify(self);
              [XTOOLS showAlertTitle:@"解压" message:@"是否解压此文件到当前文件夹" buttonTitles:@[@"取消",@"解压"] completionHandler:^(NSInteger num) {
                  @strongify(self);
                  if (num == 1) {
                      [self deCompressWithPath:path];
                  }
                  
              }];
           }
          else if ([XTOOLS fileFormatWithPath:path] == FileTypeAudio) {
              AudioViewController *audio = [AudioViewController allocFromStoryBoard];
              audio.modalPresentationStyle = UIModalPresentationFullScreen;
              NSArray *audioArr = [self sortAllFilesWithArray:self.showFilesArray forType:FileTypeAudio];
              NSInteger currentIndex = [audioArr indexOfObject:model];
              [audio setAudioArray:audioArr index:currentIndex];
              NSLog(@"ar2 == %@ == %@",audioArr,@(currentIndex));
              [self presentViewController:audio animated:YES completion:^{
                  
              }];
          }
          else if ([XTOOLS fileFormatWithPath:path] == FileTypeVideo) {
              NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
              video.modalPresentationStyle = UIModalPresentationFullScreen;
              NSArray *videoArr = [self sortAllFilesWithArray:self.showFilesArray forType:FileTypeVideo];
              NSInteger currentIndex = [videoArr indexOfObject:model];
              NSLog(@"ar1 == %@ == %@",videoArr,@(currentIndex));
              [video setVideoArray:videoArr WithIndex:currentIndex];
              [self presentViewController:video animated:YES completion:^{
                  
              }];
          }
          else {
              [XTOOLS playFileWithPath:path OrigionalWiewController:self];
          }
        }
            break;
        case FileTypeVideo:
        {
            NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
            video.modalPresentationStyle = UIModalPresentationFullScreen;
            [video setVideoArray:self.showFilesArray WithIndex:index];
            [self presentViewController:video animated:YES completion:^{
                
            }];
        }
            break;
        case FileTypeAudio:
        {
            AudioViewController *audio = [AudioViewController allocFromStoryBoard];
            audio.modalPresentationStyle = UIModalPresentationFullScreen;
            [audio setAudioArray:self.showFilesArray index:index];
            [self presentViewController:audio animated:YES completion:^{
                
            }];
        }
            break;
        case FileTypeImage:
        {
            XDPhotoBrowerViewController *browser = [[XDPhotoBrowerViewController alloc]init];
            self.imageArray = self.showFilesArray;
            browser.delegate = self;
            browser.currentIndex = index;
            [self.navigationController pushViewController:browser animated:YES];
        }
            break;
        case FileTypeDocument:
        {
            XQuickLookController *xql = [[XQuickLookController alloc]init];
            xql.itemArray = self.showFilesArray;
            xql.currentIndex = index;
            [self.navigationController pushViewController:xql animated:YES];
        }
            break;
            
        default:
            break;
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.showFilesArray.count) {
        Record *model =[self.showFilesArray objectAtIndex:indexPath.row];
        if ([self.selectedArray containsObject:model]) {
           [self.selectedArray removeObject:model];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @weakify(self)
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        @strongify(self);
        [self deleteFileWithIndex:indexPath.row];
        }];
    UITableViewRowAction *detailRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"详情" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        @strongify(self);
        [self gotoFileDetailWithIndex:indexPath.row];
    }];
    detailRoWAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];
    return @[deleteRoWAction,detailRoWAction];
}
- (void)deleteFileWithIndex:(NSInteger)index {
    [XTOOLS showAlertTitle:@"确认删除" message:@"确定删除文件？" buttonTitles:@[@"取消",@"删除"] completionHandler:^(NSInteger num) {
        if (num == 1) {
            if (index < self.showFilesArray.count) {
                Record *model = self.showFilesArray[index];
                NSString *path = model.path;
                if (![path hasPrefix:KDocumentP]) {
                    path = [KDocumentP stringByAppendingPathComponent:path];
                }
                NSError *error = nil;
                [kFileM removeItemAtPath:path error:&error];
                if (!error) {
                    [self reloadAllFiles];
                }
                NSLog(@"error == %@",error);
            }
        }
    }];
}
#pragma mark -- 排序
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editType == 2) {
       return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editType == 1) {
        return YES;
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
     toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (destinationIndexPath.row < self.showFilesArray.count) {
       [self.showFilesArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    }
}
#pragma mark -- UIPopoverPresentationControllerDelegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -- MWPhotoBrowserDelegate
- (NSInteger)xdNumberOfAllPhotos {
   return self.imageArray.count;
}
- (NSString *)xdPhotoPahtAtIndex:(NSInteger)index {
   if (index < self.imageArray.count) {
        Record *model = self.imageArray[index];
        NSString *path = model.path;
        if (![path hasPrefix:KDocumentP]) {
            path = [KDocumentP stringByAppendingPathComponent:path];
        }
        return path;
    }
    return nil;
}
- (UIImage *)xdThumbnailPhotoAtIndex:(NSInteger)index {
    if (index < self.imageArray.count) {
        Record *model = self.imageArray[index];
        NSString *path = model.path;
        NSString *pathlast = kSubDokument(path);
        if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:pathlast]) {
            return [[SDImageCache sharedImageCache]imageFromCacheForKey:pathlast];
        }
    }
    return nil;
}
- (NSString *)xdTopTitleAtIndex:(NSInteger)index {
    if (index < self.imageArray.count) {
        Record *imModel = self.imageArray[index];
        return imModel.path.lastPathComponent;
    }
    else {
        return nil;
    }
}
#pragma mark -- 压缩解压
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
        [self reloadAllFiles];
    }
    else
    {
        [XTOOLS showMessage:@"解压失败"];
    }
}

- (void)compressSelectedFiles {
    if (self.selectedArray.count == 0) {
        [XTOOLS showMessage:@"未选择"];
        return;
    }
    else {
        @weakify(self);
        NSString *message = [NSString stringWithFormat:@"确认打包压缩选择的%d个文件？请输入压缩包名称。",(int)self.selectedArray.count];
        [XTOOLS showAlertTextField:nil placeholder:@"压缩包名称" title:@"确认打包压缩" message:message buttonTitles:@[@"取消",@"确定"] completionHandler:^(NSInteger num, NSString *textValue) {
            @strongify(self);
            if (num == 1) {
                NSString *zipName = textValue;
                if (zipName.length == 0) {
                    Record *fmodel = self.selectedArray.firstObject;
                    zipName = [NSString stringWithFormat:@"%@",fmodel.name.stringByDeletingPathExtension.length > 6?[fmodel.name substringToIndex:6]:fmodel.name.stringByDeletingPathExtension];
                }
                NSString *zipPath = [self.filePath stringByAppendingPathComponent:[zipName stringByAppendingPathExtension:@"zip"]];
                [self.zipArchive CreateZipFile2:zipPath];
                for (Record *m in self.selectedArray) {
                    NSString *mpath = m.path;
                    if (![mpath hasPrefix:KDocumentP]) {
                        mpath = [KDocumentP stringByAppendingPathComponent:mpath];
                    }
                    [self.zipArchive addFileToZip:mpath newname:mpath.lastPathComponent];
                }
                if ([self.zipArchive CloseZipFile2]) {
                    [XTOOLS showMessage:@"压缩成功"];
                    [self reloadAllFiles];
                    
                }else
                {
                    [XTOOLS showMessage:@"压缩失败"];
                }
            }
        }];
    }
}
- (void)ErrorMessage:(NSString *)msg {
    NSLog(@"compress == %@",msg);
    if (self.isCompress) {
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
