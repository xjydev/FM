//
//  ScanCircleListController.m
//  QRcreate
//
//  Created by xiaodev on Sep/6/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "ScanCircleListController.h"
//#import "ShareView.h"
#import "WiFiViewController.h"
#import "ContactViewController.h"
#import "PasteViewController.h"
#import "WebViewController.h"
#import "XTools.h"
@interface ScanCircleListController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *_mainTableView;
    
}
@end

@implementation ScanCircleListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"连续扫描结果";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStyleDone target:self action:@selector(rightShareBarAction)];
}
- (void)rightShareBarAction{
    if (_listArray.count>0) {
        NSMutableString *str = [NSMutableString stringWithCapacity:0];
        for (NSString *s in _listArray) {
            [str appendString:s];
            [str appendString:@";\n"];
        }
//        [[ShareView shareView]shareViewVithText:str];
    }
    else
    {
        [XTOOLS showMessage:@"无分享内容"];
    }
   
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scancircleListcell" forIndexPath:indexPath];
    cell.textLabel.text = _listArray[indexPath.row];
    return cell;
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [_listArray removeObjectAtIndex:indexPath.row];
        [_mainTableView reloadData];
    }];
    
    return @[deleteRoWAction];//最后返回这俩个RowAction 的数组
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *contextStr = _listArray[indexPath.row];
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:contextStr]]) {
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.urlStr = contextStr;
        webViewController.noBackRoot = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
        
    }
    else if ([contextStr hasPrefix:@"WIFI:"]){
        [self performSegueWithIdentifier:@"WiFiViewController" sender:contextStr];
    }
    else
        if ([contextStr hasPrefix:@"MECARD:"]) {
            [self performSegueWithIdentifier:@"ContactViewController" sender:contextStr];
        }
        else
        {
            [self performSegueWithIdentifier:@"PasteViewController" sender:contextStr];
            
        }

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WiFiViewController"]) {
        WiFiViewController *paste = segue.destinationViewController;
        paste.wifiStr = sender;
    }
    else
        if ([segue.identifier isEqualToString:@"ContactViewController"]) {
            ContactViewController *contact = segue.destinationViewController;
            contact.contactStr = sender;
        }
        else
            if([segue.identifier isEqualToString:@"PasteViewController"])
            {
                PasteViewController *paste = segue.destinationViewController;
                paste.pasteStr = sender;
            }
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
