//
//  XDPhotoAssetViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2019/9/2.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPhotoAssetViewController.h"
#import <Photos/Photos.h>
#import "XDPhotoModel.h"
#import "XDPhotoViewController.h"
#import "XTools.h"

#define  aCellId @"photoassetcellid"

typedef void (^XDPhotoAssetCellSelectHandler)(XDPhotoAssetModel *assetModel,UIButton *selectButton);
@interface XDPhotoAssetCell : UICollectionViewCell
@property (nonatomic, strong)XDPhotoAssetModel *model;
@property (nonatomic, strong)UIButton *selectButton;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIImageView *centerImageView;
- (void)setModel:(XDPhotoAssetModel *)model selectHandler:(XDPhotoAssetCellSelectHandler)handler;
@property (nonatomic, copy)XDPhotoAssetCellSelectHandler selectHandler;
@property (nonatomic, assign)BOOL isSelected;
@end

@implementation XDPhotoAssetCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = kDarkCOLOR(0xffffff);
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.centerImageView];
        [self.contentView addSubview:self.selectButton];
        
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.selectButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-27, 0, 27, 27);
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageView setImage:[UIImage imageNamed:@"photo_camera"]];
    }
    return _imageView;
}
- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _centerImageView.backgroundColor = [UIColor clearColor];
    }
    return _centerImageView;
}
- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"photo_unselect"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"photo_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}
- (void)selectButtonAction:(UIButton *)button {
    if (self.selectHandler) {
        self.selectHandler(self.model, button);
    }
}
- (void)setModel:(XDPhotoAssetModel *)model {
    _model = model;
    if (model) {
        switch (model.type) {
            case XDPhotoTypeVideo:
            {
                self.centerImageView.hidden = NO;
                [self.centerImageView setImage:[UIImage imageNamed:@"image_video"]];
            }
                break;
            case XDPhotoTypeAudio:
            {
                self.centerImageView.hidden = NO;
                [self.centerImageView setImage:[UIImage imageNamed:@"image_audio"]];
            }
                break;
            default:
                self.centerImageView.hidden = YES;
                break;
        }
        self.selectButton.hidden = NO;
        if (model.cachedImage) {
            [self.imageView setImage:model.cachedImage];
        }
        else {
            if ([model.asset isKindOfClass:[PHAsset class]]) {
                CGSize thuSize = CGSizeMake(200, 200);
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                // 同步获得图片, 只会返回1张图片
                options.synchronous = YES;
                options.networkAccessAllowed = NO;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:thuSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    model.cachedImage = result;
                    [self.imageView setImage:model.cachedImage];
                }];
            }
        }
    }
    else {
        [self.imageView setImage:[UIImage imageNamed:@"photo_camera"]];
        self.selectButton.hidden = YES;
        self.centerImageView.hidden = YES;
    }
}
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectButton.selected = isSelected;
}
- (void)setModel:(XDPhotoAssetModel *)model selectHandler:(XDPhotoAssetCellSelectHandler)handler {
    self.model = model;
    self.selectHandler = handler;
    
}
@end

@interface XDPhotoAssetViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong)NSMutableArray *mainArray;
@property (nonatomic, strong)NSMutableArray *selectedArray;
@property (nonatomic, strong)UICollectionView *mainCollectionView;
@property (nonatomic, strong)UIButton *previewButton;//预览
@property (nonatomic, strong)UIButton *completeButton;//完成
@property (nonatomic, strong)UIButton *allSelectButton;//全选
@property (nonatomic, assign)NSInteger maxCount;
@property (nonatomic, assign)NSInteger nameNum;
@end

@implementation XDPhotoAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView .contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.mainArray = [NSMutableArray array];
    self.selectedArray = [NSMutableArray arrayWithCapacity:9];
    self.title = self.albumModel.name;
    [self.view addSubview:self.mainCollectionView];
    [self getAlbumAsset];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarButtonAction)];
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(0, CGRectGetMaxY(self.mainCollectionView.frame), CGRectGetWidth(self.view.bounds), 1);
    line.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:line];
    
    [self.view addSubview:self.allSelectButton];
    [self.view addSubview:self.previewButton];
    [self.view addSubview:self.completeButton];
    
    XDPhotoViewController *photoVC = (XDPhotoViewController *)self.navigationController;
    self.maxCount = photoVC.maxCount;
}
- (void)cancelBarButtonAction {
    XDPhotoViewController *photoVC = (XDPhotoViewController *)self.navigationController;
    if (photoVC.photoCompleteHandler) {
        photoVC.photoCompleteHandler(nil, XDPhotoStatusCancel);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (UIButton *)completeButton {
    if (!_completeButton) {
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 90, CGRectGetMaxY(self.mainCollectionView.frame)+6, 78, 32);
        _completeButton.layer.cornerRadius = 3;
        _completeButton.layer.masksToBounds = YES;
        _completeButton.backgroundColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
        [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
        _completeButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeButton addTarget:self action:@selector(completeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}

#pragma mark -- 点击获取图片，
- (void)completeButtonAction:(UIButton *)button {//点击完成的时候，获取选中的图片大图
    if (self.selectedArray.count == 0) {
        [XTOOLS showMessage:@"请选择图片"];
        return;
    }
    if (self.maxCount == 0) {
        [XTOOLS showLoading:@"导入中"];
        _mainCollectionView.userInteractionEnabled = NO;
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_async(group, queue, ^{
            self.nameNum = [kUSerD integerForKey:@"userdNameNum"];
            for (int i=0;i< self.selectedArray.count;i++) {
                @autoreleasepool {
                    XDPhotoAssetModel *model = self.selectedArray[i];
                    PHAsset *phAsset = (PHAsset *)model.asset;

                    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
                        options.networkAccessAllowed = YES;
                        [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {

                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                NSURL *pathUrl = ((AVURLAsset *)asset).URL;
                                //                        asset.availableChapterLocales
                                NSString *name =[pathUrl.absoluteString lastPathComponent];
                                if (!name) {
                                    self.nameNum++;
                                    name =[NSString stringWithFormat:@"相册视频%d.mov",(int)self.nameNum];
                                }
                                NSError *error;
                                NSData *moveData = [NSData dataWithContentsOfURL:pathUrl];
                                int pa = 1;
                                NSString *pName = name;
                                while ([kFileM fileExistsAtPath:[KDocumentP stringByAppendingPathComponent:pName]]) {
                                    pName = [NSString stringWithFormat:@"%@(%d).%@",name.stringByDeletingPathExtension,pa,name.pathExtension];
                                    pa++;
                                }
                                name = pName;
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
                [XTOOLS showLoading:[NSString stringWithFormat:@"%d/%d",i,(int)self.selectedArray.count]];

            }
            //结束后就保存以前的相册名称序列，防止以后的重名，然后刷新。

            [self.selectedArray removeAllObjects];
            if (self.nameNum > 999999) {
                self.nameNum = 0;
            }
            [kUSerD setInteger:self.nameNum forKey:@"userdNameNum"];
            [kUSerD synchronize];
        });
        //完成后通知
        dispatch_group_notify(group, queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                XDPhotoViewController *photoVC = (XDPhotoViewController *)self.navigationController;
                if (photoVC.photoCompleteHandler) {
                    photoVC.photoCompleteHandler(nil, XDPhotoStatusComplete);
                }
                [XTOOLS hiddenLoading];
                [XTOOLS showAlertTitle:@"完成" message:@"选择的资源已经导入到应用中，可以在文件列表中查看。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{

                    }];
                }];
            });
        });
    }
    else {
        [XTOOLS showLoading:nil];
        //选中之后获取大图
        __block NSMutableArray *marr = [NSMutableArray arrayWithCapacity:self.selectedArray.count];
        for (XDPhotoAssetModel *model in self.selectedArray) {
            if ([model.asset isKindOfClass:[PHAsset class]]) {
                PHAsset *phAsset = model.asset;
                CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
                CGFloat pixelWidth = kScreen_Width * 4;
                // 超宽图片
                if (aspectRatio > 1.8) {
                    pixelWidth = pixelWidth * aspectRatio;
                }
                // 超高图片
                if (aspectRatio < 0.2) {
                    pixelWidth = pixelWidth * 0.5;
                }
                CGFloat pixelHeight = pixelWidth / aspectRatio;
                CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                // 同步获得图片, 只会返回1张图片
                options.synchronous = YES;
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                
                [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (result) {
                        NSData *imageData = UIImageJPEGRepresentation(result, 1);
                        if (imageData.length > 1024*1024) {
                            float compression = 1024.0*1024.0/imageData.length;
                            NSData *lData = UIImageJPEGRepresentation(result, compression);
                            NSLog(@"compress ==== %ld,%ld",imageData.length ,lData.length);
                            UIImage *im = [UIImage imageWithData:lData];
                            [marr addObject:im];
                        }
                        else {
                            [marr addObject:result];
                        }
                    }
                }];
            }
        }
        XDPhotoViewController *photoVC = (XDPhotoViewController *)self.navigationController;
        if (photoVC.photoCompleteHandler) {
            photoVC.photoCompleteHandler(marr, XDPhotoStatusComplete);
        }
        [XTOOLS hiddenLoading];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (UIButton *)allSelectButton {
    if (!_allSelectButton) {
        _allSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSelectButton.frame = CGRectMake(10, CGRectGetMaxY(self.mainCollectionView.frame)+6, 32, 32);
        [_allSelectButton setImage:[UIImage imageNamed:@"photo_unselect"] forState:UIControlStateNormal];
        [_allSelectButton setImage:[UIImage imageNamed:@"photo_selected"] forState:UIControlStateSelected];
        [_allSelectButton addTarget:self action:@selector(allSelectedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return  _allSelectButton;
}
- (void)allSelectedButtonAction:(UIButton *)button {
    
    if (self.selectedArray.count >= self.mainArray.count) {
        [self.selectedArray removeAllObjects];
        button.selected = NO;
    }
    else {
        [self.selectedArray removeAllObjects];
        [self.selectedArray addObjectsFromArray:self.mainArray];
        button.selected = YES;
    }
    [self.mainCollectionView reloadData];
    [self reloadBottomButton];
}
- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(50, CGRectGetMaxY(self.mainCollectionView.frame)+5, 50, 34);
        [_previewButton setTitleColor:kDarkCOLOR(0x000000) forState:UIControlStateNormal];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_previewButton addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}
- (void)previewButtonAction:(UIButton *)button {
    if (self.selectedArray.count > 0) {
        
    }
    else {
        [XTOOLS showMessage:@"请选择"];
    }
}
- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollPositionCenteredVertically;
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 2;
        layout.itemSize = CGSizeMake((kScreen_Width-12)/4, (kScreen_Width-12)/4);
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, KNavitionbarHeight, kScreen_Width, kScreen_Height - 44 - KBottomSafebarHeight - KNavitionbarHeight) collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = kDarkCOLOR(0xffffff);
        
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        [_mainCollectionView registerClass:[XDPhotoAssetCell class] forCellWithReuseIdentifier:aCellId];
    }
    return _mainCollectionView;
}
- (void)getAlbumAsset {
    [XTOOLS showLoading:nil];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([self.albumModel.result isKindOfClass:[PHFetchResult class]]) {
            PHFetchResult *fetchResult = (PHFetchResult *)self.albumModel.result;
            @strongify(self);
            [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XDPhotoAssetModel *model = [XDPhotoAssetModel modelWithAsset:obj];
                if (model) {
                    [self.mainArray addObject:model];
                }
            }];
            NSLog(@"%@",self.mainArray);
            dispatch_async(dispatch_get_main_queue(), ^{
                [XTOOLS hiddenLoading];
                [self.mainCollectionView reloadData];
                [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.mainArray.count inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            });
        }
    });
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.mainArray.count > 0) {//没有的时候显示空白界面。
        return 1;
    }
    return 0;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mainArray.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XDPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:aCellId forIndexPath:indexPath];
    if (indexPath.row < self.mainArray.count) {
        XDPhotoAssetModel *model = self.mainArray[indexPath.row];
        cell.isSelected =[self.selectedArray containsObject:model];
        @weakify(self)
        [cell setModel:model selectHandler:^(XDPhotoAssetModel *assetModel, UIButton *selectButton) {
            @strongify(self);
            [self selectOrUnSelectWithModel:assetModel selectButton:selectButton];
        }];
    }
    else {
        cell.model = nil;
    }
    
    return cell;
}

- (void)selectOrUnSelectWithModel:(XDPhotoAssetModel *)model selectButton:(UIButton *)selectButton {
    if ([self.selectedArray containsObject:model]) {
        [self.selectedArray removeObject:model];
        selectButton.selected = NO;
    }
    else {
        
        if (self.selectedArray.count >= self.maxCount && self.maxCount > 0) {
            [XTOOLS showMessage:[NSString stringWithFormat:@"最多选择%d张",(int)self.maxCount]];
            return;
        }
        else {
            [self.selectedArray addObject:model];
            selectButton.selected = YES;
        }
    }
    [self reloadBottomButton];
}
- (void)reloadBottomButton {
  [self.completeButton setTitle:[NSString stringWithFormat:@"完成(%d)",(int)self.selectedArray.count] forState:UIControlStateNormal];
    self.allSelectButton.selected = (self.selectedArray.count == self.mainArray.count);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.mainArray.count) {//拍照
        [self checkOpenCamera];
    }
    else {
        XDPhotoAssetCell *cell = (XDPhotoAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
       XDPhotoAssetModel *model = self.mainArray[indexPath.row];
        [self selectOrUnSelectWithModel:model selectButton:cell.selectButton];
    }
}
#pragma mark -- 拍照
- (void)checkOpenCamera {
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        // 无权限
        UIAlertController *alertc = [UIAlertController alertControllerWithTitle:@"没有权限" message:@"没有访问相机的权限，您可以去设置中设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }];
        [alertc addAction:sureAction];
        [alertc addAction:cancelA];
        
        [self.parentViewController presentViewController:alertc animated:YES completion:^{
            
        }];
    } else {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *alertc = [UIAlertController alertControllerWithTitle:@"设备无法访问相机" message:@"无法访问到设备的相机，请检查设备摄像头" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                
            }];
            [alertc addAction:sureAction];
            [alertc addAction:cancelA];
            [self presentViewController:alertc animated:YES completion:^{
            }];
        }
        else {
            [self gotoOpenCamera];
        }
    }
}
- (void)gotoOpenCamera {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    });
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"pick ==%@",info);
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        XDPhotoViewController *photoVC = (XDPhotoViewController *)self.navigationController;
        if (photoVC.photoCompleteHandler) {
            photoVC.photoCompleteHandler(@[image], XDPhotoStatusComplete);
        }
        [picker dismissViewControllerAnimated:NO completion:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    } 
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- MWPhotoBrowserDelegate

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
@end
