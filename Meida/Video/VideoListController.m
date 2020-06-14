//
//  VideoListController.m
//  FileManager
//
//  Created by XiaoDev on 07/04/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "VideoListController.h"
#import "XTools.h"
#import "UIView+xiao.h"
#import "XManageCoreData.h"
#import "MoveFilesView.h"

#import <AVFoundation/AVFoundation.h>
#import "VideoListCell.h"

#import "NewVideoViewController.h"

@interface VideoListController ()<UITableViewDelegate,UITableViewDataSource>
{
   NSMutableArray   *_filesArray;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)UILabel *footLabel;
@end

@implementation VideoListController
+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    VideoListController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"VideoListController"];
    return VC;
}
- (UILabel *)footLabel {
    if (!_footLabel) {
        _footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        _footLabel.textAlignment = NSTextAlignmentCenter;
        _footLabel.font = [UIFont systemFontOfSize:12];
        _footLabel.textColor = [UIColor grayColor];
    }
    return _footLabel;
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
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    _filesArray = [NSMutableArray arrayWithCapacity:0];
    [self reloadFilesArray];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refreshPullUp:) forControlEvents:UIControlEventValueChanged];
    [self.mainTableView addSubview:refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadFilesArray) name:kRefreshList object:nil];
    self.mainTableView.tableFooterView = self.footLabel;
    self.mainTableView.rowHeight = kScreen_Height/8;
}
- (void)reloadFilesArray {
    
    NSError *error;
    if (self.folderPath.length == 0) {
        self.folderPath = KDocumentP;
    }
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:self.folderPath error:&error];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
        return (NSComparisonResult)[obj1 compare:obj2 options:comparisonOptions];
        
    }];
    [_filesArray removeAllObjects];
    for (NSString *name in marry) {
        if ([XTOOLS fileFormatWithPath:name] == FileTypeVideo ) {
            //不是.开头，并且路径中没有.开头的。
            if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
                NSString *nPath = name;
                if (![nPath hasPrefix:self.folderPath]) {
                    nPath = [self.folderPath stringByAppendingPathComponent:nPath];
                }
                [_filesArray addObject:nPath];
            }
        }
    }
    
    [self reloadNoDataView];
    [self.mainTableView reloadData];
}

- (void)reloadNoDataView {
    if (_filesArray.count !=0) {
        [self.mainTableView xRemoveNoData];
        self.footLabel.text = [NSString stringWithFormat:@"共有%@个视频",@(_filesArray.count)];
    }
    else
    {
        NSString *noFileStr =NSLocalizedString(@"NOvideo", nil);
        [self.mainTableView xNoDataThisViewTitle:noFileStr centerY:198];
        self.footLabel.text = nil;
    }
    
}
- (void)leftGoBackButtonAction:(UIBarButtonItem *)bar {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    return YES;
}
- (void)refreshPullUp:(UIRefreshControl *)control {
    [self reloadFilesArray];
    [self performSelector:@selector(endRefresh:) withObject:control afterDelay:0.2];
}
- (void)endRefresh:(UIRefreshControl *)control  {
    [control endRefreshing];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoListCell" forIndexPath:indexPath];
    NSString *pathName = _filesArray[indexPath.row];
    NSString *pathStr = pathName;
    if ([pathStr hasPrefix:self.folderPath]) {
        pathStr = [pathStr substringFromIndex:self.folderPath.length];
    }
    [cell setCellPath:pathStr];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewVideoViewController *video = [NewVideoViewController allocFromStoryBoard];
    video.modalPresentationStyle = UIModalPresentationFullScreen;
    [video setVideoArray:_filesArray WithIndex:indexPath.row];
    [self presentViewController:video animated:YES completion:^{
        
    }];
    
    
}
-(NSArray *)tableView:(UITableView* )tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSError *error ;
        
        NSString *path = self->_filesArray[indexPath.row];
        if (![path hasPrefix:self.folderPath]) {
            path = [self.folderPath stringByAppendingPathComponent:path];
        }
        //        [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
        
        [kFileM removeItemAtPath:path error:&error];
        [[XManageCoreData manageCoreData]deleteRecordPath:path];
        if (error) {
            NSLog(@"==%@",error);
        }
        NSLog(@"点击删除");
        [self->_filesArray removeObjectAtIndex:indexPath.row];
        [self reloadNoDataView];
        [self.mainTableView reloadData];
    }];
    //    此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转移" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
        
        [fileView showWithFolderArray:self.moveArray withTitle:nil backBlock:^(NSString *movePath,NSInteger selectedIndex) {
            NSError *error = nil;
            NSString *path = self->_filesArray[indexPath.row];
            if (![path hasPrefix:self.folderPath]) {
                path = [self.folderPath stringByAppendingPathComponent:self->_filesArray[indexPath.row]];
            }
            
            //            [NSString stringWithFormat:@"%@/%@",self.filePath,_filesArray[indexPath.row]];
            
            NSString *toPath = [movePath stringByAppendingPathComponent:path.lastPathComponent];
            //            [NSString stringWithFormat:@"%@/%@",movePath,path.lastPathComponent];
            if ([kFileM moveItemAtPath:path toPath:toPath error:&error]) {
                [XTOOLS showMessage:@"转移成功"];
                [self.mainTableView reloadData];
            }
            else{
                [XTOOLS showMessage:@"转移失败"];
                NSLog(@"error == %@",error);
            }
        }];
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction,editRowAction];//最后返回这俩个RowAction 的数组
}
- (void)dealloc {
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
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
