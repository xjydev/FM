//
//  FilesTableCell.m
//  Wenjian
//
//  Created by xiaodev on Oct/19/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "FilesTableCell.h"
#import "XTools.h"
#import "Record+CoreDataProperties.h"
@interface FilesTableCell()
{
    __weak IBOutlet UIImageView *_headerImageView;
    
    __weak IBOutlet UIView *_tagView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_subLabel;
    __weak IBOutlet NSLayoutConstraint *nameHeaderCon;
}
@end
@implementation FilesTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _tagView.layer.cornerRadius = 5;
    _tagView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setFileModel:(Record *)fileModel {
    _nameLabel.text = fileModel.name;
    if (fileModel.progress.floatValue>0) {
      _subLabel.text = [NSString stringWithFormat:@"%@  %.2f%%",[XTOOLS timeStrFromDate:fileModel.modifyDate],fileModel.progress.floatValue*100];
    }
    else
        if (fileModel.size.doubleValue>0) {
            _subLabel.text = [XTOOLS storageSpaceStringWith:fileModel.size.doubleValue];
        }
    else
    {
        if (fileModel.fileType.integerValue <=0) {//防止一些文件类型没有存上
            fileModel.fileType = @([XTOOLS fileFormatWithPath:fileModel.path]);
        }
        NSString *typeStr = @"文件夹";
        switch (fileModel.fileType.intValue) {
            case FileTypeFolder:
                typeStr = @"文件夹";
                break;
            case FileTypeAudio:
                typeStr = @"音频";
                break;
            case FileTypeImage:
                typeStr = @"图片";
                break;
            case FileTypeVideo:
                typeStr = @"视频";
                break;
            case FileTypeCompress:
                typeStr = @"压缩文件";
                break;
            case FileTypeDocument:
                typeStr = @"文档";
                break;
            default:
                typeStr = @"其他";
                break;
        }
        _subLabel.text = typeStr;
    }
    NSLog(@"===%@",@(fileModel.markInt.intValue));
    if (fileModel.markInt.intValue>0) {
        nameHeaderCon.constant = 20;
    }
    else
    {
        nameHeaderCon.constant = 10;
    }
    _tagView.backgroundColor = [[XDFileManager defaultManager] fileMarkWithTag:fileModel.markInt.intValue];
    if (fileModel.fileType.integerValue<=0) {
        fileModel.fileType = @([XTOOLS fileFormatWithPath:fileModel.path]);
    }
    switch (fileModel.fileType.intValue) {
        case FileTypeFolder:
            [_headerImageView setImage:[UIImage imageNamed:@"file_folder"]];
            break;
        case FileTypeAudio:
            [_headerImageView setImage:[UIImage imageNamed:@"file_audio"]];
            break;
        case FileTypeImage:
            [_headerImageView setImage:[UIImage imageNamed:@"file_image"]];
            break;
        case FileTypeVideo:
            [_headerImageView setImage:[UIImage imageNamed:@"file_video"]];
            break;
        case FileTypeCompress:
            [_headerImageView setImage:[UIImage imageNamed:@"file_zip"]];
            break;
        case FileTypeDocument:
            [_headerImageView setImage:[UIImage imageNamed:@"file_document"]];
            break;
        default:
            [_headerImageView setImage:[UIImage imageNamed:@"file_unknown"]];
            break;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
