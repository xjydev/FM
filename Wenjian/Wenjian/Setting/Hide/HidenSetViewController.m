//
//  HidenSetViewController.m
//  Wenjian
//
//  Created by xiaodev on Oct/24/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "HidenSetViewController.h"
#import "XTools.h"
@interface HidenSetViewController ()
{
    
    __weak IBOutlet UISwitch *_setSwitch;
}
@end

@implementation HidenSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _setSwitch.on = [kUSerD boolForKey:kHiden];
}
- (IBAction)switchChangeAction:(UISwitch *)sender {
    [kUSerD setBool:sender.on forKey:kHiden];
    [kUSerD synchronize];
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
