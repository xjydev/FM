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

static XTools *tools = nil;
@interface XTools()
{
    MRVLCPlayer  *_player;
    
}
@end
@implementation XTools
+ (instancetype)shareXTools {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[XTools alloc] init];
        tools.isCanRotation = YES;
    });
    return tools;
}
- (NSArray *)videoFormatArray {
    if (!_videoFormatArray) {
//    mkv wmv avi divx xvid, rmvb rm, flv, mp4 4k, mov 3gp, m4v blu-ray (蓝光BD), ts, m2ts swf, asf vob h265(hevc), webm
       _videoFormatArray = @[@"rmvb",@"asf",@"avi",@"divx",@"flv",@"m2ts",@"m4v",@"mkv",@"mov",@"mp4",@"ps",@"ts",@"vob",@"wmv",@"dts",@"swf", @"dv",@"gxf",@"m1v",@"m2v",@"mpeg",@"mpeg1",@"mpeg2",@"mpeg4",@"mpg",@"mts",@"mxf",@"ogm",@"a52",@"m4a",@"m4p",@"mka",@"mod",@"mp1",@"mp2",];
    }
    return _videoFormatArray;
}
- (NSArray *)audioFormatArray {
//    mp3 wma wav ac3 eac3 aac flac ape, cue, amr, ogg vorbis
    if (!_audioFormatArray) {
      _audioFormatArray = @[@"mp3",@"ogg",@"wav",@"ac3",@"eac3",@"ape",@"cda",@"au",@"midi",@"mac",@"aac",@"f4v",@"wma",@"flac",@"cue",@"amr",@"vorbis",];
    }
    return _audioFormatArray;
}
- (NSArray *)documentFormatArray {
    if (!_documentFormatArray) {
       _documentFormatArray = @[@"pdf",@"doc",@"text",@"txt",@"htm",@"dot",@"dotx",@"rtf",@"ppt",@"pots",@"pot",@"pps",@"numbers",@"pages",@"keynote",];
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
            
        }
        case FileTypeImage:
        {
            
        }
            break;
        case FileTypeDocument:
        {
            
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
//        switch ([UIDevice currentDevice].orientation) {
//            case UIDeviceOrientationUnknown:
//                return UIInterfaceOrientationMaskAll;
//                break;
//            case UIDeviceOrientationPortrait:
//                return UIInterfaceOrientationMaskPortrait;
//                break;
//            case UIDeviceOrientationPortraitUpsideDown:
//                return UIInterfaceOrientationMaskPortraitUpsideDown;
//                break;
//            case UIDeviceOrientationLandscapeLeft:
//                return UIInterfaceOrientationMaskLandscapeLeft;
//                break;
//            case UIDeviceOrientationLandscapeRight:
//                return UIInterfaceOrientationMaskLandscapeRight;
//                break;
//                
//            default:
//                return UIInterfaceOrientationMaskAll;
//                break;
//        }
    }
    
    
}
@end
