//
//  PhotoImportCollectionCell.h
//  FileManager
//
//  Created by xiaodev on Feb/10/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^CellAddLongPressGesAction)(NSIndexPath *index);
@interface PhotoImportCollectionCell : UICollectionViewCell
{
    UILongPressGestureRecognizer *_longPressGes;
    
    NSIndexPath  *_index;
//    NSString  *_cellPath;
}
@property (nonatomic, copy)CellAddLongPressGesAction cellLongPressGesBlock;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
//@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UIImageView *frontImageView;
@property (nonatomic, assign)BOOL isSelected;

- (void)setCenterImage:(UIImage *)image withType:(NSInteger)type;
- (void)setCenterImagePath:(NSString *)imagePath;
- (void)cellIndex:(NSIndexPath *)index addLongPressGesAction:(CellAddLongPressGesAction)longPressAction;
@end
