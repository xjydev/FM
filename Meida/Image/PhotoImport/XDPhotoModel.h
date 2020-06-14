//
//  XDPhotoModel.h
//  Wenjian
//
//  Created by XiaoDev on 2019/9/2.
//  Copyright © 2019 XiaoDev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,XDPhotoType) {
    XDPhotoTypeUnknown = 0,
    XDPhotoTypeImage,
    XDPhotoTypeVideo,
    XDPhotoTypeAudio,
};
@interface XDPhotoAlbumModel : NSObject
@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@end

@interface XDPhotoAssetModel : NSObject
@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign)XDPhotoType type;
@property (strong, nonatomic) UIImage *cachedImage;
+ (instancetype)modelWithAsset:(id)asset;

@end
NS_ASSUME_NONNULL_END
