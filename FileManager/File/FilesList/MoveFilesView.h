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
    NSInteger  _selectedIndex;
}
@property (nonatomic, strong)SelectedPathBack selectedPathBackBlock;
@property (nonatomic, copy)NSString *selectedStr;
@property (nonatomic, strong)NSArray  *moveArray;
-(void)showWithFolderArray:(NSArray *)array withTitle:(NSString *)title backBlock:(SelectedPathBack)backBlock;
@end