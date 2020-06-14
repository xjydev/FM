//
//  SortViewController.m
//  Wenjian
//
//  Created by xiaodev on Oct/19/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "SortViewController.h"
#import "XTools.h"
@interface SortViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *_mainTableView;
    NSMutableArray *_sortArray;
    
}
@end

@implementation SortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    _mainTableView.tableFooterView = [[UIView alloc]init];
    if ([kUSerD arrayForKey:kSort]) {
        _sortArray = [NSMutableArray arrayWithArray:[kUSerD arrayForKey:kSort]];
    }
    else
    {
        _sortArray = [NSMutableArray arrayWithObjects:@[@"名称",@"name",@"1"],@[@"标记",@"markInt",@"1"],
  @[@"文件类型",@"fileType",@"1"],
  @[@"文件大小",@"size",@"1"],
  @[@"浏览时间",@"modifyDate",@"1"],
  @[@"浏览进度",@"progress",@"1"],
   nil];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"排序" style:UIBarButtonItemStyleDone target:self action:@selector(sortAction)];
}
- (void)sortAction {
    if (_mainTableView.isEditing) {
        [self.navigationItem.rightBarButtonItem setTitle:@"排序"];
      [_mainTableView setEditing:NO animated:YES];
        [kUSerD setObject:_sortArray forKey:kSort];
        [kUSerD synchronize];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
        [_mainTableView setEditing:YES animated:YES];
    }
   
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sortArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sortViewcell" forIndexPath:indexPath];
    UIImageView *sortImageView = [cell viewWithTag:401];
    UILabel *sortLabel = [cell viewWithTag:402];
    NSArray *arr =  _sortArray[indexPath.row];
    sortLabel.text = arr[0];
    if ([arr.lastObject integerValue]==1) {
        sortImageView.transform = CGAffineTransformMakeRotation(0);
    }
    else
    {
        sortImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [_sortArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     UIImageView *sortImageView = [cell viewWithTag:401];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_sortArray[indexPath.row]];
                           
    if ([arr.lastObject integerValue]==1) {
        [arr replaceObjectAtIndex:2 withObject:@"0"];
        [UIView animateWithDuration:0.3 animations:^{
          sortImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
    else
    {
        [arr replaceObjectAtIndex:2 withObject:@"1"];
        [UIView animateWithDuration:0.3 animations:^{
            sortImageView.transform = CGAffineTransformMakeRotation(0);
        }];
    }
  
    [_sortArray replaceObjectAtIndex:indexPath.row withObject:arr];
    [kUSerD setObject:_sortArray forKey:kSort];
    [kUSerD synchronize];
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
