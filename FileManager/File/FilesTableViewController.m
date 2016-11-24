//
//  FilesTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "FilesTableViewController.h"
#import "FilesListTableViewController.h"
#import "ScanViewController.h"
@interface FilesTableViewController ()
{
    NSArray        *_tableArray;
}

@end

@implementation FilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableArray = @[@{@"title":@"所有文件"},@{@"title":@"视频"},@{@"title":@"音频"},@{@"title":@"图片"},@{@"title":@"文档"},];
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightAddButtonAction:)];
         self.navigationItem.rightBarButtonItem = addBarButton;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
//                                      initWithTitle:@"扫扫" style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}
- (void)rightAddButtonAction:(UIBarButtonItem *)button {
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:@"在本目录下，新建一个文件夹" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    UITextField *textField = aler.textFields.firstObject;
    textField.placeholder = @"文件夹名称";
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"新建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (textField.text.length<=0) {
            
        }
        else
        {
          NSLog(@"==%@",textField.text);
        }
        
    }];
    [aler addAction:cancleAction];
    [aler addAction:addAction];
    [self presentViewController:aler animated:YES completion:nil];
    
}
- (void)leftScanButtonAction:(UIBarButtonItem *)button {
    ScanViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
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
    
    return _tableArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesCell" forIndexPath:indexPath];
    
    cell.textLabel.text = _tableArray[indexPath.row][@"title"];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FilesList"]) {
        FilesListTableViewController *filesList = segue.destinationViewController;
        filesList.fileType = 1;
        
    }
}
@end
