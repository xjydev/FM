//
//  HistoryViewController.m
//  FileManager
//
//  Created by XiaoDev on 2017/12/27.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import "HistoryViewController.h"
#import "WebViewController.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import "UIView+xiao.h"
#import "XManageCoreData.h"
#import "WebCollector+CoreDataClass.h"
#import "WebHistory+CoreDataProperties.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
@interface HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray  *_historyArray;
    NSMutableArray  *_collectArray;
    NSMutableArray   *_webArray;
    __weak IBOutlet UITableView *_mainTableView;
    IBOutlet UISegmentedControl *_segmentView;
    BOOL            _isHistory;
    int             _historyPage;
    UIBarButtonItem  *_clearBar;
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.titleView = _segmentView;
    _mainTableView.tableFooterView = [[UIView alloc]init];
    _clearBar = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Clear", nil) style:UIBarButtonItemStyleDone target:self action:@selector(clearBarbuttonAction)];
    [self getWebListData];
}
- (IBAction)segmentedChangeAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0 ) {
        _isHistory = NO;
        self.navigationItem.rightBarButtonItem = nil;
        [self getWebListData];
    }
    else {
        _isHistory = YES;
        self.navigationItem.rightBarButtonItem = _clearBar;
        _historyPage = 0;
        [self getHistoryData];
    }
}
- (void)clearBarbuttonAction {
    @weakify(self);
    [XTOOLS showAlertTitle:@"确认清除？" message:@"确认清除所有浏览记录" buttonTitles:@[@"取消",@"确认"] completionHandler:^(NSInteger num) {
        if (num == 1) {
            @strongify(self);
            if ([[XManageCoreData manageCoreData]clearAllHistory]) {
                [self->_webArray removeAllObjects];
                self->_historyPage = 0;
                [self reloadTableView];
            }
            else {
                [XTOOLS showMessage:NSLocalizedString(@"Error", nil)];
            }
        }
    }];
}
- (void)getHistoryData {
    if (_historyPage == 0) {
        _webArray =[NSMutableArray arrayWithArray:[[XManageCoreData manageCoreData]getAllWebHistorypage:_historyPage]];
    }
    else
    {
        NSLog(@"page ===%@",@(_historyPage));
        [_webArray addObjectsFromArray:[[XManageCoreData manageCoreData]getAllWebHistorypage:_historyPage]];
    }
    if (_webArray.count!=0) {
        NSInteger count =_webArray.count%50;
        _historyPage = (int)(_webArray.count/50+(count >0?1:0));
        
    }
    [self reloadTableView];
   
}
- (void)reloadTableView {
    if (_webArray.count!=0) {
        [_mainTableView xRemoveNoData];
        [_mainTableView reloadData];
    }
    else
    {
        [_mainTableView reloadData];
        [_mainTableView xNoDataThisViewTitle:_isHistory?@"无浏览记录": @"无收藏网页" centerY:198];
    }
    
}
- (void)getWebListData {
    _webArray = [NSMutableArray arrayWithArray:[[[[XManageCoreData manageCoreData]getAllWebUrl]reverseObjectEnumerator]allObjects]];
    [self reloadTableView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _mainTableView) {
        if (_mainTableView.contentOffset.y>=_mainTableView.contentSize.height-2*kScreen_Height&&_isHistory) {
            
            [self getHistoryData];
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _webArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebListCell" forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:401];
    UILabel *titleLabel = [cell.contentView viewWithTag:402];
    UILabel *detailLabel = [cell.contentView viewWithTag:403];
    // Configure the cell...
    if (_isHistory) {
        WebHistory *model = _webArray[indexPath.row];
        detailLabel.text = [XTOOLS timeStrFromDate:model.time];
        NSString *subStr = [model.url substringFromIndex:10];
        NSRange range = [subStr rangeOfString:@"/" options:NSCaseInsensitiveSearch];
        NSString *str;
        if (range.location!=NSNotFound) {
           str = [model.url substringToIndex:range.location+10];
        }
        else
        {
            str = model.url;
        }
       
        if (model.title.length>0) {
            titleLabel.text = model.title;
        }else
        {
            titleLabel.text = str;
        }
        NSString *imageStr = [NSString stringWithFormat:@"%@/favicon.ico",str];
        [imageView setImageWithURL:[NSURL URLWithString:imageStr]placeholderImage:[UIImage imageNamed:@"collect"]];
        NSLog(@" url == %@  \nicon ==%@",model.url,imageStr);
    }
    else
    {
        
        // Configure the cell...
        WebCollector *object = _webArray[indexPath.row];
        titleLabel.text = object.title;
        detailLabel.text = object.url;
        NSLog(@" objecturl ==%@",object.url);
        NSString *subStr = [object.url substringFromIndex:10];
        
        NSRange range = [subStr rangeOfString:@"/" options:NSCaseInsensitiveSearch];
        NSString *str;
        if (range.location != NSNotFound) {
          str = [object.url substringToIndex:range.location+10];
        }
        else
        {
            str = object.url;
        }
        
        NSString *imageStr = [NSString stringWithFormat:@"%@/favicon.ico",str];
        [imageView setImageWithURL:[NSURL URLWithString:imageStr]placeholderImage:[UIImage imageNamed:@"collect"]];
        NSLog(@" url ==%@",imageStr);
        
    }
    return cell;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        if (self->_isHistory) {
            WebHistory *model = self->_webArray[indexPath.row];
            if ([[XManageCoreData manageCoreData]deleteWEbHistory:model]) {
                [self->_webArray removeObject:model];
                [self reloadTableView];
            }
            else
            {
                [XTOOLS showMessage:@"删除失败"];
            }
            
        }
        else {
            // Configure the cell...
            WebCollector *object = self->_webArray[indexPath.row];
            if ([[XManageCoreData manageCoreData]deleteWeb:object]) {
                [self->_webArray removeObject:object];
                [self reloadTableView];
            }
            else
            {
                [XTOOLS showMessage:@"删除失败"];
            }
        }
       
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isHistory) {
        [XTOOLS umengClick:@"webHistory"];
        WebHistory *model = _webArray[indexPath.row];
       [self pushWebDetailWithurl:model.url];
    }
    else {
        // Configure the cell...
        [XTOOLS umengClick:@"webcollect"];
        WebCollector *object = _webArray[indexPath.row];
       [self pushWebDetailWithurl:object.url];
    }
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
        [self reloadTableView];
        
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
//    [_searchBar resignFirstResponder];
    [XTOOLS umengClick:@"webSearch"];
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
        else {
            NSString *encodedString = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            text =[NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",encodedString];
        }
        
    }
    [self pushWebDetailWithurl:text];
}
- (void)pushWebDetailWithurl:(NSString *)url{
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.urlStr = url;
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.backRefreshData = ^(NSInteger state){
        [self getWebListData];
    };
    [self.navigationController pushViewController:webViewController animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
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
