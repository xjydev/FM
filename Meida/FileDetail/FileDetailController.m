//
//  FileDetailController.m
//  FileManager
//
//  Created by xiaodev on Dec/22/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//修改名称，格式转换，面对面传，

#import "FileDetailController.h"
#import "XTools.h"
#import "FaceConnectController.h"
#import "TransferIPViewController.h"
#import "EncryptDecryptManager.h"
#import "XYButton.h"
#import "XManageCoreData.h"
#import "RewardViewController.h"

@interface FileDetailController ()<UIDocumentInteractionControllerDelegate>
{
    
    __weak IBOutlet UILabel *_infoLabel;
    __weak IBOutlet UIButton *_encryptButton;//加密按钮
    __weak IBOutlet XYButton *_hidenButton;
}
@property (nonatomic) UIActivityViewController *activityViewController;
@property(nonatomic,strong)UIDocumentInteractionController *documentController;
@property (nonatomic, strong)Record *record;
@end

@implementation FileDetailController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    FileDetailController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"FileDetailController"];
    return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    if (![self.filePath hasPrefix:KDocumentP]) {
        self.filePath = [KDocumentP stringByAppendingPathComponent:self.filePath];
    }
    [self getDetail];
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.filePath]];
    self.documentController.delegate = self;
   
    
}
- (void)actionButtonPressed:(UIBarButtonItem *)sender {
//    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
//    NSMutableArray *items = [NSMutableArray arrayWithObject:data];
//    if (self.filePath) {
//        [items addObject:[self.filePath lastPathComponent]];
//    }
//    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.filePath] applicationActivities:nil];
//
//    // Show loading spinner after a couple of seconds
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if (self.activityViewController) {
//
//        }
//    });
//
//    // Show
//
//
//    self.activityViewController.popoverPresentationController.barButtonItem = sender;
//
//    [self presentViewController:self.activityViewController animated:YES completion:nil];
    BOOL canOpen = [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    if (!canOpen) {
        NSLog(@"沒有程序可以打開要分享的文件");
    }
}
- (void)getDetail {
    self.title = self.filePath.lastPathComponent;
    NSDictionary *dict = [kFileM attributesOfItemAtPath:self.filePath error:nil];
    self.record = [[XManageCoreData manageCoreData]createRecordWithPath:self.filePath];
    NSString *hName = self.filePath.lastPathComponent;
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    if (![bundleName isEqualToString:@"FileManager"]) {//只有简单文件有这个功能
        if ([hName hasPrefix:@"."]) {
            [_hidenButton setTitle:@"去除隐藏" forState:UIControlStateNormal];
        }
        else {
            [_hidenButton setTitle:@"隐藏文件" forState:UIControlStateNormal];
        }
    }
    else {
        _hidenButton.hidden = YES;
    }
    if ([self.filePath hasSuffix:@".xn"]) {
        [_encryptButton setTitle:@"解密" forState:UIControlStateNormal];
    }
    else
    {
        [_encryptButton setTitle:@"加密" forState:UIControlStateNormal];
    }
    NSString *nameStr = [NSString stringWithFormat:@"  文件名：%@\n",self.filePath.lastPathComponent];
    
    NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc]initWithString:nameStr attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
    
    
    float size =[[dict objectForKey:NSFileSize] floatValue];
    if (self.filePath.pathExtension.length == 0) {
        size = [XTOOLS folderSizeAtPath:self.filePath];
    }
    NSAttributedString *sizeStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"文件大小：%@\n",[XTOOLS storageSpaceStringWith:size]] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}] ;
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
- (IBAction)pcTransferButtonAction:(id)sender {
    TransferIPViewController *ipview = [TransferIPViewController allocFromStoryBoard];
    [self.navigationController pushViewController:ipview animated:YES];
}
- (IBAction)converFormatButtonAction:(id)sender {
    FaceConnectController *connect = [FaceConnectController allocFromStoryBoard];
    connect.filePath = self.filePath;
    [self.navigationController pushViewController:connect animated:YES];
}
- (IBAction)newNameButtonAction:(id)sender {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"重新命名" message:@"请输入新的文件名称" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"文件名称";
    textField.text = self.filePath.lastPathComponent;
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            [XTOOLS showMessage:@"名称不能为空"];
            return ;
            
        }
        if ([textField.text isEqualToString:self.filePath.lastPathComponent]) {
            return;
        }
        NSLog(@"==%@",textField.text);
        
        if ([kFileM fileExistsAtPath:self.filePath]) {
            
            NSMutableString *newPath = [NSMutableString stringWithString:self.filePath];
            NSString *oldName = [self.filePath lastPathComponent];
            NSString *formatStr = [self.filePath pathExtension];
            NSString *newName;
            if (![textField.text hasSuffix:formatStr] && formatStr.length>0) {
              newName = [NSString stringWithFormat:@"%@.%@",textField.text,formatStr];
            }
            else
            {
               newName = textField.text;
            }
            
            NSRange oldrange = [newPath rangeOfString:oldName];
            [newPath replaceCharactersInRange:oldrange withString:newName];
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
        else {
            [XTOOLS showMessage:@"文件不存在"];
        }
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}
- (IBAction)hiddenButtonAction:(id)sender {
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *title = @"订阅功能";
    NSString *message = @"文件隐藏是订阅功能，订阅会员后才可以使用。";
    NSString *btnStr = @"去订阅";
    NSString *alertStr = @"可以在订阅界面查看隐藏文件,在隐藏文件的详情中可以去除隐藏。";
    if (![bundleName isEqualToString:@"Wenjian"]){
        title = @"付费功能";
        message = @"文件隐藏是付费功能，付费后可以永久使用。";
        btnStr = @"去付费";
        alertStr = @"可以在去除广告中查看隐藏文件,在隐藏文件的详情中可以去除隐藏。";
        }
    if (![kUSerD objectForKey:kENTRICY]) {
        
           [XTOOLS showAlertTitle:title message:message buttonTitles:@[@"取消",btnStr] completionHandler:^(NSInteger num) {
               if (num == 1) {
                   RewardViewController *VC = [RewardViewController allocFromStoryBoard];
                   [self.navigationController pushViewController:VC animated:YES];
               }
           }];
           return;
       }
    NSString *oldPath = self.filePath;
    if (![oldPath hasPrefix:KDocumentP]) {
        oldPath = [KDocumentP stringByAppendingPathComponent:self.filePath];
    }
    if ([kFileM fileExistsAtPath:oldPath]) {
        NSMutableString *newPath = [NSMutableString stringWithString:oldPath];
        NSString *oldName = [self.filePath lastPathComponent];
        NSString *newName ;
        if ([oldName hasPrefix:@"."]) {
            newName = [oldName substringFromIndex:1];
            while ([newName hasSuffix:@"."]) {
                newName = [newName substringFromIndex:1];
            }
        }
        else {
            newName = [NSString stringWithFormat:@".%@",oldName];
        }
        
        NSRange oldrange = [newPath rangeOfString:oldName];
        [newPath replaceCharactersInRange:oldrange withString:newName];
        NSError *error = nil;
        [kFileM moveItemAtPath:oldPath toPath:newPath error:&error];
        if (error) {
            [XTOOLS showMessage:@"发生错误"];
        }
        else {
            self.filePath = newPath;
            self.record.name = newName.lastPathComponent;
            NSString *storePath = kSubDokument(newPath);
            
            self.record.path = storePath;
            [[XManageCoreData manageCoreData]saveRecord:self.record];
            [kNOtificationC postNotificationName:kRefreshList object:nil];
            if ([self.record.name hasPrefix:@"."]) {
                
                if ([kUSerD boolForKey:@"khhiden"]) {
                    [XTOOLS showMessage:@"隐藏成功"];
                }
                else
                {
                    [XTOOLS showAlertTitle:@"隐藏成功" message:alertStr buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                        [kUSerD setBool:YES forKey:@"khhiden"];
                        [kUSerD synchronize];
                    }];
                }
            }
            else
            {
                [XTOOLS showMessage:@"已去除隐藏"];
            }
            [self getDetail];
        }
    }
    else {
        [XTOOLS showMessage:@"文件不存在"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    if ([XTOOLS showAdview]) {
        UIView *adView = [XTOOLS bannerAdViewRootViewController:self];
        adView.center = CGPointMake(kScreen_Width/2, kScreen_Height - 25);
        [self.view addSubview:adView];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (IBAction)encryptButtonAction:(id)sender {
   
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *title = @"订阅功能";
    NSString *message = @"文件加密是订阅功能，订阅会员后才可以使用。";
    NSString *btnStr = @"去订阅";
    NSString *alertStr = @"可以在订阅界面查看隐藏文件,在隐藏文件的详情中可以去除隐藏。";
    if (![bundleName isEqualToString:@"Wenjian"]){
        title = @"付费功能";
        message = @"文件加密是付费功能，付费后可以永久使用。";
        btnStr = @"去付费";
        alertStr = @"可以在去除广告中查看隐藏文件,在隐藏文件的详情中可以去除隐藏。";
        }
    
    if (![kUSerD objectForKey:kENTRICY]) {
        [XTOOLS showAlertTitle:title message:message buttonTitles:@[@"取消",btnStr] completionHandler:^(NSInteger num) {
            if (num == 1) {
                RewardViewController *VC = [RewardViewController allocFromStoryBoard];
                [self.navigationController pushViewController:VC animated:YES];
            }
        }];
        return;
    }
        NSError *error;
        if ([self.filePath hasSuffix:@".xn"]) {
            [[EncryptDecryptManager defaultManager]DecryptWithPath:self.filePath complete:^(BOOL result, NSString *fpath) {
                if (result) {
                    [XTOOLS showMessage:@"解密成功"];
                    if (![kUSerD boolForKey:kRetain]) {
//                        [XTOOLS showAlertTitle:@"解密成功" message:@"是否删除原加密文件？" buttonTitles:@[NSLocalizedString(@"Cancel", nil),NSLocalizedString(@"Delete", nil)] completionHandler:^(NSInteger num) {
//                            if (num == 1) {
                                NSError *ferror;
                                [kFileM removeItemAtPath:self.filePath error:&ferror];
                                if (error) {
                                    NSLog(@"==%@",error);
//                                    [XTOOLS showMessage:@"删除失败"];
                                }
                                NSLog(@"点击删除");
                                
//                            }
                        self.filePath = fpath;
                        [self getDetail];
                        [self refreshFilesList];
//                        }];
                        
                    }
                    else {
                        [self refreshFilesList];
                    }
                }
                else {
                    [XTOOLS showMessage:@"解密失败"];
                }
          }];
        }
        else
        {
            [[EncryptDecryptManager defaultManager]EncryptWithPath:self.filePath complete:^(BOOL result, NSString *fpath) {
                if (result) {
                    [XTOOLS showMessage:@"加密成功"];
                    if (![kUSerD boolForKey:kRetain]) {
//                        [XTOOLS showAlertTitle:@"加密成功" message:@"是否删除原未加密文件？" buttonTitles:@[NSLocalizedString(@"Cancel", nil),NSLocalizedString(@"Delete", nil)] completionHandler:^(NSInteger num) {
//                            if (num == 1) {
                                NSError *ferror;
                                [kFileM removeItemAtPath:self.filePath error:&ferror];
                                if (error) {
                                    NSLog(@"==%@",error);
                                }
                                NSLog(@"点击删除");
                                
//                            }
                        self.filePath = fpath;
                        [self getDetail];
                        [self refreshFilesList];
//                        }];
                    }
                    else {
                        [self refreshFilesList];
                    }
                }
                else {
                    [XTOOLS showMessage:fpath];
                }
            }];
        }
}
- (void)refreshFilesList {
    [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshList object:nil];
}
//设置密码
- (void)createNewPassWord {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"设置密码" message:@"请输入加密解密密码" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"加密密码";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            [XTOOLS showMessage:@"密码不能为空"];
            return ;
        }
        else
        {
            if ([XTOOLS getPravicyPassWord]) {
                [XTOOLS showMessage:@"已有密码"];
            }
            else
            {
                [XTOOLS showMessage:@"设置成功"];
                [XTOOLS savePravicyPassword:textField.text];
            }
        }
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
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
