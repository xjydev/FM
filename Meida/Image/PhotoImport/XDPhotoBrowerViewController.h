//
//  XDPhotoBrowerViewController.h
//  Wenjian
//
//  Created by XiaoDev on 2019/11/4.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XDPhotoBrowerDelegate <NSObject>

- (NSInteger)xdNumberOfAllPhotos;

@optional
- (UIImage *)xdPhotoAtIndex:(NSInteger)index;
- (UIImage *)xdThumbnailPhotoAtIndex:(NSInteger)index;
- (BOOL)xdPhotoSelectedAtIndex:(NSInteger)index;
- (NSString *)xdPhotoPahtAtIndex:(NSInteger)index;
- (void)xdDeletePhotoAtIndex:(NSInteger)index;
- (void)xdSelectedPhotoAtIndex:(NSInteger)index;
- (NSString *)xdTopTitleAtIndex:(NSInteger)index;
- (NSAttributedString *)xdTopAttributedTitleAtIndex:(NSInteger)index;

@end

@interface XDPhotoBrowerViewController : UIViewController

@property (nonatomic, weak)id<XDPhotoBrowerDelegate>delegate;

@property (nonatomic, strong)NSArray *imagesArray;
@property (nonatomic, assign)NSInteger currentIndex;
@end

NS_ASSUME_NONNULL_END
