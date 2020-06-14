//
//  AppInfoTableViewController.m
//  player
//
//  Created by XiaoDev on 2019/5/21.
//  Copyright © 2019 Xiaodev. All rights reserved.
//

#import "AppInfoTableViewController.h"
#import "WebViewController.h"
#import "XTools.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include "sys/stat.h"
@interface AppInfoTableViewController ()
@property (nonatomic, strong)NSArray *mainArray;
@end

@implementation AppInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"应用详情";
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self reloadAppInformationDetail];
    
}

#pragma mark - Table view data source
- (void)reloadAppInformationDetail {
    self.mainArray = @[@[@{@"title":@"应用名称",@"detail":@"简单播放"}],
                       @[@{@"title":@"应用版本",@"detail":APP_CURRENT_VERSION},
                         @{@"title":@"应用作者",@"detail":@"JingYuan Xiao"},
                        @{@"title":@"应用声明",@"detail":@"如果涉及侵权行为，请联系作者"},
                         @{@"title":@"隐私条款",@"detail":@"点击查看详情"},
                         @{@"title":@"使用条款",@"detail":@"点击查看详情"},
                         @{@"title":@"联系方式",@"detail":@"xiaodeve@163.com"}],
                       @[@{@"title":@"存储文件(可删除)",@"detail":[XTOOLS storageSpaceStringWith:[self folderSizeAtPath:KDocumentP]]},
                         @{@"title":@"应用缓存(可清除)",@"detail":[XTOOLS storageSpaceStringWith:([self folderSizeAtPath:kCachesP]+[self folderSizeAtPath:kTmpP])]}],
                       ];
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mainArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.mainArray[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appinfocell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"appinfocell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = self.mainArray[indexPath.section][indexPath.row];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = dict[@"detail"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _mainArray[indexPath.section][indexPath.row];
    if (indexPath.section == 1) {//隐私条款
        if ([dict[@"title"] isEqualToString:@"隐私条款"]) {
            WebViewController *webViewController = [[WebViewController alloc] init];
            webViewController.title = @"隐私条款";
            webViewController.urlStr = @"http://xiaodev.com/2018/09/06/privacy/";
            [self.navigationController pushViewController:webViewController animated:YES];
        }
        else if ([dict[@"title"] isEqualToString:@"使用条款"]) {
            WebViewController *webViewController = [[WebViewController alloc] init];
            webViewController.title = @"使用条款";
            webViewController.urlStr = @"http://xiaodev.com/2019/11/19/TermsOfUse/";
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    else
        if (indexPath.section == 2) {
            NSString *title = @"删除存储的文件";
            NSString *detail = @"您将删除应用内存储的全部文件，如果删除将无法恢复，是否继续删除？";
            if ([dict[@"title"] isEqualToString:@"存储文件(可删除)"]) {
                
            }
            else
                if ([dict[@"title"] isEqualToString:@"应用缓存(可清除)"]) {
                    title = @"清楚缓存";
                    detail = @"您将清楚应用内的缓存，如果清除一些文件可能需要重新加载，是否继续清除？";
                }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:detail preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *unzipAction =[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([dict[@"title"] isEqualToString:@"存储文件(可删除)"]) {
                    [XTOOLS showLoading:@"删除中"];
                    
                    NSArray *array=[kFileM contentsOfDirectoryAtPath:KDocumentP error:nil];
                    
                    for (int i=0; i<array.count; i++) {
                        [kFileM removeItemAtPath:[KDocumentP stringByAppendingPathComponent:[array objectAtIndex:i]] error:nil];
                        //                    [NSString stringWithFormat:@"%@/%@",KDocumentP,[array objectAtIndex:i]]
                    }
                    [XTOOLS hiddenLoading];
                    [self reloadAppInformationDetail];
                    [XTOOLS showMessage:@"删除完毕"];
                }
                else
                    if ([dict[@"title"] isEqualToString:@"应用缓存(可清除)"]) {
                        [XTOOLS showLoading:@"清除中"];
                        
                        NSArray *array=[kFileM contentsOfDirectoryAtPath:kCachesP error:nil];
                        
                        for (int i=0; i<array.count; i++) {
                            [kFileM removeItemAtPath:[kCachesP stringByAppendingPathComponent:[array objectAtIndex:i]] error:nil];
                            //NSString stringWithFormat:@"%@/%@",kCachesP,[array objectAtIndex:i]
                        }
                        
                        NSArray *array1=[kFileM contentsOfDirectoryAtPath:kTmpP error:nil];
                        
                        for (int i=0; i<array1.count; i++) {
                            [kFileM removeItemAtPath:[kTmpP stringByAppendingPathComponent:[array1 objectAtIndex:i]] error:nil];
                            //NSString stringWithFormat:@"%@/%@",kTmpP,[array1 objectAtIndex:i]
                        }
                        [XTOOLS hiddenLoading];
                        [self reloadAppInformationDetail];
                        [XTOOLS showMessage:@"清除完毕"];
                    }
                
            }];
            [alert addAction:cancleAction];
            [alert addAction:unzipAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
}
- (float )folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}
- (long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
    if ([XTOOLS showAdview]) {
        UIView *adView = [XTOOLS bannerAdViewRootViewController:self];
        adView.center = CGPointMake(kScreen_Width/2, CGRectGetHeight(self.view.frame) - 25 - KNavitionbarHeight);
        [self.view addSubview:adView];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
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


@end
