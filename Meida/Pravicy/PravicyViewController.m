//
//  PravicyViewController.m
//  FileManager
//
//  Created by xiaodev on Sep/9/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "PravicyViewController.h"
#import "UIView+xiao.h"
#import "ZipArchive.h"
#import "XTools.h"
#import "FileDetailController.h"
#import "PravicySettingController.h"

#import "EncryptDecryptManager.h"


@interface PravicyViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ZipArchiveDelegate>
{
    __weak IBOutlet UITableView *_mainTableView;
    __weak IBOutlet UISearchBar *_searchBar;
    
    NSMutableArray  *_filesArray;
    NSMutableArray  *_allFilesArray;
    
    
}
@property (nonatomic, strong)ZipArchive  *zipArchive;
@end

@implementation PravicyViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    PravicyViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"PravicyViewController"];
    return VC;
}
- (ZipArchive *)zipArchive {
    if (!_zipArchive) {
        _zipArchive = [[ZipArchive alloc]initWithFileManager:kFileM];
        _zipArchive.delegate = self;
    }
    return _zipArchive;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件加密";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"privacySet"] style:UIBarButtonItemStyleDone target:self action:@selector(rightShareBarButton)];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    _allFilesArray = [NSMutableArray arrayWithCapacity:0];
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    _searchBar.delegate = self;
    if (!self.filePath) {
        self.filePath = KDocumentP;
    }
    [self reloadFilesArray];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_searchBar.frame)-0.5, kScreen_Width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_searchBar addSubview:lineView];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [_mainTableView addSubview:refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadFilesArray) name:krefreshPravicyList object:nil];
}
- (void)refreshPullUp:(UIRefreshControl *)control {
    [self reloadFilesArray];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}
- (void)reloadFilesArray {
    NSError *error;
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.filePath error:&error];
    [_allFilesArray removeAllObjects];
    for (NSString *name in array) {
        
        if (![name hasPrefix:@"."] && [name hasSuffix:@".xn"]) {
            [_allFilesArray addObject:name];
        }
        
    }
    _filesArray = [NSMutableArray arrayWithArray:_allFilesArray];
    if (_filesArray.count == 0) {
        [_mainTableView xNoDataThisViewTitle:NSLocalizedString(@"NOfiles", nil) centerY:198];
    }
    else
    {
        [_mainTableView xRemoveNoData];
    }
    [_mainTableView reloadData];
 
}
- (void)leftGoBackButtonAction:(UIBarButtonItem *)bar {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightShareBarButton {
    [self performSegueWithIdentifier:@"PravicySettingController" sender:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pravicylistCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    UIButton *accessoryButton =(UIButton *)cell.accessoryView;
    [accessoryButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
    NSString *pathName = _filesArray[indexPath.row];
    cell.textLabel.text = pathName;
    switch ([XTOOLS fileFormatWithPath:pathName]) {
        case FileTypeFolder:
            [cell.imageView setImage:[UIImage imageNamed:@"file_folder"]];
            break;
        case FileTypeAudio:
            [cell.imageView setImage:[UIImage imageNamed:@"file_audio"]];
            break;
        case FileTypeImage:
            [cell.imageView setImage:[UIImage imageNamed:@"file_image"]];
            break;
        case FileTypeVideo:
            [cell.imageView setImage:[UIImage imageNamed:@"file_video"]];
            break;
        case FileTypeCompress:
            [cell.imageView setImage:[UIImage imageNamed:@"file_zip"]];
            break;
        case FileTypeDocument:
            [cell.imageView setImage:[UIImage imageNamed:@"file_document"]];
            break;
        default:
            [cell.imageView setImage:[UIImage imageNamed:@"file_unknow"]];
            break;
    }

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//
        NSError *error ;
        NSString *path = [self.filePath stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
//        [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
        
        [kFileM removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [self->_filesArray removeObjectAtIndex:indexPath.row];
        [self reloadFilesArray];
        
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"预览" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSString *path = [self.filePath stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
//        [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
        if ([XTOOLS fileFormatWithPath:path] == FileTypeFolder ) {//如果是文件就进入下一层
            
            PravicyViewController *pravicyList = [PravicyViewController allocFromStoryBoard];
            pravicyList.title = self->_filesArray[indexPath.row];
            
            pravicyList.filePath = [self.filePath stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
//            [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
            pravicyList.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pravicyList animated:YES];
            
        }
        else
          if ([XTOOLS fileFormatWithPath:path] == FileTypeCompress) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解压" message:@"是否解压此文件" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"解压" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //解压文件
                [self deCompressWithPath:path];
                
            }];
            [alert addAction:cancleAction];
            [alert addAction:unzipAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        }
        else
        {
            BOOL isPlay = [XTOOLS playFileWithPath:path OrigionalWiewController:self];
            if (!isPlay) {
                [XTOOLS showMessage:@"格式不支持预览"];
            }
        }

        
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction,editRowAction];//最后返回这俩个RowAction 的数组
}
- (void)deCompressWithPath:(NSString *)path {
    BOOL success = NO;
    if ([self.zipArchive UnzipOpenFile:path] ) {
        if ([self.zipArchive UnzipFileTo:self.filePath overWrite:YES]) {
            if ( [self.zipArchive UnzipCloseFile]) {
                success = YES;
                
            }
        }
    }
    if (success) {
        [XTOOLS showMessage:@"解压成功"];
        [self reloadFilesArray];
    }
    else
    {
        [XTOOLS showMessage:@"解压失败"];
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [self.filePath stringByAppendingPathComponent:_filesArray[indexPath.row]];
//    [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
    FileDetailController *detail = [FileDetailController allocFromStoryBoard];
    detail.filePath = path;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [self.filePath stringByAppendingPathComponent:_filesArray[indexPath.row]];
    //    [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
    if ([XTOOLS fileFormatWithPath:path] == FileTypeFolder ) {//如果是文件就进入下一层
        
        PravicyViewController *pravicyList = [PravicyViewController allocFromStoryBoard];
        pravicyList.title = _filesArray[indexPath.row];
        
        pravicyList.filePath = [self.filePath stringByAppendingPathComponent:_filesArray[indexPath.row]];
        //        [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
        pravicyList.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pravicyList animated:YES];
        
    }
    else
    {
        
        
        NSError *error ;
        if ([path hasSuffix:@".xn"]) {
            [[EncryptDecryptManager defaultManager]DecryptWithPath:path complete:^(BOOL result, NSString *fpath) {
                [XTOOLS hiddenLoading];
                if (result) {
                    [XTOOLS showMessage:@"解密成功"];
                    if (![kUSerD boolForKey:kRetain]) {
//                        [XTOOLS showAlertTitle:@"解密成功" message:@"是否删除原加密文件？" buttonTitles:@[NSLocalizedString(@"Cancel", nil),NSLocalizedString(@"Delete", nil)] completionHandler:^(NSInteger num) {
//                            if (num == 1) {
                                NSError *ferror;
                                [kFileM removeItemAtPath:path error:&ferror];
                                if (error) {
                                    NSLog(@"==%@",error);
                                }
                                NSLog(@"点击删除");
                                
//                            }
                            [self reloadFilesArray];
//                        }];
                    }
                    else
                    {
                        
                        [self reloadFilesArray];
                    }
                    
                }
                else
                {
                    [XTOOLS showMessage:fpath];
                }
                
            }];
            
            
        }
        else
        {
            
            [[EncryptDecryptManager defaultManager]EncryptWithPath:path complete:^(BOOL result, NSString *fpath) {
                [XTOOLS hiddenLoading];
                if (result) {
                    [XTOOLS showMessage:@"加密成功"];
                    if (![kUSerD boolForKey:kRetain]) {
                        
//                        [XTOOLS showAlertTitle:@"加密成功" message:@"是否删除原未加密文件？" buttonTitles:@[NSLocalizedString(@"Cancel", nil),NSLocalizedString(@"Delete", nil)] completionHandler:^(NSInteger num) {
//                            if (num == 1) {
                                NSError *ferror;
                                [kFileM removeItemAtPath:path error:&ferror];
                                if (error) {
                                    NSLog(@"==%@",error);
                                }
                                NSLog(@"点击删除");
                                
//                            }
                            [self reloadFilesArray];
//                        }];
                    }
                    else
                    {
            
                        [self reloadFilesArray];
                    }
                    
                }
                else
                {
                    [XTOOLS showMessage:fpath];
                }
            }];
            
        }
   
    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}
#pragma mark - searchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length>0) {
        [_filesArray removeAllObjects];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",_searchBar.text];
        for (NSString *s in _allFilesArray) {
            if ([pre evaluateWithObject:s]) {
                [_filesArray addObject:s];
            }
        }
    }
    else
    {
        _filesArray = [NSMutableArray arrayWithArray:_allFilesArray];
    }
    [_mainTableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar  {
    _filesArray = _allFilesArray;
    [_mainTableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
            
            [self->_mainTableView reloadData];
        }
        
        NSLog(@"==%@",textField.text);
        
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
}

@end
