//
//  FilesListCell.m
//  Wenjian
//
//  Created by XiaoDev on 2019/4/11.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "FilesListCell.h"
@interface FilesListCell()
@property (nonatomic, copy)CellActionBlock cellBlock;
@property (nonatomic, strong)CAKeyframeAnimation *animation;
@property (nonatomic, strong)UILongPressGestureRecognizer *longPressGes;
@end

@implementation FilesListCell
- (UILongPressGestureRecognizer *)longPressGes {
    if (!_longPressGes) {
        _longPressGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesAction:)];
    }
    return _longPressGes;
}
- (void)longPressGesAction:(UILongPressGestureRecognizer *)longPress {
    if (self.cellBlock) {
        self.cellBlock(self.indexPath, 1);//1长按
    }
}
- (void)setCellTitle:(NSString *)title type:(NSInteger)type cellAction:(CellActionBlock)block {
    self.cellBlock = block;
    switch (type) {
        case 10:
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"folder_home"]];
            self.titleLabel.text = title ;
        }
            break;
        case 1:
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"folder_video"]];
            self.titleLabel.text = title ;
        }
            break;
        case 2:
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"folder_music"]];
            self.titleLabel.text = title ;
        }
            break;
        case 3:
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"folder_image"]];
            self.titleLabel.text = title ;
        }
            break;
        case 4:
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"folder_doc"]];
            self.titleLabel.text = title ;
        }
            break;
        case 5://添加
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"addNewFiles"]];
            self.titleLabel.text = title ;
        }
            break;
            
        default:
        {
            [self.headerImageView setImage:[UIImage imageNamed:@"folder"]];
            self.titleLabel.text = title ;
        }
            break;
    }
    if (self.longPressGes.view != self) {//所有都可以点击，文件：删除，更改名称。特殊文件：更改名称。新增：文件类型。
        [self addGestureRecognizer:self.longPressGes];
    }
}
- (void)setIsSharking:(BOOL)isSharking {
    _isSharking = isSharking;
    if (isSharking) {
        self.animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        self.animation.duration = 0.2;
        self.animation.values = @[@(-(4) / 180*M_PI),@((4) / 180.0*M_PI),@(-(4) / 180.0*M_PI)];
        self.animation.repeatCount = MAXFLOAT;
        [self.contentView.layer addAnimation:self.animation forKey:@"tanimation"];
    }
    else
    {
        if ([self.contentView.layer animationForKey:@"tanimation"]) {
            [self.contentView.layer removeAnimationForKey:@"tanimation"];
        }
    }
}

@end
