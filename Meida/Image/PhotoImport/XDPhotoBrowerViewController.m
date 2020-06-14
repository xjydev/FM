//
//  XDPhotoBrowerViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2019/11/4.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPhotoBrowerViewController.h"
#import "XDPhotoBrowerCell.h"
#import "XTools.h"
#define  cellId @"xdphotobrowercell"
@interface XDPhotoBrowerViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong)UICollectionView *mainCollectionView;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)NSIndexPath *currentIndexPath;
@end

@implementation XDPhotoBrowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self setUpView];
}
- (void)setUpView {
    
    self.navigationItem.titleView = self.titleLabel;
    [self.view addSubview:self.mainCollectionView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(rightBarButtonAction:)];
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, 200, 40)];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = KUIFontNM(17);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (void)rightBarButtonAction:(UIBarButtonItem *)barButton {
    if (self.currentIndexPath) {
       XDPhotoBrowerCell *cell = (XDPhotoBrowerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.currentIndexPath];
        UIImage *image = cell.imageView.image;
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:2];
        NSString *title = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(xdTopTitleAtIndex:)]) {
            title = [self.delegate xdTopTitleAtIndex:self.currentIndexPath.row];
        }
        if (image) {
            [items addObject:image];
        }
        if (title) {
            [items addObject:title];
        }
        UIActivityViewController *activity = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            activity.popoverPresentationController.barButtonItem = barButton;
            activity.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:activity animated:YES completion:^{
                
            }];
            
        } else {
            [self presentViewController:activity animated:YES completion:nil];
        }
    }
}
#pragma mark - property
- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
        //下面空一像素的线
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = self.view.bounds.size;
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.view.bounds)+10, CGRectGetHeight(self.view.bounds)) collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = [UIColor blackColor];
        [_mainCollectionView registerClass:[XDPhotoBrowerCell class] forCellWithReuseIdentifier:cellId];
        _mainCollectionView.pagingEnabled = YES;
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = kDarkCOLOR(0xffffff);
    }
    return _mainCollectionView;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(xdNumberOfAllPhotos)]) {
        return [self.delegate xdNumberOfAllPhotos];
    }
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XDPhotoBrowerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(xdThumbnailPhotoAtIndex:)]) {
        [cell setCellImage:[self.delegate xdThumbnailPhotoAtIndex:indexPath.row]];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(xdPhotoAtIndex:)]) {
        [cell setCellImage:[self.delegate xdPhotoAtIndex:indexPath.row]];
    }
    else if(self.delegate && [self.delegate respondsToSelector:@selector(xdPhotoPahtAtIndex:)]) {
        [cell setCellImagePath:[self.delegate xdPhotoPahtAtIndex:indexPath.row]];
    }
    else {
        if (indexPath.row < self.imagesArray.count) {
            NSObject *obj = self.imagesArray[indexPath.row];
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *imagePath = (NSString *)obj;
                if (![imagePath hasPrefix:KDocumentP]) {
                    imagePath = [KDocumentP stringByAppendingPathComponent:imagePath];
                }
                [cell setCellImagePath:imagePath];
            }
            else if ([obj isKindOfClass:[UIImage class]]){
                [cell setCellImage:(UIImage *)obj];
            }
        }
    }
    
    @weakify(self);
    cell.singleTapBlock = ^(BOOL isBackDark) {
        @strongify(self);
        if (isBackDark) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [UIView animateWithDuration:0.1 animations:^{
              [self.mainCollectionView setBackgroundColor:kDarkCOLOR(0x000000)];
            }];
            
        }
        else {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [UIView animateWithDuration:0.1 animations:^{
              [self.mainCollectionView setBackgroundColor:kDarkCOLOR(0xffffff)];
            }]; 
        }
    };
    cell.isBackDark = self.navigationController.navigationBarHidden;
    
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
    if (self.delegate && [self.delegate respondsToSelector:@selector(xdTopTitleAtIndex:)]) {
        self.titleLabel.text = [self.delegate xdTopTitleAtIndex:indexPath.row];
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(xdTopAttributedTitleAtIndex:)]) {
        self.titleLabel.attributedText = [self.delegate xdTopAttributedTitleAtIndex:indexPath.row];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.mainCollectionView.frame = CGRectMake(0,0, CGRectGetWidth(self.view.bounds)+10, CGRectGetHeight(self.view.bounds));
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
           layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
           layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
           //下面空一像素的线
           layout.minimumLineSpacing = 10;
           layout.minimumInteritemSpacing = 0;
           layout.itemSize = self.view.bounds.size;
    [self.mainCollectionView setCollectionViewLayout:layout animated:YES];
    if (self.currentIndexPath) {
      [self.mainCollectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(xdNumberOfAllPhotos)]) {
               if (self.currentIndex !=0&& self.currentIndex<[self.delegate xdNumberOfAllPhotos]) {
                   [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
                   self.currentIndex = 0;
               }
           }
    }
}
@end
