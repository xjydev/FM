//
//  MainHeaderView.m
//  player
//
//  Created by XiaoDev on 2019/5/16.
//  Copyright © 2019 Xiaodev. All rights reserved.
//

#import "MainHeaderView.h"
#import "XTools.h"
@interface MainHeaderView ()

@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) UIButton *sortButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation MainHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
        _editButton.frame = CGRectMake(0, 0, 50, 40);
        _editButton.backgroundColor = [UIColor redColor];
    }
    return _editButton;
}
- (UIButton *)typeButton {
    if (!_typeButton) {
        _typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeButton.frame = CGRectMake(50, 0, 50, 40);
        _typeButton.backgroundColor = [UIColor whiteColor];
        [_typeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_typeButton setTitle:@"全部" forState:UIControlStateNormal];
    }
    return _typeButton;
}

- (UIButton *)sortButton {
    if (!_sortButton) {
        _sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sortButton.frame = CGRectMake(100, 0, 50, 40);
        _sortButton.backgroundColor = [UIColor whiteColor];
        [_sortButton setTitle:@"名称" forState:UIControlStateNormal];
        [_sortButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _sortButton;
}
- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.frame = CGRectMake(150, 0, 50, 40);
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
