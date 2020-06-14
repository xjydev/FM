//
//  VideoListCell.m
//  FileManager
//
//  Created by XiaoDev on 14/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "VideoListCell.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "XManageCoreData.h"
#import "XTools.h"
static int loadNumber = 0;//一次最多加载8个。
@interface VideoListCell()<VLCMediaThumbnailerDelegate>
@property (nonatomic, strong)NSString *cellVideoPath;
@property (nonatomic, strong)Record *recordObject;
@end;
@implementation VideoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setCellPath:(NSString *)cellPath {
    self.cellVideoPath = cellPath;
    if ([self.cellVideoPath hasPrefix:@"/"]) {
        self.cellVideoPath = [self.cellVideoPath substringFromIndex:1];
    }
    self.recordObject = [[XManageCoreData manageCoreData]getRecordObjectWithPath:self.cellVideoPath];
    NSString *iconPath = self.cellVideoPath;
    if (![iconPath hasPrefix:kCachesP]) {
        iconPath = [kCachesP stringByAppendingPathComponent:[XTOOLS md5Fromstr:self.cellVideoPath]];
    }
    if (![kFileM fileExistsAtPath:iconPath]) {
        NSLog(@"111111111111111 ===== %@",self.cellVideoPath);
        [self.headerImageView setImage:nil];
        NSString *vpath = self.cellVideoPath;
        if (![self.cellVideoPath hasPrefix:KDocumentP]) {
            vpath = [KDocumentP stringByAppendingPathComponent:vpath];
        }
        if (loadNumber < 8) {
            loadNumber ++;
            VLCMedia *m = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:vpath]];
            VLCMediaThumbnailer *thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:m andDelegate:self];
            thumbnailer.thumbnailHeight = self.headerImageView.bounds.size.height*3;
            thumbnailer.thumbnailWidth = self.headerImageView.bounds.size.width*3;
            thumbnailer.snapshotPosition = 0.1;
            [thumbnailer fetchThumbnail];
        }
        self.titleLabel.text = self.cellVideoPath.lastPathComponent;
        self.contextLabel.text = [XTOOLS storageSpaceStringWith:[XTOOLS fileSizeAtPath:vpath]];
    }
    else
    {
        NSLog(@"===========image cash =========== %@",cellPath);
       
        self.titleLabel.text = self.cellVideoPath.lastPathComponent;
        
        [self.headerImageView setImage:[UIImage imageWithContentsOfFile:iconPath]];
        NSString *totalTime = [XTOOLS timeSecToStrWithSec:self.recordObject.totalTime.doubleValue];
        
        if (self.recordObject.progress.floatValue>0) {
            self.contextLabel.text = [NSString stringWithFormat:@"%@ \n已看%@",totalTime,[XTOOLS timeSecToStrWithSec:self.recordObject.progress.doubleValue]];
        }
        else
        {
            self.contextLabel.text = totalTime;
        }
        
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    loadNumber --;
    NSString *oldPath =[[mediaThumbnailer.media.url.absoluteString stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
    if ([oldPath hasPrefix:@"/"]) {
        oldPath = [oldPath substringFromIndex:1];
    }
    NSRange range = [oldPath rangeOfString:KDocumentP];
    if (range.location != NSNotFound && oldPath.length >= range.location+range.length+1) {
        oldPath = [oldPath substringFromIndex:range.location+range.length+1];
        if ([oldPath isEqualToString:self.cellVideoPath]) {//如果数据和截图匹配
            [self.headerImageView setImage:[UIImage imageWithCGImage:thumbnail]];
            self.contextLabel.text = mediaThumbnailer.media.length.stringValue;
        }
        
        NSString *imageCacsh = [kCachesP stringByAppendingPathComponent:[XTOOLS md5Fromstr:oldPath]];
        
        NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:thumbnail], 1.0);
        BOOL issave = [imageData writeToFile:imageCacsh atomically:YES];
        if (issave) {
            [[XManageCoreData manageCoreData]saveRecordName:oldPath.lastPathComponent path:oldPath record:-1 totalTime:mediaThumbnailer.media.length.intValue/1000 iconPath:nil];
            
        }
        NSLog(@"old ===============\n%@\n%@",oldPath,self.cellVideoPath);
    }
}

- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    loadNumber --;
    NSLog(@"截图失败");
}

@end
