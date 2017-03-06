//
//  PhotoImportCollectionCell.m
//  FileManager
//
//  Created by xiaodev on Feb/10/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "PhotoImportCollectionCell.h"

@implementation PhotoImportCollectionCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectImageView.layer.cornerRadius = 12.0f;
    self.selectImageView.layer.masksToBounds = YES;
    self.selectImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectImageView.layer.borderWidth = 1.0f;
    self.selectImageView.hidden = YES;
    
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
    
    if (image.size.height>image.size.width) {
       CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, (image.size.height-image.size.width)/2*image.scale, image.size.width*image.scale, image.size.width*image.scale));
        [self.imageView setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
    }
    else
        if (image.size.width>image.size.height) {
         CGImageRef  imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake((image.size.width-image.size.height)/2*image.scale, 0, image.size.height*image.scale, image.size.height*image.scale));
            UIImage *viewImage =[UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            [self.imageView setImage:viewImage];
            
        }
    else
    {
        [self.imageView setImage:image];
    }
    
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
@end
