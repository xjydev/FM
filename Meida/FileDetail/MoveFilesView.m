//
//  MoveFilesView.m
//  FileManager
//
//  Created by xiaodev on Dec/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//一个提供选择的控件

#import "MoveFilesView.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import "UIView+xiao.h"
@implementation MoveFilesView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    if (self) {
//        _fileView = [[MoveFilesView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, (kScreen_Height - 360), kScreen_Width, 360)];
        _backView.backgroundColor = [UIColor whiteColor];
//        backView.layer.masksToBounds = YES;
//        backView.layer.cornerRadius = 10;
        [self addSubview:_backView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        _titleLabel.text = @"请选择文件转移目录";
        _titleLabel.backgroundColor = [UIColor ora_colorWithHex:0xf7f7f7];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_backView addSubview:_titleLabel];
        
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kScreen_Width, 316) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.rowHeight = 40;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_backView addSubview:_mainTableView];
        
//        UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 320, 260, 40)];
//        buttonView.backgroundColor = kLINECOLOR;
//        [backView addSubview:buttonView];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [leftButton setImage:[UIImage imageNamed:@"cancelBack"] forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(10, 0, 44, 44);
        leftButton.backgroundColor =[UIColor clearColor];
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:leftButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [rightButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        rightButton.frame = CGRectMake(kScreen_Width-60, 0, 50, 44);
        rightButton.backgroundColor = [UIColor clearColor];
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:rightButton];
        
        
        
    }
    return self;
}
- (void)leftButtonAction {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self->_backView.center = CGPointMake(kScreen_Width/2, kScreen_Height+self->_backView.frame.size.height/2);
    } completion:^(BOOL finished) {
       [self removeFromSuperview];
    }];
  
}
- (void)rightButtonAction {
    if (self.selectedStr&&_selectedIndex>=0) {
        
        if (self.selectedPathBackBlock) {
         self.selectedPathBackBlock(_selectedStr,_selectedIndex);
        }
        [self leftButtonAction];
    }
    else
    {
        [XTOOLS showMessage:@"请选择内容"];
    }
    
}
- (NSArray *)getMoveFolderArray {
    NSError *error;
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:KDocumentP error:&error];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *name in array) {
        if (![name hasPrefix:@"."] && ![name containsString:@"/."]) {
            if ([XTOOLS fileFormatWithPath:name]==FileTypeFolder) {
                [arr addObject:name];
            }
        }
    }
    return arr;
}
-(void)showWithFolderArray:(NSArray *)array withTitle:(NSString *)title backBlock:(SelectedPathBack)backBlock{
    _selectedIndex = -1;
    if (array == nil) {
        array = [self getMoveFolderArray];
    }
    if (title) {//如果有title是选取
        _titleLabel.text = title;
        self.moveArray = array;
    }
    else {
        if ([array containsObject:KDocumentP]) {
            self.moveArray = array;
        }
        else {
            NSMutableArray *marr = [NSMutableArray arrayWithArray:array];
            [marr insertObject:KDocumentP atIndex:0];
            self.moveArray = marr;
        }
        
    }
    self.selectedPathBackBlock = backBlock;
    
    if (self.moveArray.count == 0) {
        [_mainTableView xNoDataThisViewTitle:@"无供选择内容" centerY:100];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moveArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isShow) {
        return 80;
    }
    else
    {
        return 44;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectedmovecell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectedmovecell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.highlightedTextColor = kMainCOLOR;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectedBackgroundView =[[UIView alloc]init];
         [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    NSObject *object = self.moveArray[indexPath.row];
    NSString *title = nil;
    if([object isKindOfClass:[NSString class]]){
        title = (NSString *)object;
    }
    else {
        Record *rObjec = (Record *)object;
        title = rObjec.path;
    }
    if ([title isEqualToString:KDocumentP]) {
        title = @"主目录";
    }
    cell.textLabel.text = title;
    
    if (self.isShow) {
        NSString *imagePath =title;
        if (![title hasPrefix:KDocumentP]) {
           imagePath = [KDocumentP stringByAppendingPathComponent:title];
        }
//        [NSString stringWithFormat:@"%@/%@",KDocumentP, self.moveArray[indexPath.row]];
        [cell.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectedIndex>=0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    _selectedIndex = indexPath.row;
    NSObject *object = self.moveArray[indexPath.row];
    NSString *path = nil;
    if([object isKindOfClass:[NSString class]]){
        path = (NSString *)object;
    }
    else {
        Record *rObjec = (Record *)object;
        path = rObjec.path;
    }
                      
    if (![path hasPrefix:KDocumentP]) {
     self.selectedStr = [KDocumentP stringByAppendingPathComponent:path];
    }
    else {
        self.selectedStr = path;
    }
    
    UITableViewCell *scell = [tableView cellForRowAtIndexPath:indexPath];
    scell.accessoryType = UITableViewCellAccessoryCheckmark;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self leftButtonAction];
}
@end
