//
//  MoveFilesView.h
//  FileManager
//
//  Created by xiaodev on Dec/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SelectedPathBack)(NSString * movePath, NSInteger index);
@interface MoveFilesView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    UILabel   *_titleLabel ;
    UIView    *_backView;
    UITableView *_mainTableView;
    NSInteger  _selectedIndex;
}
@property (nonatomic, strong)SelectedPathBack selectedPathBackBlock;
@property (nonatomic, copy)NSString *selectedStr;
@property (nonatomic, strong)NSArray  *moveArray;
@property (nonatomic, assign)BOOL     isShow;
-(void)showWithFolderArray:(NSArray *)array withTitle:(NSString *)title backBlock:(SelectedPathBack)backBlock;
@end
