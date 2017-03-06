//
//  DownloadCenterCell.h
//  FileManager
//
//  Created by xiaodev on Mar/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Download+CoreDataProperties.h"
@interface DownloadCenterCellModel : NSObject
- (id)initWithDownloadModel:(Download *)model;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, assign)float  progress;
@property (nonatomic, copy)NSString *path;
@property (nonatomic, strong)Download *model;
@property (nonatomic, assign)BOOL    isDownloading;


@end
@interface DownloadCenterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *lookButton;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgress;

- (void)setHeaderImage:(UIImage *)image;
- (void)setModel:(DownloadCenterCellModel *)model type:(NSInteger)type;
@end
