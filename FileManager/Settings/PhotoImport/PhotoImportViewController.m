//
//  PhotoImportViewController.m
//  FileManager
//
//  Created by xiaodev on Feb/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "PhotoImportViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoImportCollectionCell.h"
#import <Photos/Photos.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "XTools.h"
@interface PhotoImportViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MWPhotoBrowserDelegate>
{
    NSMutableArray       *_libraryImagesArray;
    __weak IBOutlet UICollectionView *_mainCollectionView;
    CGFloat               _cellWidth;
    __weak IBOutlet UILabel *_selectedLabel;
    NSMutableArray          *_selectedArray;
    NSInteger                      _nameNum;
}
@end

@implementation PhotoImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相册导入";
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"导入" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    _selectedArray = [NSMutableArray arrayWithCapacity:10];
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //下面空一像素的线
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_mainCollectionView setCollectionViewLayout:layout animated:YES];
    _cellWidth = self.view.bounds.size.width/4;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status)
        {
            case PHAuthorizationStatusNotDetermined:
            {
                
            }
                break;
            case PHAuthorizationStatusRestricted:
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已锁定访问相册权限" message:@"家长控制已锁定悦览播放器访问相册的权限，如若访问，请获取家长控制权限。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }];
                [alert addAction:sureAction];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            }
                break;
            case PHAuthorizationStatusDenied:
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未打开访问相册权限" message:@"您未打开悦览播放器访问相册的权限，你可以在设置中打开。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    
                }];
                [alert addAction:cancleAction];
                [alert addAction:sureAction];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
                
            }
                break;
            case PHAuthorizationStatusAuthorized:
            {
                // 用户已经授权使用
                
            }
                break;
        }

    }];
    [self getLibraryImageArray];
}
#pragma mark -- 获取相册信息。
- (void)getLibraryImageArray {
    _libraryImagesArray = [NSMutableArray arrayWithCapacity:0];
    [XTOOLS showLoading:@"正在加载"];
    // 获得所有的自定义相簿
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        // 遍历所有的自定义相簿
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:YES];
        }
        
        // 获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        // 遍历相机胶卷,获取大图
        NSLog(@"视频==%@",cameraRoll.localizedTitle);
        [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
    });

    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [XTOOLS hiddenLoading];
            [_mainCollectionView reloadData];
        });
    });
    
    
}
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
  
        //缩略图
        CGSize thuSize = CGSizeMake(200, 200);
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:thuSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [dict setValue:result forKey:@"Thumbnails"];
            [dict setValue:asset forKey:@"asset"];
            NSLog(@"sub ==%@ == %@",info, result);
        }];
        [_libraryImagesArray addObject:dict];
    }
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _libraryImagesArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoImportCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoImportcollectcell" forIndexPath:indexPath];
    NSDictionary *dict = _libraryImagesArray[indexPath.row];
    PHAsset *asset = dict[@"asset"];
    [cell setCenterImage:dict[@"Thumbnails"]withType:asset.mediaType];
    cell.isSelected = [_selectedArray containsObject:asset];
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
//    if (_selectedArray.count<10) {
        PhotoImportCollectionCell *cell = (PhotoImportCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSDictionary *dict = _libraryImagesArray[indexPath.row];
        PHAsset *asset = [dict objectForKey:@"asset"];
        if ([_selectedArray containsObject:asset]) {
            [_selectedArray removeObject:asset];
            cell.isSelected = NO;
        }
        else
        {
            [_selectedArray addObject:asset];
            cell.isSelected = YES;
        }
        _selectedLabel.text = [NSString stringWithFormat:@"已选择%d项",(int)_selectedArray.count];
//    }
//    else
//    {
//        [XTOOLS showMessage:@"最多选择10项"];
//    }
    
}
- (void)rightBarButtonAction:(UIBarButtonItem *)bar {
    if (_selectedArray.count>0) {
        [self writeToDocument];
    }
    else
    {
        [XTOOLS showMessage:@"选择为空"];
    }
}
- (IBAction)previewButtonAction:(id)sender {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    
    [self.navigationController pushViewController:browser animated:YES];
    
}
- (IBAction)allSelectButtonAction:(UIButton *)sender {
    if (_selectedArray.count == _libraryImagesArray.count) {
        [_selectedArray removeAllObjects];
        [sender setTitle:@"全选" forState:UIControlStateNormal];
    }
    else
    {
        [_selectedArray removeAllObjects];
        for (NSDictionary* dict in _libraryImagesArray) {
        
            [_selectedArray addObject:dict[@"asset"]];
        }
       [sender setTitle:@"全部取消" forState:UIControlStateNormal];
    }
    [_mainCollectionView reloadData];
}
//写入到应用中
- (void)writeToDocument {
    [XTOOLS showLoading:@"导入中"];
    _mainCollectionView.userInteractionEnabled = NO;

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
     _nameNum = [kUSerD integerForKey:@"userdNameNum"];
        
        for ( int i=0;i< _selectedArray.count;i++) {
            
            @autoreleasepool {
                PHAsset *phAsset = _selectedArray[i];
                
                if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
                    options.networkAccessAllowed = YES;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                        
                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            NSURL *pathUrl = ((AVURLAsset *)asset).URL;
                            //                        asset.availableChapterLocales
                            NSString *name =[pathUrl.absoluteString lastPathComponent];
                            if (!name) {
                                _nameNum++;
                                name =[NSString stringWithFormat:@"相册视频%d.mov",(int)_nameNum];
                            }
                            NSError *error;
                            NSData *moveData = [NSData dataWithContentsOfURL:pathUrl];
                            [moveData writeToFile:[NSString stringWithFormat:@"%@/%@",KDocumentP,name] atomically:YES];
                            moveData = nil;
                            
                            if(error){
                                NSLog(@"error == %@",error);
                            }
                            
                            
                        } else {
                            
                        }
                        
                    }];
                    
                    
                }
                else
                {
                    
                    
                    PHImageRequestOptions *options = [PHImageRequestOptions new];
                    options.networkAccessAllowed = YES;
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    options.synchronous = YES;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithDouble: progress], @"progress",
                                              self, @"photo", nil];
                        NSLog(@"progress == %@",dict);
                        
                    };
                    
                    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                        NSData *imageData ;
                        NSString *imageType;
                        if (UIImagePNGRepresentation(result)) {
                            imageData = UIImagePNGRepresentation(result);
                            imageType = @".png";
                        }
                        else
                        {
                            imageData = UIImageJPEGRepresentation(result, 1.0);
                            imageType = @".jpg";
                        }
                        _nameNum++;
                        NSString *imagePath = [NSString stringWithFormat:@"%@/相册%d%@",KDocumentP,(int)_nameNum,imageType];
                        [imageData writeToFile:imagePath  atomically:YES];
                        imageData = nil;
                    }];
                    
                }
   
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [XTOOLS showLoading:[NSString stringWithFormat:@"%d/%d",i,(int)_selectedArray.count]];
            });
            }
        //结束后就保存以前的相册名称序列，防止以后的重名，然后刷新。
        
        [_selectedArray removeAllObjects];
        if (_nameNum > 999999) {
            _nameNum = 0;
        }
        [kUSerD setInteger:_nameNum forKey:@"userdNameNum"];
        [kUSerD synchronize];

    });
    
    //完成后通知
    dispatch_group_notify(group, queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            
            [XTOOLS hiddenLoading];
            [XTOOLS showAlertTitle:@"完成" message:@"选择的资源已经导入到应用中，可以在文件列表中查看。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
                
            }];
            
            if (_mainCollectionView) {
                _mainCollectionView.userInteractionEnabled = YES;
                [_mainCollectionView reloadData];
                _selectedLabel.text = @"已选择（0）";
            }
        });
    });

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _selectedArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _selectedArray.count) {
        // 从asset中获得原图图片
        PHAsset *pHasset = _selectedArray[index];
       
       MWPhoto* photo = [MWPhoto photoWithAsset:pHasset targetSize:CGSizeMake(pHasset.pixelWidth, pHasset.pixelHeight)];
        return photo;
    }
    return nil;
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
