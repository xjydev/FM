//
//  PopViewController.m
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "PopViewController.h"
#import "XTools.h"
#define cellId @"poptableviewcell"
@interface PopViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)NSArray *mainArray;
@end

@implementation PopViewController
+ (instancetype)returnFromStoryBoard {
    UIStoryboard *mainStoryB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PopViewController *pop = [mainStoryB instantiateViewControllerWithIdentifier:@"PopViewController"];
    return pop;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isSub) {
        self.mainArray = @[@{@"title":@"电脑传输",@"image":@"pop_computer"},@{@"title":@"手机互传",@"image":@"pop_iphone"},@{@"title":@"相册导入",@"image":@"pop_photos"},@{@"title":@"新建文件夹",@"image":@"pop_add"}];
    }
    else {
        self.mainArray = @[@{@"title":@"电脑传输",@"image":@"pop_computer"},@{@"title":@"手机互传",@"image":@"pop_iphone"},@{@"title":@"相册导入",@"image":@"pop_photos"},@{@"title":@"新建文件夹",@"image":@"pop_add"},@{@"title":@"扫一扫",@"image":@"pop_scan"},@{@"title":@"网页搜索",@"image":@"pop_search"}];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    NSDictionary * dict =self.mainArray[indexPath.row];
    cell.textLabel.text =dict[@"title"];
    [cell.imageView setImage:[UIImage imageNamed:dict[@"image"]]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if (self.completeSelectBlock) {
            self.completeSelectBlock(indexPath.row);
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    NSLog(@"PopViewController dealloc");
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
