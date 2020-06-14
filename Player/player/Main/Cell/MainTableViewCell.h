//
//  MainTableViewCell.h
//  player
//
//  Created by XiaoDev on 2018/6/8.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Record;
@interface MainTableViewCell : UITableViewCell
@property (nonatomic, strong) Record *model;
@end

@interface MainNoDataViewCell : UITableViewCell
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
