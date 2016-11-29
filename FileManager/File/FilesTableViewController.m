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
    
    UIBarButtonItem *transferBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"transfer"] style:UIBarButtonItemStyleDone target:self action:@selector(rightTransferButtonAction:)];
    self.navigationItem.rightBarButtonItem = transferBarButton;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
//                                      initWithTitle:@"扫扫" style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSLog(@"array === %@",array.firstObject);
}
- (void)rightTransferButtonAction:(UIButton *)button {
    UIViewController *transfer = [self.storyboard instantiateViewControllerWithIdentifier:@"TransferIPViewController"];
    [self.navigationController pushViewController:transfer animated:YES];
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
