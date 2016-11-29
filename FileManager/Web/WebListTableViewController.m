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
@interface WebListTableViewController ()<UITextFieldDelegate,UISearchBarDelegate>
{
    NSMutableArray   *_webArray;
//    UITextField      *_searchField;
    
    NSMutableArray   *_searchArray;
    UISearchController *_searchController;
    UISearchBar        *_searchBar;
}
@end

@implementation WebListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width - 80, 30)];
    _searchBar.barTintColor = kNavCOLOR;
    _searchBar.placeholder = @"网址";
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    
}
- (void)leftScanButtonAction:(UIBarButtonItem *)item {
    ScanViewController *scan = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
}
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoWebWithSearchText:@""];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
     if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:text]]) {
         NSString *encodedString = (NSString *)
         CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                   (CFStringRef)text,
                                                                   NULL,
                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                   kCFStringEncodingUTF8));
         text =[NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",encodedString];
     }
    SVWebViewController *webViewController = [[SVWebViewController alloc] init];
    webViewController.urlStr = text;
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    [_searchBar resignFirstResponder];
//    if ([segue.identifier isEqualToString:@"WebDetailViewController"]) {
//        WebDetailViewController *detail = segue.destinationViewController;
//        detail.webUrlStr = sender;
//    }
    
}


@end
