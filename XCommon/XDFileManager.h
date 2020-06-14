//
//  XDFileManager.h
//  Pods-XDFile_Example
//
//  Created by XiaoDev on 2018/12/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//文件管理器
#define kFileM    [NSFileManager defaultManager]
//document路径
#define KDocumentP [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kCachesP [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kTmpP NSTemporaryDirectory()
#define kSubDokument(p) [[XDFileManager defaultManager] subStringDocumentPath:p]
typedef NS_ENUM(NSInteger , FileType) {
    FileTypeDefault,
    FileTypeVideo,
    FileTypeAudio,
    FileTypeImage,
    FileTypeDocument,
    FileTypeCompress,
    FileTypeFolder,
    FileTypemedia,
};
NS_ASSUME_NONNULL_BEGIN

@interface XDFileManager : NSObject

+ (instancetype)defaultManager;
/**
 判断文件类型
 
 @param path 文件路径
 @return 文件类型
 */
- (FileType)fileFormatWithPath:(NSString *)path;

/**
 把文件路径转换成主目录的路径，如果是主目录直接返回。

 @param path 原来的路径
 @return 主目录路径
 */
- (NSString *)prefixDocumentFilePath:(NSString *)path;

/**
 把文件路径转换成缓存的路径，如果是主目录直接返回。

 @param path 原来的路径
 @return 主目录路径
 */
- (NSString *)prefixCachesFilePaht:(NSString *)path;
- (NSArray *)foldersFromPath:(nullable NSString *)path;
- (UIColor *)fileMarkWithTag:(int)tag;
- (NSString *)fileMarkNameWithTag:(int)tag;

/**
 创建一个新的文件夹

 @param name 名称
 @return 是否创建成功
 */
- (BOOL)createNewFileName:(nullable NSString *)name WithPrexPath:(nullable NSString *)path type:(NSInteger)type;
- (NSInteger)folderTypeWithPath:(NSString *)path;
- (BOOL)setFolderType:(NSInteger)type WithPath:(NSString *)path;
- (BOOL)deleteFolderTypeWithPath:(NSString *)path;
- (NSString *)subStringDocumentPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
