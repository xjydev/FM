//
//  XDPhotoBrowerCell.m
//  Wenjian
//
//  Created by XiaoDev on 2019/11/4.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPhotoBrowerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "XTools.h"
@interface XDPhotoBrowerCell ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
@property (nonatomic, strong)UIScrollView *backScrollView;
@property (nonatomic, copy)NSString *path;

@end

@implementation XDPhotoBrowerCell
- (void)setCellImage:(UIImage *)image {
    [self.backScrollView setZoomScale:1.0 animated:NO];
    CGFloat contentHeight = CGRectGetHeight(self.backScrollView.frame);
    CGFloat contentWidth = CGRectGetWidth(self.backScrollView.frame);
    CGFloat originx = 0;
    CGFloat originy = 0;
    float newScale = 2.5;
    if (image.size.width > 0 && image.size.height > 0) {
        if (image.size.width < CGRectGetWidth(self.backScrollView.frame) && image.size.height < CGRectGetHeight(self.backScrollView.frame)) {
            contentWidth = image.size.width;
            contentHeight = image.size.height;
        }
        else {
            if (image.size.height / image.size.width > CGRectGetHeight(self.backScrollView.frame) / CGRectGetWidth(self.backScrollView.frame)) {
                contentHeight = CGRectGetHeight(self.backScrollView.frame);
                contentWidth = contentHeight/image.size.height*image.size.width;
                newScale = image.size.height/contentHeight;
                
            } else {
                contentWidth = CGRectGetWidth(self.backScrollView.frame);
                contentHeight = contentWidth / image.size.width * image.size.height;
                newScale = image.size.width/contentWidth;
            }
        }
    }
    [self.imageView setImage:image];
    self.imageView.frame = CGRectMake(originx, originy, contentWidth, contentHeight);
    NSLog(@"iamgeview == %@",self.imageView);
    contentHeight = MAX(CGRectGetHeight(self.backScrollView.frame), contentHeight);
    self.backScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.backScrollView.frame), contentHeight);
    self.backScrollView.maximumZoomScale = MAX(newScale, 2.5);
    [self.imageView sizeThatFits:self.backScrollView.frame.size];
    self.imageView.center = CGPointMake(self.backScrollView.contentSize.width/2, self.backScrollView.contentSize.height/2);
}
- (void)setCellImagePath:(NSString *)path {
    if (path.length == 0) {
        return;
    }
    self.path = path;
    [self.imageView sd_setImageWithURL:[NSURL fileURLWithPath:path] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self setCellImage:image];
    }];
}
- (void)setIsBackDark:(BOOL)isBackDark {
    _isBackDark = isBackDark;
    if (isBackDark) {
        self.backScrollView.backgroundColor = kDarkCOLOR(0x000000);
        self.contentView.backgroundColor = kDarkCOLOR(0x000000);
    }
    else {
        self.backScrollView.backgroundColor = kDarkCOLOR(0xffffff);
        self.contentView.backgroundColor = kDarkCOLOR(0xffffff);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.backScrollView];
        self.contentView.backgroundColor = kDarkCOLOR(0xffffff);
        [self.backScrollView addSubview:self.imageView];

        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [self.imageView addGestureRecognizer:singleTapGestureRecognizer];

        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.imageView addGestureRecognizer:doubleTapGestureRecognizer];

        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
    }
    return self;
}

- (UIScrollView *)backScrollView {
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _backScrollView.bouncesZoom = YES;
        _backScrollView.maximumZoomScale = 2.5;
        _backScrollView.minimumZoomScale = 1.0;
        _backScrollView.multipleTouchEnabled = YES;
        _backScrollView.delegate = self;
        _backScrollView.scrollsToTop = YES;
        _backScrollView.showsHorizontalScrollIndicator = NO;
        _backScrollView.showsVerticalScrollIndicator = YES;
        _backScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backScrollView.delaysContentTouches = NO;
        _backScrollView.canCancelContentTouches = YES;
        _backScrollView.alwaysBounceVertical = NO;
        _backScrollView.backgroundColor = kDarkCOLOR(0xffffff);
        self.isBackDark = NO;
        if (@available(iOS 11, *)) {
            _backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _backScrollView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"tap == %@",@(tap.numberOfTouchesRequired));
    self.isBackDark = !self.isBackDark;
    if (self.singleTapBlock) {
        self.singleTapBlock(self.isBackDark);
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"%@ == %@",@(self.backScrollView.zoomScale),@(self.backScrollView.minimumZoomScale));
    if (self.backScrollView.zoomScale > self.backScrollView.minimumZoomScale) {
           self.backScrollView.contentInset = UIEdgeInsetsZero;
           [self.backScrollView setZoomScale:self.backScrollView.minimumZoomScale animated:YES];
       } else {
           CGPoint touchPoint = [tap locationInView:self.imageView];
           CGFloat newZoomScale = self.backScrollView.maximumZoomScale;
           CGFloat xsize = self.frame.size.width / newZoomScale;
           CGFloat ysize = self.frame.size.height / newZoomScale;
           NSLog(@"scale == %@",@(newZoomScale));
           [self.backScrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
       }
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (CGRectGetWidth(self.backScrollView.frame)  > self.backScrollView.contentSize.width) ? ((CGRectGetWidth(self.backScrollView.frame) - self.backScrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (CGRectGetHeight(self.backScrollView.frame) > self.backScrollView.contentSize.height) ? ((CGRectGetHeight(self.backScrollView.frame) - self.backScrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(self.backScrollView.contentSize.width * 0.5 + offsetX, self.backScrollView.contentSize.height * 0.5 + offsetY);
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {

}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backScrollView.frame = self.bounds;
    [self.backScrollView setZoomScale:self.backScrollView.minimumZoomScale animated:NO];
    if (self.path) {
      [self setCellImagePath:self.path];
    } 
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
