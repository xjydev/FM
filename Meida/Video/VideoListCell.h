//
//  VideoListCell.h
//  FileManager
//
//  Created by XiaoDev on 14/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
- (void)setCellPath:(NSString *)cellPath;

@end
