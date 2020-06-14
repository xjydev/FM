//
//  PhotoImportCollectionCell.m
//  FileManager
//
//  Created by xiaodev on Feb/10/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "PhotoImportCollectionCell.h"
#import <SDWebImage/SDImageCache.h>
#import "XTools.h"
@implementation PhotoImportCollectionCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectImageView.layer.cornerRadius = 12.0f;
    self.selectImageView.layer.masksToBounds = YES;
    self.selectImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectImageView.layer.borderWidth = 1.0f;
    self.selectImageView.hidden = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    
}
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectImageView.hidden = !_isSelected;
    if (isSelected) {
        self.frontImageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    }
    else
    {
        self.frontImageView.backgroundColor = [UIColor clearColor];
    }
}
- (void)setCenterImage:(UIImage *)image withType:(NSInteger)type{
      [self.imageView setImage:image];

    switch (type) {
        case 0:
        case 1:
        {
            self.frontImageView.image =nil;
        }
            break;
        case 2://视频
        {
            [self.frontImageView setImage:[UIImage imageNamed:@"image_video"]];
        }
            break;
        case 3://音频
        {
            [self.frontImageView setImage:[UIImage imageNamed:@"image_audio"]];
        }
            break;
            
        default:
            break;
    }
}
- (void)setCenterImagePath:(NSString *)imagePath {
    self.imageView.image = nil;
    NSString *pathlast = kSubDokument(imagePath);
    
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:pathlast]) {
        self.imageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:pathlast];
    }
    else
    {
        self.imageView.image = nil;
        dispatch_queue_t queue = dispatch_queue_create("cn.xiaodev", DISPATCH_QUEUE_SERIAL); dispatch_async(queue, ^{
            @autoreleasepool {
                @try {
                    UIImage * limage = nil;
                    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
                    if (imageData.length > 1024*1024) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage * dimage = [self compressLargeImage:[UIImage imageWithData:imageData]];
                            [[SDImageCache sharedImageCache]storeImage:dimage forKey:pathlast toDisk:YES completion:^{
                                
                            }];
                            [self.imageView setImage:dimage];
                        });
                    }
                    else
                    {
                        if (imageData.length > 1024*100) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            imageData = UIImageJPEGRepresentation(image, 0.05);
                        }
                        limage = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[SDImageCache sharedImageCache]storeImage:limage forKey:pathlast toDisk:YES completion:^{
                                
                            }];
                            [self.imageView setImage:limage];
                        });
                    }
                    
                } @finally {
                    
                }
            }
        });
    }
    self.frontImageView.image =nil;
}
- (void)cellIndex:(NSIndexPath *)index addLongPressGesAction:(CellAddLongPressGesAction)longPressAction {
    if (!_longPressGes) {
        _longPressGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesAction:)];
        [self addGestureRecognizer:_longPressGes];
    }
    self.cellLongPressGesBlock = longPressAction;
    _index = index;
}
- (void)longPressGesAction:(UILongPressGestureRecognizer *)longPressGes {
    
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        
        if (self.cellLongPressGesBlock) {
            self.cellLongPressGesBlock(_index);
        }
    }
    
}
- (UIImage *)compressLargeImage:(UIImage *)largeImage {
    if (largeImage.size.width== 0) {
        return nil;
    }
    CGSize size = CGSizeMake(kScreen_Width, largeImage.size.height/largeImage.size.width*kScreen_Width);
    UIGraphicsBeginImageContext(size);
    [largeImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
@end
