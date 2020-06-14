//
//  HomeFeedController.m
//  FileManager
//
//  Created by 阿凡树 on 2017/4/7.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import "HomeFeedController.h"
#import "HomeFeedCell.h"
#import "NetManager.h"
#import "HomeFeedModel.h"
#import "UMMobClick/MobClick.h"
#import "XTools.h"
#import "MJRefresh.h"
@interface HomeFeedController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, readwrite, retain) NSMutableArray *mainArray;
@property (nonatomic, readwrite, retain) IBOutlet UITableView *tableView;
@end

@implementation HomeFeedController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"HomeFeed"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HomeFeed"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainArray = [[NSMutableArray alloc] init];
    [self getDataFromNet:NO];
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getDataFromNet:YES];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getDataFromNet:NO];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)getRandom {
    return arc4random()%400;
}

- (void)getDataFromNet:(BOOL)isRefresh {
    __weak typeof(self) weakSelf = self;
    [[NetManager sharedInstance] getDataWithPath:[NSString stringWithFormat:@"https://app.kankan.izannet.com/home/index/%zd",[self getRandom]] parameters:nil completion:^(NSError *error, id resultObject) {
        if (error == nil) {
            HomeFeedAPI* api = [[HomeFeedAPI alloc] initWithData:resultObject error:nil];
            if (isRefresh) {
                weakSelf.mainArray = [[api.data arrayByAddingObjectsFromArray:weakSelf.mainArray] mutableCopy];
            } else {
                [weakSelf.mainArray addObjectsFromArray:api.data];
            }
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeFeedCell" forIndexPath:indexPath];
    cell.model = self.mainArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80;
    HomeFeedModel* item = self.mainArray[indexPath.row];
    CGFloat titleHeight = [item.title boundingRectWithSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]} context:nil].size.height;
    CGFloat videoHeight = MIN(kScreen_Width * item.height / item.width , 300);
    height += (titleHeight + videoHeight);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeFeedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell startPlay];
    [MobClick event:@"playonce"];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeFeedCell *cell1 = (HomeFeedCell *)cell;
    [cell1 stopPlay];
}

@end
