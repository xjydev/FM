//
//  WebListTableViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "WebListTableViewController.h"
#import "WebDetailViewController.h"
#import "XTools.h"
@interface WebListTableViewController ()<UITextFieldDelegate>
{
    NSMutableArray   *_webArray;
    UITextField      *_searchField;
}
@end

@implementation WebListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    _searchField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width - 80, 30)];
    _searchField.backgroundColor = [UIColor whiteColor];
    _searchField.placeholder = @"网址";
    _searchField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    self.navigationItem.titleView = _searchField;
    
}
- (void)leftScanButtonAction:(UIBarButtonItem *)item {
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSegueWithIdentifier:@"WebDetailViewController" sender:textField.text];
    
    return YES;
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

    return _webArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"WebDetailViewController" sender:@""];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [_searchField resignFirstResponder];
    if ([segue.identifier isEqualToString:@"WebDetailViewController"]) {
        WebDetailViewController *detail = segue.destinationViewController;
        detail.webUrlStr = sender;
    }
    
}


@end
