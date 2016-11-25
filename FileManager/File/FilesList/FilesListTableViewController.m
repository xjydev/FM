//
//  FilesListTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "FilesListTableViewController.h"
#import "VideoViewController.h"

@interface FilesListTableViewController ()
{
    NSArray   *_filesArray;
}
@end

@implementation FilesListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filesArray = @[@"111",@"222",@"333"];
    switch (self.fileType) {
        case FileTypeVideo:
            self.title = @"视频";
            break;
        case FileTypeAudio:
            self.title = @"音频";
            break;
        case FileTypeImage:
            self.title = @"图片";
            break;
        case FileTypeDocument:
            self.title = @"文档";
            break;
            
        default:
            self.title = @"文件";
            break;
    }
//    _filesArray = [kFileM enumeratorAtPath:KDocumentP];
   
    
    _filesArray = [kFileM subpathsOfDirectoryAtPath:KDocumentP error:nil];
    NSLog(@"file === %@",_filesArray);
    
    NSString *path = KDocumentP;
    NSDirectoryEnumerator *fileD = [kFileM enumeratorAtPath:path];
    NSLog(@"===%@",fileD);
    
    while (path = [fileD nextObject]) {
        NSLog(@"extend== %@",[path pathExtension]);
    }
    NSDirectoryEnumerator *fileDire = [kFileM enumeratorAtPath:KDocumentP];
    NSLog(@"enum == %@",fileDire);
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _filesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesListCell" forIndexPath:indexPath];
    
    cell.textLabel.text = _filesArray[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSString *path = [NSString stringWithFormat:@"%@/%@",KDocumentP,_filesArray[indexPath.row]];
    NSLog(@"path==%@",path);
//    NSDictionary *fileDict = [kFileM attributesOfItemAtPath:path error:nil];
//    
//    NSLog(@"type == %@",fileDict[NSFileType]);
  BOOL isPlay = [XTOOLS playFileWithPath:path OrigionalWiewController:self];
    if (!isPlay) {

    }
//    VideoViewController *video = [[VideoViewController alloc]init];
   
//    video.videoPath =path;
   
//    [self presentViewController:video animated:YES completion:nil];
//    [self.navigationController pushViewController:video animated:YES];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    return YES;
}


-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSLog(@"点击删除");
    }];
    //此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction, editRowAction];//最后返回这俩个RowAction 的数组
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
