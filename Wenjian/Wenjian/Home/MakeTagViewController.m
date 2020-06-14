//
//  MakeTagViewController.m
//  Wenjian
//
//  Created by xiaodev on Oct/19/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "MakeTagViewController.h"
#import "XTools.h"
@interface MakeTagViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *_mainTableView;
    BackTagHandler _backTagHandler;
}
@end

@implementation MakeTagViewController
+ (MakeTagViewController *)viewControllerFromStoryboard {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MakeTagViewController *makeView = [story instantiateViewControllerWithIdentifier:@"MakeTagViewController"];
    makeView.modalPresentationStyle  = UIModalPresentationPopover;
    makeView.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    return makeView;
}
- (void)makeTagBackHandler:(BackTagHandler)backTagHandeler {
    _backTagHandler = backTagHandeler;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    [XTOOLS umengClick:@"maketag"];
    self.preferredContentSize = CGSizeMake(100, 240);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maketagcell" forIndexPath:indexPath];
    UIView *tagView = [cell.contentView viewWithTag:401];
    UILabel *label = [cell.contentView viewWithTag:402];
    
    tagView.backgroundColor = [[XDFileManager defaultManager] fileMarkWithTag:(int)indexPath.row+1];
    label.text = [[XDFileManager defaultManager] fileMarkNameWithTag:(int)indexPath.row+1];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row+1 == 7) {
      _backTagHandler(0);
    }
    else
    {
        _backTagHandler((int)indexPath.row+1);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
