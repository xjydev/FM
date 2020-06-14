//
//  HomePopViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2019/5/5.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "HomePopViewController.h"
#import "XTools.h"
@interface HomePopViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *maiTableView;

@end

@implementation HomePopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.popItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homepopcell" forIndexPath:indexPath];
    NSDictionary *dict = self.popItems[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.pickerItemBlock) {
            NSDictionary *dict = self.popItems[indexPath.row];
            self.pickerItemBlock(dict[@"type"], dict[@"title"]);
        }
    }];
    
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
