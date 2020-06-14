//
//  XDFileManager.m
//  Pods-XDFile_Example
//
//  Created by XiaoDev on 2018/12/2.
//

#import "XDFileManager.h"
#import "XManageCoreData.h"
@interface XDFileManager ()

@property (nonatomic, strong)NSArray * videoFormatArray;
@property (nonatomic, strong)NSArray * audioFormatArray;
@property (nonatomic, strong)NSArray * imageFormatArray;
@property (nonatomic, strong)NSArray * documentFormatArray;
@property (nonatomic, strong)NSArray * compressFormatArray;

@end

@implementation XDFileManager
+ (instancetype)defaultManager {
    static XDFileManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XDFileManager alloc] init];
        
    });
    return instance;
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
        _videoFormatArray = @[@"rmvb",@"asf",@"avi",@"divx",@"flv",@"m2ts",@"m4v",@"mkv",@"mov",@"mp4",@"ps",@"ts",@"vob",@"wmv",@"dts",@"swf", @"dv",@"gxf",@"m1v",@"m2v",@"mpeg",@"mpeg1",@"mpeg2",@"mpeg4",@"mpg",@"mts",@"mxf",@"ogm",@"a52",@"mka",@"mod",@"caf",@"rm",@"webm"];
    }
    return _videoFormatArray;
}
- (NSArray *)audioFormatArray {
    //    mp3 wma wav ac3 eac3 aac flac ape, cue, amr, ogg vorbis
    if (!_audioFormatArray) {
        _audioFormatArray = @[@"mp3",@"ogg",@"wav",@"ac3",@"eac3",@"ape",@"cda",@"au",@"midi",@"mac",@"aac",@"f4v",@"wma",@"flac",@"cue",@"amr",@"vorbis",@"m4p",@"mp1",@"mp2",@"m4a"];
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
- (FileType )fileFormatWithPath:(NSString *)path {
    if (path.length == 0) {
        return FileTypeDefault;
    }
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
- (NSString *)prefixDocumentFilePath:(NSString *)path {
    if ([path hasPrefix:KDocumentP]) {
        return path;
    }
    else if ([path hasPrefix:kCachesP]) {
        path = [path substringFromIndex:kCachesP.length];
    }
    return [KDocumentP stringByAppendingPathComponent:path];
}
- (NSString *)prefixCachesFilePaht:(NSString *)path {
    if ([path hasPrefix:kCachesP]) {
        return path;
    }
    else if ([path hasPrefix:KDocumentP]) {
        path = [path substringFromIndex:KDocumentP.length];
    }
    return [kCachesP stringByAppendingPathComponent:path];
}
- (NSArray *)foldersFromPath:(nullable NSString *)path {
    if (!path) {
        path = KDocumentP;
    }
    NSArray *fileArray = [kFileM contentsOfDirectoryAtPath:path error:nil];
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        
        NSRange range = NSMakeRange(0,obj1.length);
        
        return [obj1 compare:obj2 options:(NSWidthInsensitiveSearch|NSNumericSearch) range:range];
        
    };
    NSArray *resultArray = [fileArray sortedArrayUsingComparator:sort];
    NSMutableArray *fArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    BOOL isFolder = NO;
    for (NSString *folderPath in resultArray) {
        [kFileM fileExistsAtPath:[path stringByAppendingPathComponent:folderPath] isDirectory:&isFolder];
        
        if (isFolder&&![folderPath hasPrefix:@"."]) {
            NSInteger type = [self folderTypeWithPath:folderPath];
            [fArray addObject:@{@"title":folderPath.lastPathComponent,@"type":@(type)}];
        }
    }
    return fArray;
}
- (UIColor *)fileMarkWithTag:(int)tag {
    switch (tag) {
        case 0:
            return [UIColor clearColor];
            break;
        case 1:
            return [UIColor redColor];
            break;
        case 2:
            return [UIColor orangeColor];
            break;
        case 3:
            return [UIColor greenColor];
            break;
        case 4:
            return [UIColor blueColor];
            break;
        case 5:
            return [UIColor magentaColor];
            break;
        case 6:
            return [UIColor grayColor];
            break;
            
        default:
            return [UIColor clearColor];
            break;
    }
}
- (NSString *)fileMarkNameWithTag:(int)tag {
    switch (tag) {
        case 0:
            return @"无";
            break;
        case 1:
            return @"红色";
            break;
        case 2:
            return @"橙色";
            break;
        case 3:
            return @"绿色";
            break;
        case 4:
            return @"蓝色";
            break;
        case 5:
            return @"品红";
            break;
        case 6:
            return @"灰色";
            break;
            
        default:
            return @"无";
            break;
    }
}
- (BOOL)createNewFileName:(nullable NSString *)name WithPrexPath:(nullable NSString *)path type:(NSInteger)type{
    
    if (name.length == 0) {
        name = @"新建文件夹";
    }
    if (path.length == 0) {
        path = KDocumentP;
    }
    NSString *lpath = [path stringByAppendingPathComponent:name];
    NSString *newPath = lpath;
    int num = 0;
    while ([kFileM fileExistsAtPath:newPath]) {
        num ++;
        newPath = [NSString stringWithFormat:@"%@%d",lpath,num];
    }
    BOOL b = [kFileM createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (b) {
        [self setFolderType:type WithPath:newPath];
    }
    return b;
}
- (NSInteger)folderTypeWithPath:(NSString *)path {
    
    path = kSubDokument(path);
    
    Record *model = [[XManageCoreData manageCoreData]getRecordObjectWithPath:path];
    NSLog(@"path == %@  ===  %@",path,model.progress);
    return model.progress.integerValue;
    
}
- (BOOL)setFolderType:(NSInteger)type WithPath:(NSString *)path {
    path = kSubDokument(path);
    Record *model = [[XManageCoreData manageCoreData]createRecordWithPath:path];
    model.progress = @(type);
    NSLog(@"创建的文件类型是    ==== %@",@(type));
   return [[XManageCoreData manageCoreData]saveRecord:model];
}
- (BOOL)deleteFolderTypeWithPath:(NSString *)path {
    path = kSubDokument(path);
    return [[XManageCoreData manageCoreData]deleteRecordPath:path];
}
- (NSString *)subStringDocumentPath:(NSString *)path {
    if ([path hasPrefix:KDocumentP]) {
        path = [path substringFromIndex:KDocumentP.length];
    }
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    return path;
    
}
@end

