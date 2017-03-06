//
//  DownloadCenterCell.m
//  FileManager
//
//  Created by xiaodev on Mar/1/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "DownloadCenterCell.h"
#import "DownLoadCenter.h"
@implementation DownloadCenterCellModel
- (id)initWithDownloadModel:(Download *)model {
    self = [super init];
    if (self) {
       self.model = model;
    }
    return self;
    
}
- (NSString *)name {
    if (!_name) {
        if (self.model.name.length>0) {
            _name = self.model.name;
        }
        else
            if (self.model.path.lastPathComponent.length>0) {
                _name = self.model.path.lastPathComponent;
            }
        else
        {
            _name = self.model.url.lastPathComponent;
        }
    }
    return _name;
}
- (NSString *)path {
    return self.model.path;
}
- (void)setIsDownloading:(BOOL)isDownloading{
    _isDownloading = isDownloading;
    if (_isDownloading) {
        [[DownLoadCenter defaultDownLoad]startDownload:self.model.url trag:nil];
    }
    else
    {
        [[DownLoadCenter defaultDownLoad]pauseDownload];
    }
}
@end
@implementation DownloadCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setHeaderImage:(UIImage *)image {
    self.headerImageView.frame = CGRectMake((60-image.size.width)/2, (60-image.size.height)/2, image.size.width, image.size.height);
    [self.headerImageView setImage:image];
}

- (void)setModel:(DownloadCenterCellModel *)model type:(NSInteger)type{
    self.titleLabel.text = model.name;
    if (type ==1) {
        self.detailLabel.text = @"正在下载";
    }
    else
        if(type == 2){
          self.detailLabel.text = @"正在等待下载";
        }
    else
    {
        self.detailLabel.text = @"已下载";
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
