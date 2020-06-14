//
//  MarkViewController.m
//  Wenjian
//
//  Created by xiaodev on Aug/21/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "MarkViewController.h"
#import "XManageCoreData.h"
#import "XTools.h"
#import "FilesTableCell.h"
#import "UIView+xiao.h"
//#import "UIViewController+JY.h"
@interface MarkViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *_mainTableView;
}
@property (nonatomic, strong)NSMutableArray *markArray;
@end

@implementation MarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setleftBackButton];
    [XTOOLS umengClick:@"markv"];
    _markArray = [NSMutableArray arrayWithArray:[[XManageCoreData manageCoreData]getAllMarkFiles]];
    if (_markArray.count == 0) {
        [_mainTableView xNoDataThisViewTitle:@"没有标记文件" centerY:198];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _markArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilesTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"marklistcell1" forIndexPath:indexPath];
    Record *model = _markArray[indexPath.row];
    cell.fileModel = model;
    return cell;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        Record *model = self.markArray[indexPath.row];
        model.markInt = @(0);
        if ([[XManageCoreData manageCoreData]saveRecord:model]) {
            [self.markArray removeObject:model];
            if (self.markArray.count == 0) {
                [self->_mainTableView xNoDataThisViewTitle:@"没有标记文件" centerY:198];
            }
        }
        else
        {
            [XTOOLS showMessage:@"删除失败"];
        }
        [tableView reloadData];
    }];
    
    return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
