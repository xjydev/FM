//
//  SearchViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2019/8/23.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "SearchViewController.h"
#import "WebViewController.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import "UIView+xiao.h"
#import "XManageCoreData.h"
#import "WebCollector+CoreDataClass.h"
#import "WebHistory+CoreDataProperties.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *mainArray;

@property (nonatomic, strong)UITextField *searchTextField;
@property (nonatomic, strong)UIButton *searhChannelButton;
@property (nonatomic, strong)UIView *headerView;
@property (nonatomic, strong)UISegmentedControl *segmentControl;
@property (nonatomic, strong)UIButton *clearButton;
@property (nonatomic, assign)NSInteger searchChannel;
@property (nonatomic, copy)NSString *searchChannelUrl;
@property (nonatomic, copy)NSString *searchChannelName;
@property (nonatomic, assign) BOOL   isHistory;
@property (nonatomic, assign) int    historyPage;


@end

@implementation SearchViewController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"XScan" bundle:nil];
    SearchViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"SearchViewController"];
    return VC;
}
- (NSString *)searchChannelUrl {
    switch (self.searchChannel) {
        case 0:
            return @"https://www.baidu.com/s?wd=";
            break;
        case 1:
            return @"https://m.so.com/s?q=";
            break;
        default:
            return @"https://wap.sogou.com/web/searchList.jsp?keyword=";
            break;
    }
}
- (NSString *)searchChannelName {
    switch (self.searchChannel) {
        case 0:
            return @"百度";
            break;
        case 1:
            return @"360";
            break;
        default:
            return @"搜狗";
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonItemAction)];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    self.searchChannel = [kUSerD integerForKey:@"xsearchChannel"];
    self.historyPage = 0;
    [self setupViews];
    [self getMainArrayWithHistory:NO];
}
- (void)backBarButtonItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setupViews {
    self.navigationItem.titleView = self.searchTextField;
}
- (UITextField *)searchTextField {
    if (!_searchTextField) {
        _searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0,kScreen_Width - 100 , 36)];
        _searchTextField.backgroundColor = kCOLOR(0xf1f1f1, 0x222222);
        UIView *lefView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 36)];
        [lefView addSubview:self.searhChannelButton];
        _searchTextField.leftView = lefView;
        _searchTextField.leftViewMode = UITextFieldViewModeAlways;
        _searchTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
        _searchTextField.attributedPlaceholder =[[NSAttributedString alloc]initWithString: @"输入搜索内容" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
        _searchTextField.layer.borderColor = [UIColor grayColor].CGColor;
        _searchTextField.layer.borderWidth = 0.5;
        _searchTextField.delegate = self;
        _searchTextField.returnKeyType = UIReturnKeySearch;
    }
    return _searchTextField;
}
- (UIButton *)searhChannelButton {
    if (!_searhChannelButton) {
        _searhChannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searhChannelButton.frame = CGRectMake(0, 0, 60, 36);
        _searhChannelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_searhChannelButton setTitleColor:kDarkCOLOR(0x000000) forState:UIControlStateNormal];
        [_searhChannelButton setTitle:self.searchChannelName forState:UIControlStateNormal];
        [_searhChannelButton addTarget:self action:@selector(searchChanelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searhChannelButton;
}
- (void)searchChanelButtonAction:(UIButton *)button {
    self.searchChannel = (self.searchChannel+1)%3;
    [button setTitle:self.searchChannelName forState:UIControlStateNormal];
    [kUSerD setInteger:self.searchChannel forKey:@"xsearchChannel"];
    [kUSerD synchronize];
    
}
#pragma mark -- 获取收藏和历史
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
        _headerView.backgroundColor = kDarkCOLOR(0xffffff);
        self.segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"收藏",@"历史"]];
        self.segmentControl.frame = CGRectMake((kScreen_Width - 120)/2, 8, 120, 34);
        self.segmentControl.tintColor = kMainCOLOR;
        self.segmentControl.selectedSegmentIndex = 0;
        [self.segmentControl addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
        [_headerView addSubview:self.segmentControl];
        CALayer *line = [[CALayer alloc]init];
        line.frame = CGRectMake(0, 49.5, kScreen_Width, 0.5);
        line.backgroundColor = [UIColor lightGrayColor].CGColor;
        [_headerView.layer addSublayer:line];
        [_headerView addSubview:self.clearButton];
    }
    return _headerView;
}
- (void)segmentControlAction:(UISegmentedControl *)control {
    if ((control.selectedSegmentIndex == 1)!=self.isHistory) {
        if (self.isHistory) {
            self.historyPage = 0;
        }
        [self getMainArrayWithHistory:control.selectedSegmentIndex ==1];
    }
}
- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearButton.frame = CGRectMake(kScreen_Width - 70, 0, 60, 50);
        [_clearButton setTitle:@"清空" forState:UIControlStateNormal];
        [_clearButton setTitleColor:kMainCOLOR forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}
- (void)clearButtonAction {
    [XTOOLS showAlertTitle:@"确认清空" message:@"清空所有历史记录？" buttonTitles:@[@"取消",@"确认"] completionHandler:^(NSInteger num) {
        if (num) {
            if ([[XManageCoreData manageCoreData]clearAllHistory]) {
                [self.mainArray removeAllObjects];
                self.historyPage = 0;
                [self reloadTableView];
            }
            else {
                [XTOOLS showMessage:NSLocalizedString(@"Error", nil)];
            }
        }
    }];
}
- (void)getMainArrayWithHistory:(BOOL)is {
    self.isHistory = is;
    if (!self.isHistory) {
        self.clearButton.hidden = YES;
      self.mainArray = [NSMutableArray arrayWithArray:[[[[XManageCoreData manageCoreData]getAllWebUrl]reverseObjectEnumerator]allObjects]];
    }
    else {
        self.clearButton.hidden = NO;
        if (self.historyPage == 0) {
            self.mainArray =[NSMutableArray arrayWithArray:[[XManageCoreData manageCoreData]getAllWebHistorypage:self.historyPage]];
        }
        else {
            NSLog(@"page ===%@",@(_historyPage));
            [self.mainArray addObjectsFromArray:[[XManageCoreData manageCoreData]getAllWebHistorypage:self.historyPage]];
        }
        if (self.mainArray.count!=0) {
            NSInteger count =self.mainArray.count%50;
            _historyPage = (int)(self.mainArray.count/50+(count >0?1:0));
        }
    }
    NSLog(@"arraycount == %@",@(self.mainArray.count));
    [self reloadTableView];
}
- (void)reloadTableView {
    if (self.mainArray.count!=0) {
        [_mainTableView xRemoveNoData];
        [_mainTableView reloadData];
    }
    else {
        [_mainTableView reloadData];
        [_mainTableView xNoDataThisViewTitle:_isHistory?@"无历史记录": @"无收藏网页" centerY:198];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCellid" forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:401];
    UILabel *titleLabel = [cell.contentView viewWithTag:402];
    UILabel *detailLabel = [cell.contentView viewWithTag:403];
    // Configure the cell...
    if (self.isHistory) {
        WebHistory *model = self.mainArray[indexPath.row];
        detailLabel.text = [XTOOLS timeStrFromDate:model.time];
        NSString *subStr = [model.url substringFromIndex:10];
        NSRange range = [subStr rangeOfString:@"/" options:NSCaseInsensitiveSearch];
        NSString *str;
        if (range.location!=NSNotFound) {
            str = [model.url substringToIndex:range.location+10];
        }
        else {
            str = model.url;
        }
        
        if (model.title.length>0) {
            titleLabel.text = model.title;
        } else {
            titleLabel.text = str;
        }
        NSString *imageStr = [NSString stringWithFormat:@"%@/favicon.ico",str];
        [imageView setImageWithURL:[NSURL URLWithString:imageStr]placeholderImage:[UIImage imageNamed:@"collect"]];
        NSLog(@" url == %@  \nicon ==%@",model.url,imageStr);
    }
    else {
        
        // Configure the cell...
        WebCollector *object = self.mainArray[indexPath.row];
        titleLabel.text = object.title;
        detailLabel.text = object.url;
        NSLog(@" objecturl ==%@",object.url);
        NSString *subStr = [object.url substringFromIndex:10];
        
        NSRange range = [subStr rangeOfString:@"/" options:NSCaseInsensitiveSearch];
        NSString *str;
        if (range.location != NSNotFound) {
            str = [object.url substringToIndex:range.location+10];
        }
        else {
            str = object.url;
        }
        NSString *imageStr = [NSString stringWithFormat:@"%@/favicon.ico",str];
        [imageView setImageWithURL:[NSURL URLWithString:imageStr]placeholderImage:[UIImage imageNamed:@"collect"]];
        NSLog(@" url ==%@",imageStr);
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isHistory) {
        [XTOOLS umengClick:@"webHistory"];
        WebHistory *model = self.mainArray[indexPath.row];
        [self pushWebDetailWithurl:model.url];
    }
    else {
        // Configure the cell...
        [XTOOLS umengClick:@"webcollect"];
        WebCollector *object = self.mainArray[indexPath.row];
        [self pushWebDetailWithurl:object.url];
    }
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        if (self.isHistory) {
            WebHistory *model = self.mainArray[indexPath.row];
            if ([[XManageCoreData manageCoreData]deleteWEbHistory:model]) {
                [self.mainArray removeObject:model];
                [self reloadTableView];
            }
            else {
                [XTOOLS showMessage:@"删除失败"];
            }
            
        }
        else {
            WebCollector *object = self.mainArray[indexPath.row];
            if ([[XManageCoreData manageCoreData]deleteWeb:object]) {
                [self.mainArray removeObject:object];
                [self reloadTableView];
            }
            else {
                [XTOOLS showMessage:@"删除失败"];
            }
        }
        
    }];
    return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WebCollector *object = self.mainArray[indexPath.row];
        
        if ([[XManageCoreData manageCoreData]deleteWeb:object]) {
            [self.mainArray removeObject:object];
        }
        [self reloadTableView];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.mainTableView) {
        if (self.mainTableView.contentOffset.y>=self.mainTableView.contentSize.height-2*kScreen_Height&&self.isHistory) {
            
            [self getMainArrayWithHistory:YES];
        }
    }
}
#pragma mark -- textfielddelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
     [self gotoWebWithSearchText:textField.text];
    return YES;
}
-(void)gotoWebWithSearchText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    [self.searchTextField resignFirstResponder];
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
        else
        {
            NSString *encodedString = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            text =[NSString stringWithFormat:@"%@%@",self.searchChannelUrl,encodedString];
        }
        
    }
    [self pushWebDetailWithurl:text];
}
- (void)pushWebDetailWithurl:(NSString *)url{
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.urlStr = url;
    webViewController.noBackRoot = YES;
    webViewController.hidesBottomBarWhenPushed = YES;
    @weakify(self);
    webViewController.backRefreshData = ^(NSInteger state) {
        @strongify(self);
        [self getMainArrayWithHistory:NO];
    };
    [self.navigationController pushViewController:webViewController animated:YES];
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
