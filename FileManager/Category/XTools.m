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
#import "UMessage.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

NSString * const userRotationKey = @"canRotationKey";

static XTools *tools = nil;
@interface XTools()
{
    MRVLCPlayer               *_player;
    UILabel                   *_alertLabel;
    UIActivityIndicatorView   *_activityView;
    UILabel                   *_activityLabel;
    
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
       _videoFormatArray = @[@"rmvb",@"asf",@"avi",@"divx",@"flv",@"m2ts",@"m4v",@"mkv",@"mov",@"mp4",@"ps",@"ts",@"vob",@"wmv",@"dts",@"swf", @"dv",@"gxf",@"m1v",@"m2v",@"mpeg",@"mpeg1",@"mpeg2",@"mpeg4",@"mpg",@"mts",@"mxf",@"ogm",@"a52",@"m4a",@"mka",@"mod",@"caf"];
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
        [_dateFormater setDateFormat:@"YYYYMMDDHHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    NSDate *date = [NSDate date];
    _dateStr = [_dateFormater stringFromDate:date];
    return _dateStr;
}
- (NSString *)timeStr {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"HHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    NSDate *date = [NSDate date];
    _timeStr = [_dateFormater stringFromDate:date];
    return _timeStr;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddAlertLabel) object:nil];
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
//completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler
- (void)showAlertTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSInteger i= 0; i<buttonTitles.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(i);
        }];
        [alert addAction:action];
    }
   
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:^{
        
    }];
}
- (void)showLoading:(NSString *)title {
    if (!_activityView) {
        UIView *asuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        asuperView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        asuperView.center =CGPointMake([UIApplication sharedApplication].keyWindow.center.x, [UIApplication sharedApplication].keyWindow.center.y-40);
        asuperView.layer.cornerRadius = 10;
        asuperView.layer.masksToBounds = YES;
        
        _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(10, 0, 80, 80);
        _activityView.color = [UIColor whiteColor];
        _activityView.hidesWhenStopped = YES;
        [asuperView addSubview:_activityView];
    
        
        _activityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 100, 20)];
        _activityLabel.textAlignment = NSTextAlignmentCenter;
        _activityLabel.font = [UIFont systemFontOfSize:14];
        _activityLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        [asuperView addSubview:_activityLabel];
        
        [[UIApplication sharedApplication].keyWindow addSubview:asuperView];
        
    }
    _activityView.superview.hidden = NO;
    _activityLabel.text = title;
    [_activityView startAnimating];
    
}
- (void)hiddenLoading {
    _activityView.superview.hidden = YES;
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
#pragma mark -- 加密md5
- (NSString *)md5Fromstr:(NSString *)str {
    if (str) {
        const char *cStr = [str UTF8String];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        //把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了digest这个空间中
        CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", digest[i]];//x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
        return output;
    }
    return nil;
}
- (void)openVPN {
[self showAlertTitle:@"访问方法" message:@"如果国外网站无法访问，可以去App Store搜索“免费VPN”，选择安装VPN翻墙软件，安装后配置打开VPN然后再次访问此网页。\n推荐“Green”VPN软件" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
    
}];
}
- (void)choose18year {
    if ([kUSerD integerForKey:@"userage"]==0) {
        [self showAlertTitle:@"您是否年满18周岁？" message:@"本应用涉及到的互联网内容可能不宜未成年人观看,如果满18周岁,请打开应用通知功能。" buttonTitles:@[@"不满18岁",@"年满18周岁"] completionHandler:^(NSInteger num) {
            if (num == 0) {
                [UMessage setAlias:@"18down" type:kUMessageAliasTypeQQ response:^(id responseObject, NSError *error) {
                    NSLog(@"18down ===%@==%@",responseObject,error);
                }];
            }
            else
            {
                
                [UMessage setAlias:@"18up" type:kUMessageAliasTypeSina response:^(id responseObject, NSError *error) {
                    NSLog(@"18up ===%@==%@",responseObject,error);
                }];
            }
            [kUSerD setInteger:1 forKey:@"userage"];
            [kUSerD synchronize];
        }];
        
    }
}
- (void)gotoAppStoreComment {
    NSInteger commentNum = [kUSerD integerForKey:@"appstorecomment"];
    if (commentNum >= 10) {
        [self showAlertTitle:@"给个好评吧" message:@"如果感觉不错，去App Store奖励程序员一个五星好评吧。" buttonTitles:@[@"五星好评",@"稍后评论"] completionHandler:^(NSInteger num) {
            
            if (num == 0) {
                NSString *appleID = @"1184757517";
                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                 [kUSerD setInteger:-100 forKey:@"appstorecomment"];
            }
            else
                if (num == 1) {
                    [kUSerD setInteger:0 forKey:@"appstorecomment"];
                    
                }
            
            [kUSerD synchronize];
            
        }];
    }
    [kUSerD setInteger:commentNum+1 forKey:@"appstorecomment"];
    [kUSerD synchronize];
    
}
@end
