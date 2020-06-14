//
//  XDPhotoViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2019/9/2.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPhotoViewController.h"
#import "XDPhotoAlbumViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface XDPhotoViewController ()
@property (nonatomic, strong)XDPhotoAlbumViewController *albumVC;
@end

@implementation XDPhotoViewController

+ (void)pickerPhotoWithMaxCount:(NSInteger)max complete:(PhotoComplete)completeHanlder {
    [self pickerPhotoWithSelectedArray:nil max:max complete:completeHanlder];
}
+ (void)pickerPhotoWithSelectedArray:(nullable NSArray *)selectedArray max:(NSInteger)max complete:(PhotoComplete)completeHanlder {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            UIAlertController *alertc = [UIAlertController alertControllerWithTitle:@"没有权限" message:@"没有访问相册的权限，您可以去设置中设置" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                
            }];
            [alertc addAction:sureAction];
            [alertc addAction:cancelA];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertc animated:YES completion:^{
                
            }];
        }
        else {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIAlertController *alertc = [UIAlertController alertControllerWithTitle:@"设备无法打开相册" message:@"无法访问相册，您可以去设置中设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    
                }];
                [alertc addAction:sureAction];
                [alertc addAction:cancelA];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertc animated:YES completion:^{
                    
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XDPhotoViewController *photoVC = [[XDPhotoViewController alloc]init];
                    photoVC.photoCompleteHandler = completeHanlder;
                    photoVC.maxCount = max;
                    photoVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:photoVC animated:YES completion:nil];
                });
            }
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumVC = [[XDPhotoAlbumViewController alloc]init];
    [self pushViewController:self.albumVC animated:YES];
    [self getAllCameraRollAlbum];
}
- (void)getAllCameraRollAlbum {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *albumArr = [NSMutableArray array];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
//        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        // 我的照片流 1.6.10重新加入..
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
        for (PHFetchResult *fetchResult in allAlbums) {
            NSLog(@"fetch == %@ == %@",@(fetchResult.count),@(allAlbums.count));
            for (PHAssetCollection *collection in fetchResult) {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if ([collection isKindOfClass:[PHAssetCollection class]] && collection.assetCollectionSubtype != 1000000201) {//过滤『最近删除』相册
                    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                    NSLog(@"collection == %@",collection.localizedTitle);
                    if (fetchResult.count > 0) {
                        if ([self isCameraRollAlbum:collection]) {
                            [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:YES needFetchAssets:NO] atIndex:0];
                        } else {
                            [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO needFetchAssets:NO]];
                        }
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albumVC.albumArray = albumArr;
        });
    });
}
- (BOOL)isCameraRollAlbum:(id)metadata {
    if ([metadata isKindOfClass:[PHAssetCollection class]]) {
        NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (versionStr.length <= 1) {
            versionStr = [versionStr stringByAppendingString:@"00"];
        } else if (versionStr.length <= 2) {
            versionStr = [versionStr stringByAppendingString:@"0"];
        }
        CGFloat version = versionStr.floatValue;
        // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
        if (version >= 800 && version <= 802) {
            return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
        } else {
            return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
        }
    }
    if ([metadata isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = metadata;
        return ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos);
    }
    
    return NO;
}
- (XDPhotoAlbumModel *)modelWithResult:(id)result name:(NSString *)name isCameraRoll:(BOOL)isCameraRoll needFetchAssets:(BOOL)needFetchAssets {
    XDPhotoAlbumModel *model = [[XDPhotoAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        model.count = [group numberOfAssets];
    }
    return model;
}

@end
