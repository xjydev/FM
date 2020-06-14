//
//  VideoSetController.m
//  FileManager
//
//  Created by xiaodev on Oct/26/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "VideoSetController.h"
#import "XTools.h"
@interface VideoSetController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation VideoSetController
+ (instancetype)viewControllerFromeStoryBoard {
    UIStoryboard *setStory = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    VideoSetController *viewc = [setStory instantiateViewControllerWithIdentifier:@"VideoSetController"];
    return viewc;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
//    _array = @[@[@"声道",],@[@"宽高"],@[@"播放速度"],@[@"音频延迟"],@[@"字幕延迟"],@[@""]];
//    self.preferredContentSize = CGSizeMake(200, 150);
//    float f_ar = kScreen_Width / kScreen_Height;
//    NSString *reoStr;
//    if (f_ar == (float)(640./1136.)) // iPhone 5 aka 16:9.01
//        reoStr = @"16:9";
//    else if (f_ar == (float)(2./3.)) // all other iPhones
//        reoStr = @"16:10"; // libvlc doesn't support 2:3 crop
//    else if (f_ar == .75) // all iPads
//        reoStr = @"4:3";
//    else if (f_ar == .5625) // AirPlay
//        reoStr = @"16:9";
//    else{
//        reoStr = @"默认";
//    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"" forIndexPath:indexPath];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (CGSize)preferredContentSize{
//    if (self.presentingViewController) {
//        
//        CGSize size = CGSizeMake(150, 150);
//        return size;
//    }else {
//        return [super preferredContentSize];
//    }
//}
//- (void)setPreferredContentSize:(CGSize)preferredContentSize{
//    super.preferredContentSize = preferredContentSize;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
