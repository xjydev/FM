//
//  XimageViewController.m
//  FileManager
//
//  Created by xiaodev on Dec/10/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XimageViewController.h"
#import <SDWebImage/SDImageCache.h>
#import "MoveFilesView.h"
#import "ZipArchive.h"
#import "UIView+xiao.h"
#import "XManageCoreData.h"
#import "FileDetailController.h"
#import "XTools.h"
#import "PhotoImportCollectionCell.h"
#import "SingliImageController.h"
#import "XDPhotoBrowerViewController.h"
@interface XimageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ZipArchiveDelegate,UIPopoverPresentationControllerDelegate,XDPhotoBrowerDelegate>
{
//    NSMutableArray   *_allFilesArray;//本地种类的数据。
    NSMutableArray   *_filesArray;
//    NSMutableArray   *_imagesArray;
    UIBarButtonItem  *_rightBarButton;
    BOOL              _isEditing;
    BOOL              _isCompress;
    CGFloat               _cellWidth;
    __weak IBOutlet UIButton *_allSelectButton;
}
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (nonatomic, strong)NSMutableArray   *zipArray;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong)ZipArchive  *zipArchive;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;

@end

@implementation XimageViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    XimageViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"XimageViewController"];
    return VC;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
 self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //下面空一像素的线
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.mainCollectionView setCollectionViewLayout:layout animated:YES];
    _cellWidth = self.view.bounds.size.width/4;
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    [self bottomButtonCanSelect:NO];
    [self reloadFilesArray];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.mainCollectionView addSubview:refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadFilesArray) name:kRefreshList object:nil];
    
}
- (void)reloadFilesArray {
    NSError *error;
    if (self.folderPath.length == 0) {
        self.folderPath = KDocumentP;
    }
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.folderPath error:&error];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
        return (NSComparisonResult)[obj1 compare:obj2 options:comparisonOptions];
        
    }];
    [_filesArray removeAllObjects];
    for (NSString *name in marry) {
        if ([XTOOLS fileFormatWithPath:name] == FileTypeImage) {
            if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
                NSString *nPath = name;
                if (![nPath hasPrefix:self.folderPath]) {
                    nPath = [self.folderPath stringByAppendingPathComponent:nPath];
                }
                [_filesArray addObject:nPath];
            }
        }
    }
    
    [self reloadNoDataView];
    [self.mainCollectionView reloadData];
}
- (void)reloadNoDataView {
    if (_filesArray.count !=0) {
        [self.mainCollectionView xRemoveNoData];
    }
    else
    {
        NSString *noFileStr = NSLocalizedString(@"NOpictures", nil);;
        [self.mainCollectionView xNoDataThisViewTitle:noFileStr centerY:198];
    }
    
}
- (void)leftGoBackButtonAction:(UIBarButtonItem *)bar {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBarButtonAction:(UIBarButtonItem *)bar {
    if (_isEditing) {
        _isEditing = NO;
        self.bottomView.hidden = YES;
        self.mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_rightBarButton setTitle:@"选择"];
        self.title = NSLocalizedString(@"Image", nil);
    }
    else
    {
        _isEditing = YES;
        self.bottomView.hidden = NO;
        self.mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        [_rightBarButton setTitle:NSLocalizedString(@"Cancel", nil)];
        self.title = [NSString stringWithFormat:@"已选择%d项",(int)self.zipArray.count];
        [self showBottomSelectNum:self.zipArray.count];
        [self showBottomSelectNum:self.zipArray.count];
        if (self.zipArray.count>=1) {
            [self bottomButtonCanSelect:YES];
        }
        else
            if(self.zipArray.count==0)
            {
                [self bottomButtonCanSelect:NO];
                
            }
    }
    [self.mainCollectionView reloadData];
//    [self.mainTableView setEditing:_isEditing animated:YES];
    
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _filesArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoImportCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoImportcollectcell" forIndexPath:indexPath];
    NSString *pathName = _filesArray[indexPath.row];
    NSString *imagePath = pathName;
    if (![imagePath hasPrefix:self.folderPath]) {
        imagePath = [self.folderPath stringByAppendingPathComponent:imagePath];
    }
    if (_isEditing) {
      cell.isSelected = [self.zipArray containsObject:pathName];
        [cell setCenterImagePath:imagePath];
    }
    else
    {
        [cell cellIndex:indexPath addLongPressGesAction:^(NSIndexPath *index) {
            NSLog(@"==%@",index);
            [self showSingleImageWith:cell.contentView index:indexPath.row];
        }];
        [cell setCenterImagePath:imagePath];
        cell.isSelected = NO;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_cellWidth, _cellWidth);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEditing) {
        PhotoImportCollectionCell *cell = (PhotoImportCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSString *pathName = _filesArray[indexPath.row];
        
        if ([self.zipArray containsObject:pathName]) {
            [self.zipArray removeObject:pathName];
            cell.isSelected = NO;
        }
        else
        {
            [self.zipArray addObject:pathName];
            cell.isSelected = YES;
        }
        self.title = [NSString stringWithFormat:@"已选择%d项",(int)self.zipArray.count];
        [self showBottomSelectNum:self.zipArray.count];
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
    }
    else
    {
        XDPhotoBrowerViewController *browser = [[XDPhotoBrowerViewController alloc]init];
        browser.delegate = self;
        browser.currentIndex = indexPath.row;
//        [browser setCurrentPhotoIndex:indexPath.row ];
        [self.navigationController pushViewController:browser animated:YES];
    }
    
}
#pragma mark -- xdphotoBrower
- (NSInteger)xdNumberOfAllPhotos {
    return _filesArray.count;
}
- (UIImage *)xdThumbnailPhotoAtIndex:(NSInteger)index {
    if (index < _filesArray.count) {
        NSString *pathName = _filesArray[index];
        NSString *imagePath = pathName;
        if (![imagePath hasPrefix:self.folderPath]) {
            imagePath = [self.folderPath stringByAppendingPathComponent:imagePath];
        }
        NSString *pathlast = kSubDokument(imagePath);
        if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:pathlast]) {
            return [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:pathlast];
        }
    }
    return nil;
}
- (NSString *)xdTopTitleAtIndex:(NSInteger)index {
    if (index < _filesArray.count) {
        NSString *pathName = _filesArray[index];
        return pathName.lastPathComponent;
    }
    return nil;
}
- (NSString *)xdPhotoPahtAtIndex:(NSInteger)index {
   if (index < _filesArray.count) {
        NSString *pathName = _filesArray[index];
        NSString *imagePath = pathName;
        if (![imagePath hasPrefix:self.folderPath]) {
            imagePath = [self.folderPath stringByAppendingPathComponent:imagePath];
        }
       return imagePath;
    }
    return nil;
}
- (void)showSingleImageWith:(UIView *)view index:(NSInteger)index{
    SingliImageController *setV = [SingliImageController viewControllerFromeStoryBoard];
    setV.modalPresentationStyle = UIModalPresentationPopover;
    setV.preferredContentSize = CGSizeMake(80, 135);
    setV.popoverPresentationController.sourceView = view;
    setV.popoverPresentationController.sourceRect = CGRectMake(view.center.x, view.center.y, 10, 10);
//    setV.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    setV.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    setV.popoverPresentationController.delegate = self;
    setV.index = index;
    setV.selectedBack = ^(NSInteger index, NSInteger type) {
        NSString *fpath = self->_filesArray[index];
        if (![fpath hasPrefix:self.folderPath]) {
            fpath = [self.folderPath stringByAppendingPathComponent:fpath];
        }
        switch (type) {
            case 0:
                {
                    [self gotoDetail:fpath];
                }
                break;
            case 1:
            {
                NSError *error = nil;
                
                NSString *path = fpath;
                if (![path hasPrefix:self.folderPath]) {
                   path = [self.folderPath stringByAppendingPathComponent:fpath];
                }
                
                [kFileM removeItemAtPath:path error:&error];
                [[XManageCoreData manageCoreData]deleteRecordPath:path];
                if (error) {
                    NSLog(@"==%@",error);
                }
                NSLog(@"点击删除");
                [self->_filesArray removeObjectAtIndex:index];
                [self reloadNoDataView];
                [self.mainCollectionView reloadData];
            }
                break;
            case 2:
            {
                MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
                
                [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
                    NSError *error = nil;
                    NSString *path =fpath;
                    if (![fpath hasPrefix:self.folderPath]) {
                       path = [self.folderPath stringByAppendingPathComponent:fpath];
                    }
                    
                    //            [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
                    
                    NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
                    //            [NSString stringWithFormat:@"%@/%@",movePath,path.lastPathComponent];
                    if ([kFileM moveItemAtPath:path toPath:toPath error:&error]) {
                        [XTOOLS showMessage:@"转移成功"];
                        [self.mainCollectionView reloadData];
                    }
                    else{
                        [XTOOLS showMessage:@"转移失败"];
                        NSLog(@"error == %@",error);
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    };
    [self presentViewController:setV animated:YES completion:^{
        
    }];
}
- (void)gotoDetail:(NSString *)path {
    NSString *detailPath = path;
    if (![path hasPrefix:self.folderPath]) {
        detailPath = [self.folderPath stringByAppendingPathComponent:path];
    }
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = detailPath;
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark -- UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}
#pragma mark --底部按钮
- (void)bottomButtonCanSelect:(BOOL)isCan {
   
    for (NSInteger i = 501; i<504; i++) {
        UIButton *button = [self.bottomView viewWithTag:i];
        if (button.enabled == isCan) {
            return;
        }
        button.enabled = isCan;
    }
   
}
- (void)showBottomSelectNum:(NSInteger)num {
    NSString *numstr = [NSString stringWithFormat:@"%@",@(num)];
    NSMutableAttributedString *sAttri = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@/%@",numstr,@(_filesArray.count)]];
    [sAttri setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, numstr.length+1)];
    _selectLabel.attributedText = sAttri;
}
- (IBAction)compressButtonAction:(id)sender {

    [self compressToZip];
}
- (IBAction)allSelectButtonAction:(UIButton *)sender {
    if (self.zipArray.count != _filesArray.count) {
        self.zipArray = [NSMutableArray arrayWithArray:_filesArray];
        sender.selected = YES;
        [self bottomButtonCanSelect:YES];
    }
    else
    {
        [self.zipArray removeAllObjects];
        sender.selected = NO;
        [self bottomButtonCanSelect:NO];
    }
    self.title = [NSString stringWithFormat:@"已选择%d项",(int)self.zipArray.count];
    [self showBottomSelectNum:self.zipArray.count];
    [self.mainCollectionView reloadData];
}
//转移按钮
- (IBAction)moveButtonAction:(id)sender {
    MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
    
    [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
        for (NSString *name in self.zipArray) {
            NSString * path = name;
            if (![name hasPrefix: self.folderPath]) {
               path = [self.folderPath stringByAppendingPathComponent:name];
            }
            NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
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
        [mstr appendString:name.lastPathComponent];
        [mstr appendString:@"\n"];
    }
    [mstr appendFormat:@"删除以上%@个文件",@(self.zipArray.count)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除文件" message:mstr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (NSString *s in self.zipArray) {
            NSString *path =s;
            if (![path hasPrefix:self.folderPath]) {
                path = [self.folderPath stringByAppendingPathComponent:path];
            }
            [kFileM removeItemAtPath:path error:nil];
            [[XManageCoreData manageCoreData]deleteRecordPath:path];
            [self->_filesArray removeObject:s];
            
        }
        [self reloadFilesArray];
        
    }];
    [alert addAction:cancleAction];
    [alert addAction:unzipAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
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
        [XTOOLS showLoading:@"压缩中"];
        NSString *zipName = textField.text;
        if (zipName.length<=0) {
            zipName = @"压缩";
        }
        NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip",self.folderPath,zipName];
        [self.zipArchive CreateZipFile2:zipPath];
        for (NSString *name in self.zipArray) {
            NSString *path = name;
            if ([path hasPrefix:self.folderPath]) {
                path = [self.folderPath stringByAppendingPathComponent:name];
            }
            //            [NSString stringWithFormat:@"%@/%@",self.filePath,name];
            [self.zipArchive addFileToZip:path newname:path.lastPathComponent];
        }
        [XTOOLS hiddenLoading];
        if ([self.zipArchive CloseZipFile2]) {
            [XTOOLS showMessage:@"压缩成功"];
//            [self reloadFilesArray];
            
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

#pragma mark -- MWPhotoBrowserDelegate
//- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
//    return _filesArray.count;
//}
//
//- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
//    if (index < _filesArray.count) {
//
//        NSString *pathName = _filesArray[index];
//        NSString *imagePath = pathName;
//        if (![imagePath hasPrefix:self.folderPath]) {
//            imagePath = [self.folderPath stringByAppendingPathComponent:imagePath];
//        }
//        return [MWPhoto photoWithURL:[NSURL fileURLWithPath:imagePath]];
//    }
//    return nil;
//}
//- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
//    if (index < _filesArray.count) {
//        NSString *pathName = _filesArray[index];
//        NSString *imagePath = pathName;
//        if ([imagePath hasPrefix:self.folderPath]) {
//            imagePath = [imagePath substringFromIndex:self.folderPath.length];
//        }
//        return [MWPhoto photoWithImage:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath]];
//    }
//    return nil;
//}
//- (NSAttributedString *)photoBrowser:(MWPhotoBrowser *)photoBrowser attriTitleForPhotoAtIndex:(NSUInteger)index {
//    if (index < _filesArray.count) {
//        NSString *pstr =_filesArray[index];
//        NSString *indexStr =[NSString stringWithFormat:@"%@ / %@",@(index+1),@(_filesArray.count)];
//        NSString *titleStr =[NSString stringWithFormat:@"%@\n%@",indexStr,pstr.lastPathComponent];
//        NSMutableAttributedString *mattri = [[NSMutableAttributedString alloc]initWithString:titleStr];
//        [mattri setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(indexStr.length+1, titleStr.length - indexStr.length-1)];
//        return mattri;
//    }
//    return nil;
//
//}
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
