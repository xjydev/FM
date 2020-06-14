//
//  XDPhotoBrowerCell.h
//  Wenjian
//
//  Created by XiaoDev on 2019/11/4.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDPhotoBrowerCell : UICollectionViewCell
- (void)setCellImage:(UIImage *)image;
- (void)setCellImagePath:(NSString *)path;
@property (nonatomic, copy)void (^singleTapBlock)(BOOL isBackDark);
@property (nonatomic, strong)UIImageView  *imageView;
@property (nonatomic, assign)BOOL isBackDark;

@end

NS_ASSUME_NONNULL_END
