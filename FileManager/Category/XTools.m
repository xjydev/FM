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
    if (_videoFormatArray) {
//    mkv wmv avi divx xvid, rmvb rm, flv, mp4 4k, mov 3gp, m4v blu-ray (蓝光BD), ts, m2ts swf, asf vob h265(hevc), webm
       _videoFormatArray = @[@"rmvb",@"asf",@"avi",@"divx",@"flv",@"m2ts",@"m4v",@"mkv",@"mov",@"mp4",@"ps",@"ts",@"vob",@"wmv",@"dts",@"swf", @"dv",@"gxf",@"m1v",@"m2v",@"mpeg",@"mpeg1",@"mpeg2",@"mpeg4",@"mpg",@"mts",@"mxf",@"ogm",@"a52",@"m4a",@"m4p",@"mka",@"mod",@"mp1",@"mp2",];
    }
    return _videoFormatArray;
}
- (NSArray *)audioFormatArray {
//    mp3 wma wav ac3 eac3 aac flac ape, cue, amr, ogg vorbis
    if (_audioFormatArray) {
      _audioFormatArray = @[@"mp3",@"ogg",@"wav",@"ac3",@"eac3",@"ape",@"cda",@"au",@"midi",@"mac",@"aac",@"f4v",@"wma",@"flac",@"cue",@"amr",@"vorbis",];
    }
    return _audioFormatArray;
}
- (NSArray *)documentFormatArray {
    if (_documentFormatArray) {
       _documentFormatArray = @[@"pdf",@"doc",@"text",@"txt",@"htm",@"dot",@"dotx",@"rtf",@"ppt",@"pots",@"pot",@"pps",@"numbers",@"pages",@"keynote",];
    }
    return _documentFormatArray;
}
- (NSArray *)imageFormatArray {
    if (_imageFormatArray) {
       _imageFormatArray = @[@"gif",@"jpeg",@"bmp",@"tif",@"jpg",@"pcd",@"qti",@"qtf",@"tiff",@"png",];
    }
    return _imageFormatArray;
}
- (NSArray *)compressFormatArray {
    if (_compressFormatArray) {
        _compressFormatArray = @[@"zip",];
    }
    return _compressFormatArray;
}
+ (FileType )fileFormatWithPath:(NSString *)path {
//    if ([path pathExtension]) {
//        
//    }
    return FileTypeAudio;
}
- (BOOL)playWithFilePath:(NSString *)filePath {
    
    return YES;
}

- (UIInterfaceOrientationMask)orientationMask {
    
    if (self.isCanRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationUnknown:
                return UIInterfaceOrientationMaskAll;
                break;
            case UIInterfaceOrientationPortrait:
                return UIInterfaceOrientationMaskPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                return UIInterfaceOrientationMaskPortraitUpsideDown;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                return UIInterfaceOrientationMaskLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                return UIInterfaceOrientationMaskLandscapeRight;
                break;
                
            default:
                return UIInterfaceOrientationMaskAll;
                break;
        }
    }
    
}
@end
