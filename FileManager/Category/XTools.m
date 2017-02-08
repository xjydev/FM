//
//  XTools.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XTools.h"
#import "AppDelegate.h"
#import "MRVLCPlayer.h"
#import "VideoViewController.h"
#import "XHUDView.h"
#import "XQuickLookController.h"
#import "AudioViewController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
NSString * const userRotationKey = @"canRotationKey";

static XTools *tools = nil;
@interface XTools()
{
    MRVLCPlayer               *_player;
    UILabel                   *_alertLabel;
    UIActivityIndicatorView   *_activityView;
    
}
@end
@implementation XTools
+ (instancetype)shareXTools {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[XTools alloc] init];
        if (IsPad) {
          tools.isCanRotation = YES;
        }
        else
        {
          tools.isCanRotation = [[kUSerD objectForKey:userRotationKey] boolValue];
        }
        
    });
    return tools;
}
- (NSString *)hiddenFilePath {
    NSString *path = [NSString stringWithFormat:@"%@/.hiddenFile",KDocumentP];
    if (![kFileM fileExistsAtPath:path]) {
       [kFileM createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
    
}
- (NSArray *)videoFormatArray {
    if (!_videoFormatArray) {
//    mkv wmv avi divx xvid, rmvb rm, flv, mp4 4k, mov 3gp, m4v blu-ray (蓝光BD), ts, m2ts swf, asf vob h265(hevc), webm
       _videoFormatArray = @[@"rmvb",@"asf",@"avi",@"divx",@"flv",@"m2ts",@"m4v",@"mkv",@"mov",@"mp4",@"ps",@"ts",@"vob",@"wmv",@"dts",@"swf", @"dv",@"gxf",@"m1v",@"m2v",@"mpeg",@"mpeg1",@"mpeg2",@"mpeg4",@"mpg",@"mts",@"mxf",@"ogm",@"a52",@"m4a",@"mka",@"mod"];
    }
    return _videoFormatArray;
}
- (NSArray *)audioFormatArray {
//    mp3 wma wav ac3 eac3 aac flac ape, cue, amr, ogg vorbis
    if (!_audioFormatArray) {
      _audioFormatArray = @[@"mp3",@"ogg",@"wav",@"ac3",@"eac3",@"ape",@"cda",@"au",@"midi",@"mac",@"aac",@"f4v",@"wma",@"flac",@"cue",@"amr",@"vorbis",@"m4p",@"mp1",@"mp2",];
    }
    return _audioFormatArray;
}
- (NSArray *)documentFormatArray {
    if (!_documentFormatArray) {
       _documentFormatArray = @[@"pdf",@"doc",@"text",@"txt",@"htm",@"dot",@"dotx",@"rtf",@"ppt",@"pots",@"pot",@"pps",@"numbers",@"pages",@"keynote",@"docx",@"xlsx",@"html",@"csv"];
    }
    return _documentFormatArray;
}
- (NSArray *)imageFormatArray {
    if (!_imageFormatArray) {
       _imageFormatArray = @[@"gif",@"jpeg",@"bmp",@"tif",@"jpg",@"pcd",@"qti",@"qtf",@"tiff",@"png",];
    }
    return _imageFormatArray;
}
- (NSArray *)compressFormatArray {
    if (!_compressFormatArray) {
        _compressFormatArray = @[@"zip",];
    }
    return _compressFormatArray;
}
- (NSDateFormatter *)dateFormater {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    return _dateFormater;
}
- (NSString *)dateStr {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"HHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    NSDate *date = [NSDate date];
    _dateStr = [_dateFormater stringFromDate:date];
    return _dateStr;
}
#pragma mark - 播放文件
- (BOOL)playFileWithPath:(NSString *)path OrigionalWiewController:(UIViewController *)origionalWiewController; {
    switch ([self fileFormatWithPath:path]) {
        case FileTypeVideo:
        {
            VideoViewController *video = [origionalWiewController.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
            video.videoPath = path;
            [origionalWiewController presentViewController:video animated:YES completion:^{
                
            }];
        }
            break;
        case FileTypeAudio:
        {
            AudioViewController *audio = [origionalWiewController.storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
            audio.audioPath = path;
            [origionalWiewController presentViewController:audio animated:YES completion:^{
                
            }];
        }
             break;
        case FileTypeImage:
        {
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
            MWPhotoBrowser *brow = [[MWPhotoBrowser alloc]initWithPhotos:@[photo]];
            [origionalWiewController.navigationController pushViewController:brow animated:YES];
        }
            break;
        case FileTypeDocument:
        {
            XQuickLookController *xql = [[XQuickLookController alloc]init];
            xql.itemArray = @[path];
            [origionalWiewController.navigationController pushViewController:xql animated:YES];
        }
            break;
        case FileTypeCompress:
        {
            
        }
            break;
            
            
        default://FileTypeDefault
        {
            
        }
            break;
    }
    return YES;
}

- (FileType )fileFormatWithPath:(NSString *)path {
    NSString *extension = [[path pathExtension]lowercaseString];
    if ([self.videoFormatArray containsObject:extension]) {
        return FileTypeVideo;
    }
    else if ([self.audioFormatArray containsObject:extension]) {
        return FileTypeAudio;
    }
    else
        if ([self.documentFormatArray containsObject:extension]) {
            return FileTypeDocument;
        }
    else if ([self.imageFormatArray containsObject:extension]){
            return FileTypeImage;
        }
    else
        if ([self.compressFormatArray containsObject:extension]) {
            return FileTypeCompress;
        }
    else
        if (extension.length == 0) {
            return FileTypeFolder;
        }
    else {
            return FileTypeDefault;
        }
}

- (UIInterfaceOrientationMask)orientationMask {
    
    if (self.isCanRotation) {
        
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
}
- (void)showMessage:(NSString *)title {
    if (!_alertLabel) {
        _alertLabel = [[UILabel alloc]init];
        _alertLabel.bounds = CGRectMake(0, 0, 100, 40);
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.75];
        _alertLabel.textColor = [UIColor whiteColor];
        _alertLabel.layer.cornerRadius = 10;
        _alertLabel.layer.masksToBounds = YES;
        _alertLabel.hidden = YES;
//        AppDelegate *app =(AppDelegate *)[UIApplication sharedApplication];
        _alertLabel.center = [UIApplication sharedApplication].keyWindow.center;
        [[UIApplication sharedApplication].keyWindow addSubview:_alertLabel];
    }
    _alertLabel.bounds = CGRectMake(0, 0, 16*title.length+30, 40);
    _alertLabel.hidden = NO;
    _alertLabel.text = title;
    [self performSelector:@selector(hiddAlertLabel) withObject:nil afterDelay:title.length * 0.2];
    
}
- (void)hiddAlertLabel {
    [UIView animateWithDuration:0.2 animations:^{
        _alertLabel.alpha = 0;
    } completion:^(BOOL finished) {
       _alertLabel.hidden = YES;
        _alertLabel.alpha = 1;
    }];
   
}
- (void)showLoading:(NSString *)title {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.bounds = CGRectMake(0, 0, 80, 80);
        _activityView.color = [UIColor whiteColor];
        _activityView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        _activityView.hidesWhenStopped = YES;
        _activityView.layer.cornerRadius = 10;
        _activityView.layer.masksToBounds = YES;
        _activityView.center = [UIApplication sharedApplication].keyWindow.center;
        [[UIApplication sharedApplication].keyWindow addSubview:_activityView];
    }
    
    [_activityView startAnimating];
    
}
- (void)hiddenLoading {
    [_activityView stopAnimating];
}
- (double)timeStrToSecWithStr:(NSString *)str {
    double timeSec = 0;
    NSArray *array = [str componentsSeparatedByString:@":"]; 
    for (NSInteger i = 0; i<array.count; i++) {
        NSString *time = [array objectAtIndex:i];
        
       timeSec = timeSec *60 + labs([time integerValue]);
    }
    
    return timeSec;
}
- (NSString *)timeSecToStrWithSec:(double)sec {
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",((NSInteger)sec)/3600,(((NSInteger)sec)%3600)/60,((NSInteger)sec)%60];
}
//获取手机存储空间信息
- (float)allStorageSpace {
    NSDictionary *att = [kFileM attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    float total = [[att objectForKey:NSFileSystemSize] floatValue];
    return total;
}
- (float)freeStorageSpace {
    NSDictionary *att = [kFileM attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    float total = [[att objectForKey:NSFileSystemFreeSize] floatValue];
    return total;
}
- (NSString *)storageSpaceStringWith:(float)space {
    float sizeKb = space/1000;
    float sizeMb = sizeKb/1000;
    float sizeGb = sizeMb/1000;
    if (sizeGb > 1) {
        return [NSString stringWithFormat:@"%.2fG",sizeGb];
    }
    else if (sizeMb > 1) {
        return [NSString stringWithFormat:@"%.2fM",sizeMb];
    }
    else{
        return [NSString stringWithFormat:@"%.2fKB",sizeKb];
    }

}
@end
