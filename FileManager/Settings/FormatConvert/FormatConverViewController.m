//
//  FormatConverViewController.m
//  FileManager
//
//  Created by xiaodev on Jan/10/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "FormatConverViewController.h"
#import "FormatConver.h"
#import "UIColor+Hex.h"
#import "FilesListController.h"
#import "FileDetailController.h"
#import <AVFoundation/AVFoundation.h>
@interface FormatConverViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
{
    
    __weak IBOutlet UITableView *_mainTableView;
    __weak IBOutlet UIButton *_convertButton;
    __weak IBOutlet UIPickerView *_pickerView;
    __weak IBOutlet UIView *_pickerBackView;
    NSArray        *_mainArray;
    NSString       *_filePath;
    NSString       *_convertedPath;
    NSDictionary   *_formatDict;
    NSDictionary   *_qualityDict;
    NSArray        *_formatArray;
    NSArray        *_qualityArray;
    BOOL            _isPickerFormat;
}
@end

@implementation FormatConverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"格式转换";
    _convertButton.layer.borderColor = kMainCOLOR.CGColor;
    _convertButton.layer.borderWidth = 1.0;
    _convertButton.layer.cornerRadius = 20;
    _convertButton.layer.masksToBounds = YES;
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;

    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _mainArray = @[@[@"选择文件：",@"转换后格式：",@"转换后质量："]];
    _qualityDict =@{@"大小适中质量不变":AVAssetExportPresetMediumQuality};
    _formatDict = @{@"mp4":AVFileTypeMPEG4};
    
    UILabel *alertHeaderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    alertHeaderLabel.textAlignment = NSTextAlignmentCenter;
    alertHeaderLabel.textColor = [UIColor redColor];
    alertHeaderLabel.numberOfLines = 0;
    alertHeaderLabel.text = @"此功能只支持少数的格式转换，可以尝试是否满足您的需求";
    alertHeaderLabel.font = [UIFont systemFontOfSize:14];
    _mainTableView.tableHeaderView = alertHeaderLabel;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mainArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = _mainArray[section];
    return arr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"formatconvercell" forIndexPath:indexPath];
    cell.textLabel.text = _mainArray[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                if (_filePath) {
                    cell.detailTextLabel.text = [_filePath lastPathComponent];
                }
                else
                {
                    cell.detailTextLabel.text = @"选择文件";
                }
            }
                break;
            case 1:
            {
                if (_formatDict.allKeys.count>0) {
                    cell.detailTextLabel.text = _formatDict.allKeys[0];
                }
            }
                break;
            case 2:
            {
                if (_qualityDict.allKeys.count>0) {
                    cell.detailTextLabel.text = _qualityDict.allKeys[0];
                }
            }
                break;
                
            default:
                break;
        }
    }
    else
        
    if (indexPath.section == 1) {
        if (_convertedPath) {
            cell.detailTextLabel.text =[_convertedPath lastPathComponent];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                FilesListController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesListController"];
                filesList.isSelected = YES;
                filesList.fileType = FileTypeAudio|FileTypeVideo;
                filesList.title = @"选择文件";
                filesList.selectedPath = ^(NSString *path){
                    _filePath = path;
                    [_mainTableView reloadData];
                };
                [self.navigationController pushViewController:filesList animated:YES];
            }
                break;
            case 1:
            {
                _isPickerFormat = YES;
                if (!_formatArray) {
                    _formatArray = @[@{@"mov":AVFileTypeQuickTimeMovie},
                                     @{@"mp4":AVFileTypeMPEG4},
                                     @{@"m4v":AVFileTypeAppleM4V},
                                     @{@"m4a":AVFileTypeAppleM4A},
                                     @{@"3gpp":AVFileType3GPP},
                                     @{@"3gpp2":AVFileType3GPP2},
                                     @{@"caf":AVFileTypeCoreAudioFormat},
                                     @{@"wav":AVFileTypeWAVE},
                                     @{@"aif":AVFileTypeAIFF},
                                     @{@"aifc":AVFileTypeAIFC},
                                     @{@"amr":AVFileTypeAMR},
                                     @{@"mp3":AVFileTypeMPEGLayer3},
                                     @{@"au":AVFileTypeSunAU},
                                     @{@"ac3":AVFileTypeAC3},
                                     @{@"eac3":AVFileTypeEnhancedAC3},];
                }
                [_pickerView reloadAllComponents];
                _pickerBackView.hidden = NO;
            }
                break;
            case 2:
            {
                _isPickerFormat = NO;
                if (!_qualityArray) {
                    _qualityArray = @[@{@"占存略大，高质量输出":AVAssetExportPresetHighestQuality},
                                     @{@"质量不变，正常输出":AVAssetExportPresetMediumQuality},
                                     @{@"压缩大小,低质量输出":AVAssetExportPresetLowQuality},];
                }
                
                _pickerBackView.hidden = NO;
                [_pickerView reloadAllComponents];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    FileDetailController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"FileDetailController"];
    detail.filePath = _convertedPath;
    [self.navigationController pushViewController:detail animated:YES];
}
- (IBAction)formatConvertButtonAction:(UIButton *)sender {
    if (_filePath) {
        [sender setTitle:@"重新转换" forState:UIControlStateNormal];
        _convertButton.selected = YES;
        _convertButton.userInteractionEnabled = NO;
        [self formartConvertBegan];
    }
    else
    {
        [XTOOLS showMessage:@"选择文件"];
    }
    
   
}
#pragma mark -- 格式转换convert
- (void)formartConvertBegan {
    [XTOOLS showLoading:@"开始转换"];
    NSURL *sourceUrl = [NSURL fileURLWithPath:_filePath];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"11%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:_qualityDict.allValues[0]];
        
        
        NSMutableString *resultPath = [NSMutableString stringWithString:_filePath];
        NSRange extension = [resultPath rangeOfString:[resultPath pathExtension]];
        [resultPath replaceCharactersInRange:extension withString:_formatDict.allKeys[0]];
        
        //        NSString * resultPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:uniqueName];//PATH_OF_DOCUMENT为documents路径
        
        NSLog(@"output File Path : %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType =AVFileTypeMPEG4;//可以配置多种输出文件格式
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             
             switch (exportSession.status) {
                     
                 case AVAssetExportSessionStatusUnknown:
                     [XTOOLS showMessage:@"转换出错"];
                     
                                          NSLog(@"AVAssetExportSessionStatusUnknown");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Unknown", 0.8); //自定义错误提示信息
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     [XTOOLS showLoading:@"正在等待"];
                                          NSLog(@"AVAssetExportSessionStatusWaiting");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Waiting", 0.8);
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     [XTOOLS showLoading:@"正在输出"];
                                          NSLog(@"AVAssetExportSessionStatusExporting");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Exporting", 0.8);
                     
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                 {
                     
                                          NSLog(@"AVAssetExportSessionStatusCompleted");
                     
                     
                     if ([kFileM fileExistsAtPath:resultPath]) {
                        _convertedPath = resultPath;
                         _mainArray = @[@[@"选择文件：",@"转换后格式：",@"转换后质量："],@[@"转换后文件："]];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             _convertButton.selected = NO;
                             _convertButton.userInteractionEnabled = YES;
                             [_mainTableView reloadData];
                             [XTOOLS hiddenLoading];
                             [XTOOLS showMessage:@"转化完成"];
                         });
                     }
                     
                     NSLog(@"mp4 file size:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
                 }
                     break;
                     
                 case AVAssetExportSessionStatusFailed:
                     [XTOOLS showMessage:@"转换出错"];
                     _convertButton.selected = NO;
                     _convertButton.userInteractionEnabled = YES;
                                          NSLog(@"AVAssetExportSessionStatusFailed");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Unknown", 0.8);
                     
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     [XTOOLS showMessage:@"转换取消"];
                     _convertButton.selected = NO;
                     _convertButton.userInteractionEnabled = YES;
                                          NSLog(@"AVAssetExportSessionStatusFailed");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Cancelled", 0.8);
                     
                     break;
                     
             }  
             
         }];  
        
    }  

}
#pragma mark -- PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_isPickerFormat) {
        return _formatArray.count;
    }
    else
    {
        return _qualityArray.count;
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (_isPickerFormat) {
        NSDictionary *dict = _formatArray[row];
        return dict.allKeys[0];
    }
    else
    {
        NSDictionary *dict = _qualityArray[row];
        return dict.allKeys[0];
    }
}

- (IBAction)pickerCommitButtonAction:(id)sender {
    _pickerBackView.hidden = YES;
    if (_isPickerFormat) {
        _formatDict = _formatArray[[_pickerView selectedRowInComponent:0]];
    }
    else
    {
       _qualityDict = _qualityArray[[_pickerView selectedRowInComponent:0]];
    }
    [_mainTableView reloadData];
}
- (IBAction)pickerCancelButton:(id)sender {
    _pickerBackView.hidden = YES;
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
