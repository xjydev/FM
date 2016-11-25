//
//  PreferencesTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/25/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "PreferencesTableViewController.h"
#import "XTools.h"
@interface PreferencesTableViewController ()
{
    NSArray     *_mainArray;
}
@end

@implementation PreferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainArray = @[@[@{@"title":@"屏幕旋转",@"subTitle":@"应用的所有界面是否支持转屏",@"tag":@"0"},],];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mainArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_mainArray[section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preferencesCell" forIndexPath:indexPath];
    cell.textLabel.text = _mainArray[indexPath.section][indexPath.row][@"title"];
    cell.detailTextLabel.text = _mainArray[indexPath.section][indexPath.row][@"subTitle"];
    UISwitch *switchView = [cell.contentView viewWithTag:301];
    if (switchView) {
        if (switchView.allTargets.count==0) {
            [switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
        }
        switchView.on = XTOOLS.isCanRotation;
    }
   
    
    return cell;
}
- (void)swithAction:(UISwitch *)switchView {
    UITableViewCell *cell = (UITableViewCell *)switchView.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch ([_mainArray[indexPath.section][indexPath.row][@"tag"] integerValue]) {
        case 0:
        {
            XTOOLS.isCanRotation = switchView.on;
            [kUSerD setObject:[NSNumber numberWithBool:XTOOLS.isCanRotation] forKey:userRotationKey];
        }
            break;
            
        default:
            break;
    }
    
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

@end
