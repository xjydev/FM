//
//  FilesListCell.h
//  Wenjian
//
//  Created by XiaoDev on 2019/4/11.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CellActionBlock)(NSIndexPath *index,NSInteger type);
@interface FilesListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, assign)BOOL isSharking;
- (void)setCellTitle:(NSString *)title type:(NSInteger)type cellAction:(CellActionBlock)block;
@end

NS_ASSUME_NONNULL_END
