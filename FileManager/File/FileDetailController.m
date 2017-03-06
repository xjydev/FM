//
//  FileDetailController.m
//  FileManager
//
//  Created by xiaodev on Dec/22/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//修改名称，格式转换，面对面传，

#import "FileDetailController.h"
#import "XTools.h"
#import "UMMobClick/MobClick.h"

@interface FileDetailController ()
{
    
    __weak IBOutlet UILabel *_infoLabel;
}
@end

@implementation FileDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDetail];
    
}
- (void)getDetail {
    self.title = self.filePath.lastPathComponent;
    NSDictionary *dict = [kFileM attributesOfItemAtPath:self.filePath error:nil];
    
    NSString *nameStr = [NSString stringWithFormat:@"  文件名：%@\n",self.filePath.lastPathComponent];
    
    NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc]initWithString:nameStr attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
    
    
    float size =[[dict objectForKey:NSFileSize] floatValue];
    NSAttributedString *sizeStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"文件大小：%@\n ",[XTOOLS storageSpaceStringWith:size]] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}] ;
    [mstr appendAttributedString:sizeStr];

    
    NSDate *createDate = [dict objectForKey:NSFileCreationDate];
    NSString *createStr = [NSString stringWithFormat:@"创建时间：%@\n",[XTOOLS.dateFormater stringFromDate:createDate]];
    [mstr appendAttributedString:[[NSAttributedString alloc]initWithString:createStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}]];
    
    NSDate *modifiDate =[dict objectForKey:NSFileModificationDate];
    
    NSString *modifiTimeStr = [NSString stringWithFormat:@"上次修改：%@\n",[XTOOLS.dateFormater stringFromDate:modifiDate]];
    [mstr appendAttributedString:[[NSAttributedString alloc]initWithString:modifiTimeStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}]];
    
    NSString *path = [NSString stringWithFormat:@"文件路径：%@\n",[self.filePath substringFromIndex:KDocumentP.length]];
    [mstr appendAttributedString:[[NSAttributedString alloc]initWithString:path attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}]];
    NSString *fileTypeStr = nil;
    switch ([XTOOLS fileFormatWithPath:self.filePath]) {
        case FileTypeDefault:
        {
            fileTypeStr = @"文件类型：未知\n";
        }
            break;
        case FileTypeVideo:
        {
            fileTypeStr = @"文件类型：视频\n";
        }
            break;
        case FileTypeAudio:
        {
            fileTypeStr = @"文件类型：音频\n";
        }
            break;
        case FileTypeImage:
        {
            fileTypeStr = @"文件类型：图片\n";
        }
            break;
        case FileTypeDocument:
        {
            fileTypeStr = @"文件类型：文档\n";
        }
            break;
        case FileTypeFolder:
        {
            fileTypeStr = @"文件类型：文件夹\n";
        }
            break;
            
        default:
        {
            fileTypeStr = @"文件类型：未知\n";
        }
            break;
    }
    [mstr appendAttributedString:[[NSAttributedString alloc]initWithString:fileTypeStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];
    [paragraphStyle setParagraphSpacing:4];  //调整段间距
    [paragraphStyle setHeadIndent:80.0];
    [mstr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [mstr length])];
    
    
    _infoLabel.attributedText = mstr;
    NSLog(@"detail == %@ ",dict);
}
- (IBAction)converFormatButtonAction:(id)sender {
    
}
- (IBAction)newNameButtonAction:(id)sender {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"重新命名" message:@"请输入新的文件名称" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"文件名称";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            [XTOOLS showMessage:@"名称不能为空"];
            return ;
            
        }
        
        NSLog(@"==%@",textField.text);
        
        if ([kFileM fileExistsAtPath:self.filePath]) {
            
            NSMutableString *newPath = [NSMutableString stringWithString:self.filePath];
            NSString *oldName = [self.filePath lastPathComponent];
            NSString *formatStr = [self.filePath pathExtension];
            NSString *newName = [NSString stringWithFormat:@"%@.%@",textField.text,formatStr];
            NSRange oldrange = [newPath rangeOfString:oldName];
            [newPath replaceCharactersInRange:oldrange withString:newName];
//            [newPath stringByReplacingOccurrencesOfString:oldName withString:newName];
            NSError *error = nil;
            [kFileM moveItemAtPath:self.filePath toPath:newPath error:&error];
            if (error) {
              [XTOOLS showMessage:@"修改失败"];
            }
            else
            {
                self.filePath = newPath;
                [self getDetail];
                [XTOOLS showMessage:@"修改成功"];
            }
        }
        else
        {
            [XTOOLS showMessage:@"文件不存在"];
        }
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"fileDetail"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"fileDetail"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
