//
//  MoveFilesView.m
//  FileManager
//
//  Created by xiaodev on Dec/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "MoveFilesView.h"
#import "XTools.h"
#import "UIColor+Hex.h"
@implementation MoveFilesView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    if (self) {
//        _fileView = [[MoveFilesView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake((kScreen_Width - 260)/2, (kScreen_Height - 360)/2, 260, 360)];
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 10;
        [self addSubview:backView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 260, 40)];
        _titleLabel.text = @"请选择文件转移目录";
        _titleLabel.backgroundColor = [UIColor ora_colorWithHex:0xf7f7f7];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [backView addSubview:_titleLabel];
        
        UITableView *mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 40, 240, 280) style:UITableViewStylePlain];
        mainTableView.delegate = self;
        mainTableView.dataSource = self;
        mainTableView.rowHeight = 40;
        [mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [backView addSubview:mainTableView];
        
        UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 320, 260, 40)];
        buttonView.backgroundColor = kLINECOLOR;
        [backView addSubview:buttonView];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0.5, 130, 39.5);
        leftButton.backgroundColor =[UIColor whiteColor];
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:leftButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [rightButton setTitle:@"确定" forState:UIControlStateNormal];
        rightButton.frame = CGRectMake(130.5, 0.5, 129.5, 39.5);
        rightButton.backgroundColor = [UIColor whiteColor];
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:rightButton];
        
    }
    return self;
}
- (void)leftButtonAction {
  [self removeFromSuperview];
}
- (void)rightButtonAction {
    if (self.selectedStr) {
        self.selectedPathBackBlock(_selectedStr,_selectedIndex);
        [self removeFromSuperview];
    }
    else
    {
        [XTOOLS showMessage:@"请选择路径"];
    }
    
}
-(void)showWithFolderArray:(NSArray *)array withTitle:(NSString *)title backBlock:(SelectedPathBack)backBlock{
    if (title) {
        _titleLabel.text = title;
    }
    self.selectedPathBackBlock = backBlock;
    self.moveArray = array;
   
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moveArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectedmovecell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectedmovecell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.highlightedTextColor = kMainCOLOR;
        cell.selectedBackgroundView =[[UIView alloc]init];
         [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    NSString *title = self.moveArray[indexPath.row];
    if (title.length== 0) {
        title = @"主目录";
    }
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.row;
    self.selectedStr =[NSString stringWithFormat:@"%@/%@",KDocumentP, self.moveArray[indexPath.row]];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self removeFromSuperview];
}
@end
