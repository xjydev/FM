//
//  PickerArrayController.m
//  FileManager
//
//  Created by XiaoDev on 23/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "PickerArrayController.h"
#import "XTools.h"
@interface PickerArrayController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray  *_mainArray;
}
@property (nonatomic, strong)NSArray *mainArray;
@property (nonatomic, assign)NSInteger type;//1,倍速 2，时间。
@end

@implementation PickerArrayController
+ (instancetype)pickerControllerFromStroyboardType:(NSInteger)type {
    
    UIStoryboard *setStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    PickerArrayController *pa = [setStory instantiateViewControllerWithIdentifier:@"PickerArrayController"];
    
    
    pa.type = type;
    if (type == 1) {
      pa.mainArray = @[@(6),@(4),@(2),@(1.5),@(1.25),@(1),@(0.5),@(0.25),@(0.1)];
    }
    else
        if (type == 2) {
            pa.mainArray = @[@(1),@(5),@(10),@(20),@(30),@(40),@(50),@(60),@(90),@(120),];
        }
    else
    {
        pa.mainArray = @[@"DEFAULT", @"FILL_TO_SCREEN", @"4:3", @"16:9", @"16:10"];
    }
    
    return pa;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickerarraycell" forIndexPath:indexPath];
    NSNumber *num = self.mainArray[indexPath.row];
    if (self.type == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"X%@",num];
    }
    else
        if (self.type == 2) {
          cell.textLabel.text = [NSString stringWithFormat:@"%dm",num.intValue];
        }
    else
    {
        NSString *str = self.mainArray[indexPath.row];
        if ([str isEqualToString:@"DEFAULT"]) {
            str = @"默认";
        }
        else
            if ([str isEqualToString:@"FILL_TO_SCREEN"]) {
                str = @"满屏";
            }
       cell.textLabel.text = str;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 1||self.type == 2) {
        NSNumber *num = self.mainArray[indexPath.row];
        
        if (self.pickerArrayBlock) {
           self.pickerArrayBlock(num,nil);
        }
        
    }
    else
    {
        NSString *str = self.mainArray[indexPath.row];
        
        if (self.pickerArrayBlock) {
            self.pickerArrayBlock(nil, str);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (BOOL)shouldAutorotate {
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    return YES;
}

@end
