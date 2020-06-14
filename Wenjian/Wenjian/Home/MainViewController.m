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

#import "XTools.h"

#import "NewVideoViewController.h"
#import "RecordViewController.h"
#import "TransferIPViewController.h"
#import "FaceConnectController.h"
#import "ScanViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "SearchViewController.h"
#import "PurchaseView.h"
#import "FilesListCell.h"
#import "FilesListController.h"
#import "XimageViewController.h"
#import "VideoListController.h"
#import "HomePopViewController.h"
#import "FileDetailController.h"
#import "UIView+badgeValue.h"
@interface MainViewController ()<UIPopoverPresentationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate>

@property (nonatomic, assign)NSInteger nameNum;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (weak, nonatomic) IBOutlet PurchaseView *bottomAdView;
@property (nonatomic, strong)NSMutableArray *mainArray;
@property (nonatomic, strong)NSMutableArray *moveArray;

@end

@implementation MainViewController
- (NSMutableArray *)mainArray {
    if (!_mainArray) {
        _mainArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _mainArray ;
}
- (NSMutableArray *)moveArray {
    if (!_moveArray) {
        _moveArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _moveArray;
}
- (void)viewDidLoad {
    [super viewDidLoad]; 
    self.title = @"保密文件";
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"transfer"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemAction:)];
    [self reloadAllFolder];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    if (@available(iOS 10.0, *)) {
        self.mainCollectionView.refreshControl = refresh;
    } else {
        [self.mainCollectionView addSubview:refresh];
    }
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self performSelector:@selector(showNewGuide) withObject:nil afterDelay:0.2];
}
- (void)showNewGuide {
    if (![kUSerD boolForKey:kGuide]) {
        [XTOOLS showAlertTitle:@"新手引导" message:@"*点击右上角“=”号添加文件。\n*点击或者长按“+”号新家文件夹。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            [kUSerD setBool:YES forKey:kGuide];
            [kUSerD synchronize];
        }];
    }
}
- (void)refreshPullUp:(UIRefreshControl *)rc {
    [self reloadAllFolder];
    [self performSelector:@selector(endRefresh:) withObject:rc afterDelay:0.5];
}
- (void)endRefresh:(UIRefreshControl *)rc {
    [rc endRefreshing];
}
- (void)reloadAllFolder {
    NSArray *array = @[@{@"title":@"所有文件",@"type":@(10),@"loc":@(1)},@{@"title":@"所有视频",@"type":@(1),@"loc":@(1)},@{@"title":@"所有音频",@"type":@(2),@"loc":@(1)},@{@"title":@"所有图片",@"type":@(3),@"loc":@(1)},@{@"title":@"所有文档",@"type":@(4),@"loc":@(1)},];
    self.mainArray = [NSMutableArray arrayWithArray:array];
    NSArray *folderArray = [[XDFileManager defaultManager] foldersFromPath:nil];
    for (NSDictionary *dict in folderArray) {
        [self.moveArray addObject:dict[@"title"]];
        [self.mainArray addObject:dict];
    }
    [self.mainArray addObject:@{@"title":@"新建",@"type":@(5)}];
    [self.mainCollectionView reloadData];
}
- (void)leftBarButtonItemAction {
    DrawerViewController *drawerVC = (DrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [drawerVC openLeftMenu];
}
- (void)rightBarButtonItemAction:(UIBarButtonItem *)item {
    PopViewController *pop = [PopViewController returnFromStoryBoard];
    pop.modalPresentationStyle = UIModalPresentationPopover;
    pop.popoverPresentationController.barButtonItem = item;
    pop.popoverPresentationController.delegate = self;
    pop.popoverPresentationController.backgroundColor = kCOLOR(0xffffff, 0x333333);
    pop.preferredContentSize = CGSizeMake(150, 220);
    @weakify(self);
    pop.completeSelectBlock = ^(NSInteger index) {
        @strongify(self);
        switch (index) {
            case 0:
            {
                TransferIPViewController *transfer = [TransferIPViewController allocFromStoryBoard];
                [self.navigationController pushViewController:transfer animated:YES];
            }
                break;
            case 1:
            {
                FaceConnectController *transfer = [FaceConnectController allocFromStoryBoard];
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
//                XDPhotoViewController *picker = [[XDPhotoViewController alloc]init];
//                [XDPhotoViewController pickerPhotoWithMaxCount:0 complete:^(NSArray * _Nullable photoArray, XDPhotoStatus status) {
//
//                }];
//                [self.navigationController pushViewController:picker animated:YES];
            }
                break;
            case 3:
            {
                ScanViewController *transfer = [ScanViewController allocFromStoryBoard];
                [self.navigationController pushViewController:transfer animated:YES];
            }
                break;

            default:
            {
                SearchViewController *searchVC = [SearchViewController allocFromStoryBoard];
                [self.navigationController pushViewController:searchVC animated:YES];
            }
                break;
        }

    };
    [self presentViewController:pop animated:YES completion:^{

    }];

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
                            [moveData writeToFile:[KDocumentP stringByAppendingPathComponent:name] atomically:YES];
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
                        NSString *imagePath = [NSString stringWithFormat:@"%@/相册%d%@",KDocumentP,(int)self.nameNum,imageType];
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
            [XTOOLS showAlertTitle:@"完成" message:@"选择的资源已经导入到应用中，可以在文件列表中查看。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
            }];
        });
    });
}
#pragma mark -- collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mainArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FilesListCell *cell = [self.mainCollectionView dequeueReusableCellWithReuseIdentifier:@"homeblockcellid" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    NSDictionary *dict = self.mainArray[indexPath.row];
    @weakify(self);
    [cell setCellTitle:dict[@"title"] type:[dict[@"type"] integerValue] cellAction:^(NSIndexPath * _Nonnull index, NSInteger type) {
        @strongify(self);
        [self showPopListWithIndexPath:indexPath];
    }];
    return cell;
}
- (void)showPopListWithIndexPath:(NSIndexPath *)indexPath {
    FilesListCell *cell = (FilesListCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath];
    HomePopViewController *pickerArr = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePopViewController"];
    pickerArr.modalPresentationStyle = UIModalPresentationPopover;
    NSDictionary *fDict = self.mainArray[indexPath.row];
    if (indexPath.row < 5) {//自带的
        pickerArr.popItems = @[@{@"title":@"详情",@"type":@(6)}];
         pickerArr.preferredContentSize = CGSizeMake(100, 44);
    }
    else if ([[fDict objectForKey:@"type"]integerValue] == 5) {//新建
        pickerArr.popItems = @[@{@"title":@"普通文件夹",@"type":@(1),},@{@"title":@"视频文件夹",@"type":@(2)},@{@"title":@"音频文件夹",@"type":@(3)},@{@"title":@"图片文件夹",@"type":@(4)},@{@"title":@"文档文件夹",@"type":@(5)}];
        pickerArr.preferredContentSize = CGSizeMake(120, 220);
    }
    else {//其他
        pickerArr.popItems = @[@{@"title":@"重命名",@"type":@(8)},@{@"title":@"删除",@"type":@(7)},@{@"title":@"详情",@"type":@(6)}];
        pickerArr.preferredContentSize = CGSizeMake(100, 132);
    }
    
    pickerArr.popoverPresentationController.delegate = self;
    pickerArr.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    pickerArr.popoverPresentationController.sourceView = cell.headerImageView;
    pickerArr.popoverPresentationController.sourceRect =CGRectMake(0, 0, cell.headerImageView.bounds.size.width/2, cell.headerImageView.bounds.size.height/2);
    @weakify(self);
    pickerArr.pickerItemBlock = ^(NSNumber *num,NSString *str) {
        @strongify(self);
        [XTOOLS umEvent:@"longClick" label:str];
        if (num.integerValue < 6) {//新建文件
            [self createNewFolderWithType:num.integerValue - 1];
        }
        else if (num.integerValue == 6) {//详情
            [self detailFolderWithIndexPath:indexPath];
        }
        else
            if (num.integerValue == 7) {//删除
                [self deleteFolderWithIndexPath:indexPath];
            }
            else if(num.integerValue == 8){//重命名
                [self renameFolderWithIndexPath:indexPath];
            }
    };
    [self presentViewController:pickerArr animated:YES completion:^{
        
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = self.mainArray[indexPath.row];
    if ([dict[@"type"] integerValue] == 5) {//创建
        [self createNewFolderWithType:0];//点击直接创建为0
    }
    else if ([dict[@"type"] integerValue] == 10){//全部
        FilesListController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
        VC.title = dict[@"title"];
        VC.moveArray = self.moveArray;
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    else if ([dict[@"type"] integerValue] == 1){//视频
        VideoListController *VC = [VideoListController allocFromStoryBoard];
        VC.title = dict[@"title"];
        VC.moveArray = self.moveArray;
        if ([dict[@"loc"]intValue]!= 1) {
            VC.folderPath = [KDocumentP stringByAppendingPathComponent:dict[@"title"]];
        }
        [self.navigationController pushViewController:VC animated:YES];
    }
    else if ([dict[@"type"] integerValue] == 2){//音频
        FilesListController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
        VC.title = dict[@"title"];
        VC.moveArray = self.moveArray;
        VC.fileType = FileTypeAudio;
        if ([dict[@"loc"]intValue]!= 1) {
            VC.filePath = [KDocumentP stringByAppendingPathComponent:dict[@"title"]];
        }
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    else if ([dict[@"type"] integerValue] == 3){//图片
        XimageViewController *VC = [XimageViewController allocFromStoryBoard];
        VC.title = dict[@"title"];
        if ([dict[@"loc"]intValue]!= 1) {
            VC.folderPath = [KDocumentP stringByAppendingPathComponent:dict[@"title"]];
        }
        [self.navigationController pushViewController:VC animated:YES];
    }
    else if ([dict[@"type"] integerValue] == 4){//文档
        FilesListController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
        VC.title = dict[@"title"];
        VC.moveArray = self.moveArray;
        VC.fileType = FileTypeDocument;
        if ([dict[@"loc"]intValue]!= 1) {
            VC.filePath = [KDocumentP stringByAppendingPathComponent:dict[@"title"]];
        }
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    else
    {
        FilesListController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
        VC.moveArray = self.moveArray;
        VC.title = dict[@"title"];
        VC.fileType = FileTypeFolder;
        VC.filePath = [KDocumentP stringByAppendingPathComponent:dict[@"title"]];
        [self.navigationController pushViewController:VC animated:YES];
    }
}

//创建文件及
- (void)createNewFolderWithType:(NSInteger)type {
    @weakify(self);
    NSString *titleName = @"新建文件夹";
    if (type == 1) {
        titleName = @"新建视频文件夹";
    }
    else if (type == 2) {
       titleName = @"新建音频文件夹";
    }
    else if (type == 3) {
        titleName = @"新建图片文件夹";
    }
    else if (type == 4) {
        titleName = @"新建文档文件夹";
    }
    [XTOOLS showAlertTextField:nil placeholder:@"输入文件名称" title:titleName message:nil buttonTitles:@[@"取消",@"创建"] completionHandler:^(NSInteger num, NSString *textValue) {
        @strongify(self);
        if (num == 1) {
            NSString *folderName = textValue;
            BOOL fc = [[XDFileManager defaultManager]createNewFileName:folderName WithPrexPath:nil type:type];
            if (fc) {
                [XTOOLS showMessage:@"创建成功"];
                [self reloadAllFolder];
            }
            else {
                [XTOOLS showMessage:@"创建失败"];
            }
        }
    }];
}
- (void)renameFolderWithIndexPath:(NSIndexPath *)indexPath {
     NSDictionary *fDict = self.mainArray[indexPath.row];
    NSString *olderName = fDict[@"title"];
    NSInteger ftype = [fDict[@"type"]integerValue];
    @weakify(self);
    [XTOOLS showAlertTextField:olderName placeholder:@"输入新文件名称" title:@"重新命名" message:nil buttonTitles:@[@"取消",@"确定"] completionHandler:^(NSInteger num, NSString *textValue) {
        @strongify(self);
        if (num == 1) {
            if (textValue.length<=0) {
                [XTOOLS showMessage:@"名称不能为空"];
                return ;
            }
            if ([textValue isEqualToString:olderName]) {
                return;
            }
            NSString *olderPath = [KDocumentP stringByAppendingPathComponent:olderName];
            if ([kFileM fileExistsAtPath:olderPath]) {
                
                NSString *newPath = [KDocumentP stringByAppendingPathComponent:textValue];

                NSError *error = nil;
                [kFileM moveItemAtPath:olderPath toPath:newPath error:&error];
                if (error) {
                    [XTOOLS showMessage:@"修改失败"];
                }
                else
                {
                    [[XDFileManager defaultManager]deleteFolderTypeWithPath:olderName];
                    [[XDFileManager defaultManager]setFolderType:ftype WithPath:newPath];
                    [self reloadAllFolder];
                    [XTOOLS showMessage:@"修改成功"];
                }
            }
            else {
                [XTOOLS showMessage:@"文件不存在"];
            }
        }
    }];
}
- (void)deleteFolderWithIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *fDict = self.mainArray[indexPath.row];
    NSString *path = [KDocumentP stringByAppendingPathComponent:fDict[@"title"]];
    NSError *error;
   BOOL is = [kFileM removeItemAtPath:path error:&error];
    if (!is) {
        NSLog(@"==%@",error);
      [XTOOLS showMessage:@"删除失败"];
    }
    else {
        [[XDFileManager defaultManager]deleteFolderTypeWithPath:path];
        [self reloadAllFolder];
        [XTOOLS showMessage:@"删除成功"];
    }
}
- (void)detailFolderWithIndexPath:(NSIndexPath *)indexPath {
     NSDictionary *fDict = self.mainArray[indexPath.row];
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = fDict[@"title"];
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark -- UIPopoverPresentationControllerDelegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
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
