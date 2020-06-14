//
//  WebListTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "WebListTableViewController.h"
#import "ScanViewController.h"
#import "SVWebViewController.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import "UIView+xiao.h"
#import "XManageCoreData.h"
#import "WebCollector+CoreDataClass.h"
//#import "DownloadViewController.h"
#import <AFNetworking/AFNetworking.h>
@interface WebListTableViewController ()<UITextFieldDelegate,UISearchBarDelegate>
{
    NSMutableArray   *_webArray;
    
    NSMutableArray   *_searchArray;
    UISearchController *_searchController;
    UISearchBar        *_searchBar;
    UIBarButtonItem    *_rightBar;
    UIBarButtonItem    *_leftBar;

}
@end

@implementation WebListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//downLoad
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未连接网络" message:@"连接网络，才能搜索和访问网页，是否检查应用网络设置？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                
                //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
            }];
            [alert addAction:cancleAction];
            [alert addAction:sureAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
        [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    }];

    
    _leftBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
    self.navigationItem.leftBarButtonItem = _leftBar;
    _rightBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"downLoad"] style:UIBarButtonItemStyleDone target:self action:@selector(rightDownLoadButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBar;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width - 80, 40)];
    _searchBar.barTintColor = kNavCOLOR;
    _searchBar.placeholder = @"搜索或输入网址";
    [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _searchBar.keyboardType = UIKeyboardTypeURL;
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    [self getWebListData];
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
//    [XTOOLS choose18year];
    
}
- (void)refreshPullUp:(UIRefreshControl *)refresh {
    [self getWebListData];
    [self performSelector:@selector(endRefresh:) withObject:refresh afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}

- (void)getWebListData {
    _webArray = [NSMutableArray arrayWithArray:[[[[XManageCoreData manageCoreData]getAllWebUrl]reverseObjectEnumerator]allObjects]];
    if (_webArray.count!=0) {
        [self.tableView xRemoveNoData];
    }
    else
    {
        [self.tableView xNoDataThisViewTitle:@"无收藏网页" centerY:198];
    }
    [self.tableView reloadData];
}
- (void)leftScanButtonAction:(UIBarButtonItem *)item {
    ScanViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
}
//- (void)rightDownLoadButtonAction:(UIBarButtonItem *)item {
//    DownloadViewController *filesList = [self.storyboard instantiateViewControllerWithIdentifier:@"DownloadViewController"];
//    filesList.title = @"下载";
//    filesList.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:filesList animated:YES];
//}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"===%@",text);
    if ([text isEqualToString:@"\n"]&&searchBar.text.length>0) {
        
        [self gotoWebWithSearchText:_searchBar.text];
    }
    return YES;
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

    return _webArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    WebCollector *object = _webArray[indexPath.row];
    cell.textLabel.text = object.title;
    [cell.imageView setImage:[UIImage imageNamed:@"collect"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebCollector *object = _webArray[indexPath.row];
    [self pushWebDetailWithurl:object.url];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
         WebCollector *object = _webArray[indexPath.row];

        if ([[XManageCoreData manageCoreData]deleteWeb:object]) {
            [_webArray removeObject:object];
        }
        if (_webArray.count == 0) {
            [self.tableView xRemoveNoData];
        }
        [self.tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
-(void)gotoWebWithSearchText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    [_searchBar resignFirstResponder];

    //如果不是网址无法打开就百度搜索
     if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:text]]) {
         if ([text hasSuffix:@".com"]||[text hasSuffix:@".cn"]||[text hasPrefix:@"www."]||[text hasSuffix:@".net"]) {
             if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",text]]]) {
                 text = [NSString stringWithFormat:@"http://%@",text];
             }
             else
                 if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",text]]]) {
                     text = [NSString stringWithFormat:@"https://%@",text];
                 }
  
         }
      else
         {
             NSString *encodedString = (NSString *)
             CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                       (CFStringRef)text,
                                                                       NULL,
                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                       kCFStringEncodingUTF8));
             text =[NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",encodedString];
         }
         
     }
    [self pushWebDetailWithurl:text];
}
- (void)pushWebDetailWithurl:(NSString *)url{
    SVWebViewController *webViewController = [[SVWebViewController alloc] init];
    webViewController.urlStr = url;
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.backRefreshData = ^(NSInteger state){
        [self getWebListData];
    };
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
}

@end
