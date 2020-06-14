//
//  SingliImageController.m
//  FileManager
//
//  Created by XiaoDev on 14/04/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "SingliImageController.h"
#import "XTools.h"
@interface SingliImageController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *_mainTableView;
    NSArray   *_mainArray;
}
@end

@implementation SingliImageController
+ (instancetype)viewControllerFromeStoryBoard {
    UIStoryboard *setStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    SingliImageController *viewc = [setStory instantiateViewControllerWithIdentifier:@"SingliImageController"];
    return viewc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _mainArray = @[@"详情",@"删除",@"转移"];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return  _mainArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"singleimagecell" forIndexPath:indexPath];
    cell.textLabel.text = _mainArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedBack) {
        self.selectedBack(self.index,indexPath.row);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    });
}
- (BOOL)shouldAutorotate {
    return YES;
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
