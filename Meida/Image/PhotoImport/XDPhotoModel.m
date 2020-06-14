//
//  XDPhotoModel.m
//  Wenjian
//
//  Created by XiaoDev on 2019/9/2.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPhotoModel.h"
#import <Photos/Photos.h>
@implementation XDPhotoAlbumModel

@end

@implementation XDPhotoAssetModel

+ (instancetype)modelWithAsset:(id)asset {
    XDPhotoAssetModel *model = [[XDPhotoAssetModel alloc]init];
    model.asset = asset;
    if ([model.asset isKindOfClass:[PHAsset class]]) {
        model.type = ((PHAsset *)model.asset).mediaType;
    }
    model.isSelected = NO;
    return model;
}

@end
