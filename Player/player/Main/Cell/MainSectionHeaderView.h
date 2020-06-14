//
//  MainSectionHeaderView.h
//  player
//
//  Created by XiaoDev on 2018/6/8.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,XMainHeaderType) {
    XMainHeaderTypeDefault,
    XMainHeaderTypeFileType,
    XMainHeaderTypeSort,
    XMainHeaderTypeEdit,
    XMainHeaderTypeSearch,
};
@class Record;
@interface MainSectionHeaderView : UITableViewHeaderFooterView
@property (nonatomic, assign) XMainHeaderType headerType;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) NSInteger sortType;
@property (nonatomic, copy)void (^headerSelectedHanlder)(NSInteger tag,NSObject *obj);
- (void)reloadHeaderView;
@end

@interface MainSectionFooterView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIControl *headerControl;

@property (nonatomic, strong)Record *model;

@end
