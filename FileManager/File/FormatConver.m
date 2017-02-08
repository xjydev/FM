//
//  FormatConver.m
//  FileManager
//
//  Created by xiaodev on Jan/10/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "FormatConver.h"
#import <AVFoundation/AVFoundation.h>
#import "XTools.h"
@implementation FormatConver
- (void)converFilePath:(NSString *)sourcePath WithType:(NSString *)type completion:(void(^)(NSString *converFilePath))comepleteBlock
{
    /**
     *  mov格式转mp4格式
     */
    NSURL *sourceUrl = [NSURL fileURLWithPath:sourcePath];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        
        NSMutableString *resultPath = [NSMutableString stringWithString:sourcePath];
        NSRange extension = [resultPath rangeOfString:[resultPath pathExtension]];
        
        
//        NSString * resultPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:uniqueName];//PATH_OF_DOCUMENT为documents路径
        
        NSLog(@"output File Path : %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;//可以配置多种输出文件格式
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             dispatch_async(dispatch_get_main_queue(), ^{
//                 [hud hideAnimated:YES];
             });
             
             switch (exportSession.status) {
                     
                 case AVAssetExportSessionStatusUnknown:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusUnknown");
//                     CLOUDMESSAGETIPS(@"视频格式转换出错Unknown", 0.8); //自定义错误提示信息
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusWaiting");
//                     CLOUDMESSAGETIPS(@"视频格式转换出错Waiting", 0.8);
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusExporting");
//                     CLOUDMESSAGETIPS(@"视频格式转换出错Exporting", 0.8);
                     
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                 {
                     
                     //                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     
                     comepleteBlock(resultPath);
                     
                     
                     NSLog(@"mp4 file size:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
                 }
                     break;
                     
                 case AVAssetExportSessionStatusFailed:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusFailed");
//                     CLOUDMESSAGETIPS(@"视频格式转换出错Unknown", 0.8);
                     
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusFailed");
//                     CLOUDMESSAGETIPS(@"视频格式转换出错Cancelled", 0.8);
                     
                     break;
                     
             }  
             
         }];  
        
    }  
}
@end
