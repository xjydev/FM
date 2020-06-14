//
//  MainSectionHeaderView.m
//  player
//
//  Created by XiaoDev on 2018/6/8.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "MainSectionHeaderView.h"
#import "XTools.h"
@interface MainSectionHeaderView ()
@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) UIButton *sortButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *editButton;
@end
@implementation MainSectionHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.editButton];
        [self addSubview:self.typeButton];
        [self addSubview:self.sortButton];
        [self addSubview:self.searchButton];
    }
    return self;
}
- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(0, 0, 50, 50);
        _editButton.backgroundColor = [UIColor redColor];
    }
    return _editButton;
}
- (UIButton *)typeButton {
    if (!_typeButton) {
        _typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeButton.frame = CGRectMake(50, 0, (kScreen_Width - 100)/2, 50);
        _typeButton.backgroundColor = [UIColor whiteColor];
        [_typeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_typeButton setTitle:@"全部" forState:UIControlStateNormal];
    }
    return _typeButton;
}

- (UIButton *)sortButton {
    if (!_sortButton) {
        _sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sortButton.frame = CGRectMake(kScreen_Width/2, 0, (kScreen_Width - 100)/2, 50);
        _sortButton.backgroundColor = [UIColor whiteColor];
        [_sortButton setTitle:@"名称" forState:UIControlStateNormal];
        [_sortButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _sortButton;
}
- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.frame = CGRectMake(kScreen_Width - 50, 0, 50, 50);
        _searchButton.backgroundColor = [UIColor redColor];
    }
    return _searchButton;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
