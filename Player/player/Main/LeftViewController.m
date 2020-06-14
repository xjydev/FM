//
//  LeftViewController.m
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "LeftViewController.h"
#import "DrawerViewController.h"
#import "XTools.h"
#import "UIView+xiao.h"
#define cellId @"leftcellId"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSArray *mainArray;
@property (nonatomic, strong)UILabel *sizeLabel;
@property (nonatomic, weak)UITableViewCell *payCell;
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kMainCOLOR;
    self.mainArray =@[@[@{@"image":@"left_history",@"title":@"历史记录",@"tag":@(6)},@{@"image":@"left_encry",@"title":@"加密文件",@"tag":@(8)},@{@"image":@"left_setting",@"title":@"应用设置",@"tag":@(1)},@{@"image":@"left_detail",@"title":@"应用详情",@"tag":@(2)}],@[@{@"image":@"left_pay",@"title":@"订阅会员",@"tag":@(7)},@{@"image":@"left_share",@"title":@"分享好友",@"tag":@(3)},@{@"image":@"left_feedback",@"title":@"意见反馈",@"tag":@(4)},@{@"image":@"left_comment",@"title":@"给个好评",@"tag":@(5)},],];
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    [headerView addSubview:self.sizeLabel];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = kMainCOLOR;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 230, 80)];
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.font = [UIFont systemFontOfSize:15];
        _sizeLabel.numberOfLines = 2;
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _sizeLabel;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mainArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.mainArray[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = self.mainArray[indexPath.section][indexPath.row];
    cell.textLabel.text =dict[@"title"];
    [cell.imageView setImage:[UIImage imageNamed:dict[@"image"]]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.mainArray[indexPath.section][indexPath.row];
    [[DrawerViewController shareDrawer] closeLeftMenu];
    [[DrawerViewController shareDrawer] leftViewDidSelectedtag:[dict[@"tag"]integerValue]];
    if ([dict[@"tag"]integerValue] == 7) {
        self.payCell.imageView.xdBadgeValue = nil;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}
- (void)willShow {
    NSString *s =[XTOOLS storageSpaceStringWith:[XTOOLS freeStorageSpace]];
    NSString *sizeStr = [NSString stringWithFormat:@"设备剩余:\n%@/%@",s,[XTOOLS storageSpaceStringWith:[XTOOLS allStorageSpace]]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.paragraphSpacing = 10;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:sizeStr attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    [attr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30]} range:NSMakeRange(6, s.length+1)];
    self.sizeLabel.attributedText =attr;
    self.payCell.imageView.xdBadgeValue =[kUSerD boolForKey:KADBLOCK] ?nil: @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma 转屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IsPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL)shouldAutorotate {
    return YES;
}

@end
