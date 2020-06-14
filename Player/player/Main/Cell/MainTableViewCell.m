//
//  MainTableViewCell.m
//  player
//
//  Created by XiaoDev on 2018/6/8.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "MainTableViewCell.h"
#import "XManageCoreData.h"
#import <SDWebImage/SDImageCache.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import "XTools.h"
@interface MainTableViewCell ()<VLCMediaThumbnailerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, assign) BOOL needStorage;
@end

@implementation MainTableViewCell
static int loadNumber = 0;//视频图片加载一次最多加载8个。

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.layer.masksToBounds = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)setModel:(Record *)model {
    _model = model;
    NSLog(@"cellmodel == %@",model);
    NSString *sPath =_model.path;
    if (![sPath hasPrefix:KDocumentP]) {
        sPath = [KDocumentP stringByAppendingPathComponent:sPath];
    }
    self.needStorage = NO;
    NSString *name = _model.name;
    if (name.length == 0) {
        name = _model.path.lastPathComponent;
        _model.name = name;
        self.needStorage = YES;
    }
    self.titleLabel.text = name;
    
    if (_model.fileType == 0 ) {//如果是默认就错了，重新获取
        _model.fileType = @([XTOOLS fileFormatWithPath:_model.path]);
        self.needStorage = YES;
    }
    switch (_model.fileType.integerValue) {//文件图片
        case FileTypeVideo: {
            [self showProgressDetailText:YES];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_video"]];
            [self setVideoImagePath:sPath];
            }
            break;
        case FileTypeAudio:{
            [self showProgressDetailText:YES];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_audio"]];
        }
            break;
        case FileTypeImage:{
            [self showProgressDetailText:NO];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_image"]];
            [self setThumbnailImageWithPath:sPath];
        }
            break;
        case FileTypeDocument:{
            [self showProgressDetailText:NO];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_doc"]];
        }
            break;
        case FileTypeCompress:{
            [self showProgressDetailText:NO];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_zip"]];
        }
            break;
        case FileTypeFolder:{
            [self showProgressDetailText:NO];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_folder"]];
        }
            break;
            
        default:{
            [self showProgressDetailText:NO];
            [self.headerImageView setImage:[UIImage imageNamed:@"header_no"]];
        }
            break;
    }
    if (self.needStorage) {
        [[XManageCoreData manageCoreData]saveRecord:_model];
    }
}
- (void)showProgressDetailText:(BOOL)is {
    NSString *sPath = self.model.path;
    if (![sPath hasPrefix:KDocumentP]) {
        sPath = [KDocumentP stringByAppendingPathComponent:sPath];
    }
    if (is) {
        //观看进度
        if (self.model.progress.floatValue  > 0.00) {
            NSString *mtime = @"";
            if (self.model.modifyDate) {
                mtime = [XTOOLS hmtimeStrFromDate:self.model.modifyDate];
            }
            NSString *doStr = @"已看：";
            if (self.model.fileType.integerValue == FileTypeAudio) {
                doStr = @"已听：";
            }
            if (self.model.totalTime.floatValue > 0.0) {
               self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@%.f%%",mtime,doStr, (self.model.progress.floatValue/self.model.totalTime.floatValue)*100];
            }
            else {
                 self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@%@",mtime,doStr, [XTOOLS timeSecToStrWithSec:self.model.progress.floatValue]];
            }
            self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@%.f%%",mtime,doStr,self.model.progress.floatValue];
        }
        else {
            if (self.model.size.doubleValue == 0) {
                self.needStorage = YES;
                self.model.size = @([XTOOLS fileSizeAtPath:sPath]);
            }
            NSString *tname = @"视频";
            if (self.model.fileType.integerValue == FileTypeAudio) {
                tname = @"音频";
            }
            self.subTitleLabel.text = [NSString stringWithFormat:@"%@大小：%@",tname,[XTOOLS storageSpaceStringWith:self.model.size.doubleValue]];
        }
    }
    else {
        if (self.model.size.doubleValue == 0) {
            self.needStorage = YES;
            self.model.size = @([XTOOLS fileSizeAtPath:sPath]);
        }
        NSString *typeName = @"图片";
        if (self.model.fileType.integerValue == FileTypeDocument) {
            typeName = @"文档";
        }
        else if (self.model.fileType.integerValue == FileTypeImage) {
           typeName = @"图片";
        }
        else {
          typeName = @"文件";
        }
        self.subTitleLabel.text = [NSString stringWithFormat:@"%@大小：%@",typeName,[XTOOLS storageSpaceStringWith:self.model.size.doubleValue]];
    }
    
}
- (void)setVideoImagePath:(NSString *)path {
    self.headerImageView.image = nil;
    NSString *pathlast = kSubDokument(path);
    NSLog(@"path last == %@",pathlast);
    if ([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:pathlast]) {
        self.headerImageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:pathlast];
    }
    else
    {
        if (loadNumber < 8) {
            loadNumber ++;
            VLCMedia *m = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:path]];
            VLCMediaThumbnailer *thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:m andDelegate:self];
            thumbnailer.thumbnailHeight = self.headerImageView.bounds.size.height;
            thumbnailer.thumbnailWidth = self.headerImageView.bounds.size.width;
            thumbnailer.snapshotPosition = 0.1;
            [thumbnailer fetchThumbnail];
        }
    }
}
- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    loadNumber --;
    NSString *oldPath =[[mediaThumbnailer.media.url.absoluteString stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
    if ([oldPath hasPrefix:@"file:///"]) {
        oldPath = [oldPath substringFromIndex:7];
    }
    oldPath = kSubDokument(oldPath);
    
    NSLog(@"截图成功 == %@ = %@",oldPath,self.model.path);
    if ([oldPath isEqualToString:self.model.path]) {//如果数据和截图匹配
        [self.headerImageView setImage:[UIImage imageWithCGImage:thumbnail]];
        self.model.totalTime = mediaThumbnailer.media.length.value;
        self.needStorage = YES;
        [[SDImageCache sharedImageCache]storeImage:[UIImage imageWithCGImage:thumbnail] forKey:oldPath toDisk:YES completion:^{
            
        }];
    }
}

- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    NSLog(@"截图失败");
}

- (void)setThumbnailImageWithPath:(NSString *)path {
    self.headerImageView.image = nil;
    NSString *pathlast = kSubDokument(path);
    
    if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:pathlast]) {
        self.headerImageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:pathlast];
    }
    else
    {
        self.headerImageView.image = nil;
        dispatch_queue_t queue = dispatch_queue_create("cn.xiaodev", DISPATCH_QUEUE_SERIAL); dispatch_async(queue, ^{
            @autoreleasepool {
                @try {
                    UIImage * limage = nil;
                    NSData *imageData = [NSData dataWithContentsOfFile:path];
                    if (imageData.length > 1024*1024) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage * dimage = [self compressLargeImage:[UIImage imageWithData:imageData]];
                            [[SDImageCache sharedImageCache]storeImage:dimage forKey:pathlast toDisk:YES completion:^{
                                
                            }];
                            [self.headerImageView setImage:dimage];
                        });
                    }
                    else
                    {
                        if (imageData.length > 1024*100) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            imageData = UIImageJPEGRepresentation(image, 0.05);
                        }
                        limage = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[SDImageCache sharedImageCache]storeImage:limage forKey:pathlast toDisk:YES completion:^{
                                
                            }];
                            [self.headerImageView setImage:limage];
                        });
                    }
                    
                } @finally {
                    
                }
            }
        });
    }
}
- (UIImage *)compressLargeImage:(UIImage *)largeImage {
    if (largeImage.size.width== 0) {
        return nil;
    }
    CGSize size = CGSizeMake(kScreen_Width, largeImage.size.height/largeImage.size.width*kScreen_Width);
    UIGraphicsBeginImageContext(size);
    [largeImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
@end


@interface MainNoDataViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation MainNoDataViewCell
- (void)setIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.titleLabel.text = @"数据线传输";
        [self.centerImageView setImage:[UIImage imageNamed:@"transfer1"]];
        self.detailLabel.text = @"1.使用数据线连接电脑，打开“iTunes”软件或者Finder本地设备。\n2.找到左上角手机符号，点击“文件共享”。\n3.右边找到“简单文件”，把文件拖到最右边的框内或者点击“添加”选择文件。\n4.传输完成打开软件刷新，既可看到上传文件。如果文件较大建议此传输方式。";
    }
    else {
        self.titleLabel.text = @"无线传输";
        [self.centerImageView setImage:[UIImage imageNamed:@"transfer2"]];
        self.detailLabel.text = @"1.点击右上角“+”，选择电脑传输。\n2.打开电脑浏览器，把IP地址输入到浏览器地址栏中。\n3.把文件拖到网页中既可上传。\n4.上传完成，进入首页刷新既可看到文件。由于局域网限制，传输数据可能较慢。";
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
