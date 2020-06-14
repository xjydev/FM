//
//  FileModel.h
//  player
//
//  Created by XiaoDev on 2018/6/8.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject
@property (nonatomic, copy)   NSString *fileName;//文件名称
@property (nonatomic, assign) float     fileSize;//文件大小
@property (nonatomic, assign) float     fileProgress;//文件进度
@property (nonatomic, strong) NSDate   *addDate;//文件添加时间
@property (nonatomic, strong) NSDate   *lastOpenDate;//文件最后一次打开时间
@property (nonatomic, strong) NSString *filePath;//文件路径
@property (nonatomic, copy)   NSString *fileIcon;//文件图标缓存名称
@property (nonatomic, assign) NSInteger fileType;//文件类型
@end
