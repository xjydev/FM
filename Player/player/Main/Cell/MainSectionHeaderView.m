//
//  MainSectionHeaderView.m
//  player
//
//  Created by XiaoDev on 2018/6/8.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "MainSectionHeaderView.h"
#import <SDWebImage/SDImageCache.h>
#import "XTools.h"

#define kHeaderCellId @"xmainheadercell"
#define kHeaderHeaderId @"xmainheaderheaderid"
#define kHeaderSearchcell @"xmainheadersearchcell"

#define kFileType @"kfileType"
#define kFileSort @"kfileSort"

#define kHeaderCellHeight 49
#pragma mark --  header 上的cell

@interface XMainHeaderCell : UICollectionViewCell

@property (nonatomic, strong)UIImageView *headerImageView;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation XMainHeaderCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [self addSubview:self.headerImageView];
        [self addSubview:self.titleLabel];
        self.backgroundColor = kDarkCOLOR(0xffffff);
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [_titleLabel setHighlightedTextColor:kSELECTCOLOR];
    }
    return _titleLabel;
}
@end
#pragma mark -- search cell
@interface XMainSearchCell : UICollectionViewCell<UITextFieldDelegate>
@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, copy)void (^textFieldChangeBlock)(UITextField *textField);
@end

@implementation XMainSearchCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kDarkCOLOR(0xffffff);
        [self addSubview:self.textField];
    }
    return self;
}
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 5, 200, 40)];
        _textField.placeholder = @"文件名称";
        _textField.backgroundColor = kCOLOR(0xf9f9f9, 0x111111);
        _textField.layer.cornerRadius = 20;
        _textField.layer.masksToBounds = YES;
        _textField.keyboardType = UIKeyboardTypeWebSearch;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.delegate = self;
        [kNOtificationC addObserver:self selector:@selector(textFieldChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return _textField;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = CGRectMake(10, 5, CGRectGetWidth(self.bounds)-10, 40);
}
- (void)textFieldChange {
    if (self.textFieldChangeBlock) {
        self.textFieldChangeBlock(self.textField);
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)dealloc {
    [kNOtificationC removeObserver:self];
}
@end
#pragma mark -- header Cancel
@interface XMainHeaderHeader : UICollectionReusableView
@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, copy)void (^headerCancelButtonBlock)(NSInteger status);
@end

@implementation XMainHeaderHeader
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cancelButton];
        self.backgroundColor = kDarkCOLOR(0xffffff);
    }
    return self;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"header_back"] forState:UIControlStateNormal];
        _cancelButton.frame = CGRectMake(0, 0, 50, kHeaderCellHeight);
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (void)cancelButtonAction:(UIButton *)button {
    if (self.headerCancelButtonBlock) {
        self.headerCancelButtonBlock(1);
    }
}
@end

#pragma mark -- 首页用到的cell和header
@interface MainSectionHeaderView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong)NSArray *mainArray;
@property (nonatomic, assign)float itemWidth;
@property (nonatomic, strong)XMainHeaderCell *firstCell;

@end
@implementation MainSectionHeaderView
- (NSInteger)fileType {
    if (_fileType == 0) {
        _fileType = [kUSerD integerForKey:kFileType];
        if (_fileType == 0) {
          _fileType = 11;
        }
    }
    return _fileType;
}
- (NSInteger)sortType {
    if (_sortType == 0) {
        _sortType = [kUSerD integerForKey:kFileSort];
    }
    return _sortType;
}
- (void)reloadHeaderView {
    [self.mainCollectionView reloadData];
}
- (NSString *)fileTypeStr {
    switch (self.fileType) {
        case 11:
            return @"全部";
        case 12:
            return @"视频";
        case 13:
            return @"音频";
        case 14:
            return @"图片";
        case 15:
            return @"文档";
            
        default:
            break;
    }
    return @"全部";
}
- (NSString *)fileSortStr {
    switch (self.sortType) {
        case 21:
            return @"名称排序";
            break;
        case 22:
            return @"手动排序";
            break;
        case 23:
            return @"文件大小";
            break;
        case 24:
            return @"修改日期";
            break;
        case 25:
            return @"创建日期";
            break;
            
        default:
            return @"排序";
            break;
    }
}
- (void)setHeaderType:(XMainHeaderType)headerType {
    _headerType = headerType;
    switch (_headerType) {
        case XMainHeaderTypeDefault:
            self.mainArray =@[@{@"title":@"全部",@"image":@"",@"tag":@"1"},@{@"title":@"排序",@"image":@"",@"tag":@"2"},@{@"title":@"编辑",@"image":@"",@"tag":@"3"},@{@"title":@"搜索",@"image":@"",@"tag":@"4"},];
            break;
        case XMainHeaderTypeFileType:
            self.mainArray = @[@{@"title":@"全部",@"image":@"",@"tag":@"11"},@{@"title":@"视频",@"image":@"",@"tag":@"12"},@{@"title":@"音频",@"image":@"",@"tag":@"13"},@{@"title":@"图片",@"image":@"",@"tag":@"14"},@{@"title":@"文档",@"image":@"",@"tag":@"15"},];

            break;
        case XMainHeaderTypeSort:
            self.mainArray = @[@{@"title":@"名称排序",@"image":@"",@"tag":@"21"},@{@"title":@"手动排序",@"image":@"",@"tag":@"22"},@{@"title":@"文件大小",@"image":@"",@"tag":@"23"},@{@"title":@"修改日期",@"image":@"",@"tag":@"24"},@{@"title":@"创建日期",@"image":@"",@"tag":@"25"},];

            break;
        case XMainHeaderTypeSearch:
            self.mainArray =@[@{@"title":@"文件名称",@"image":@"",@"tag":@"31"},@{@"title":@"搜索",@"image":@"",@"tag":@"32"},];
            break;
        case XMainHeaderTypeEdit:
            self.mainArray =@[@{@"title":@"删除",@"image":@"",@"tag":@"41"},@{@"title":@"压缩",@"image":@"",@"tag":@"42"},@{@"title":@"全选",@"image":@"",@"tag":@"43"},@{@"title":@"转移",@"image":@"",@"tag":@"44"},@{@"title":@"转入",@"image":@"",@"tag":@"45"}];
            break;
        default:
            break;
    }
    [self.mainCollectionView reloadData];
}
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.itemWidth = kScreen_Width/4;
        self.backgroundColor = kDarkCOLOR(0xffffff);
        [self addSubview:self.mainCollectionView];
        [self setHeaderType:XMainHeaderTypeDefault];
        CALayer *line = [[CALayer alloc]init];
        line.frame = CGRectMake(0, 49.5, kScreen_Width, 0.5);
        line.backgroundColor = [UIColor lightGrayColor].CGColor;
        [self.layer addSublayer:line];
    }
    return self;
}
- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0.5;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionHeadersPinToVisibleBounds = YES;
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0,kScreen_Width, kHeaderCellHeight) collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = kCOLOR(0xf5f5f5, 0x222222);
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        [_mainCollectionView registerClass:[XMainHeaderCell class] forCellWithReuseIdentifier:kHeaderCellId];
        [_mainCollectionView registerClass:[XMainSearchCell class] forCellWithReuseIdentifier:kHeaderSearchcell];
        [_mainCollectionView registerClass:[XMainHeaderHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderHeaderId];
    }
    return _mainCollectionView;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return self.mainArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.headerType == XMainHeaderTypeDefault) {
        return CGSizeMake(0, 0);
    }
    return CGSizeMake(50, kHeaderCellHeight);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (self.headerType !=XMainHeaderTypeDefault) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            XMainHeaderHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderHeaderId forIndexPath:indexPath];
            @weakify(self);
            header.headerCancelButtonBlock = ^(NSInteger status) {
                @strongify(self);
                self.headerType = XMainHeaderTypeDefault;
                [self.mainCollectionView reloadData];
                if (self.headerSelectedHanlder) {
                    self.headerSelectedHanlder(0, nil);
                }
            };
            return header;
        }
    }
    return nil;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.mainArray[indexPath.row];
    NSString *str = dict[@"tag"];
    if (str.integerValue == 31) {//搜索
        return CGSizeMake(kScreen_Width - 50 - self.itemWidth, kHeaderCellHeight);
    }
    return CGSizeMake(self.itemWidth, kHeaderCellHeight);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.mainArray[indexPath.row];
    NSString *tag = dict[@"tag"];
    if (tag.integerValue == 31) {//搜索
      XMainSearchCell *scell = [collectionView dequeueReusableCellWithReuseIdentifier:kHeaderSearchcell forIndexPath:indexPath];
        @weakify(self);
        scell.textFieldChangeBlock = ^(UITextField *textField) {
            @strongify(self);
            if (self.headerSelectedHanlder) {
                self.headerSelectedHanlder(31, textField);
            }
        };
        scell.backgroundColor = kCOLOR(0xf1f1f1, 0x222222);
        [scell.textField becomeFirstResponder];
        return scell;
    }
    else {
        XMainHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        cell.titleLabel.text = dict[@"title"];
        if (self.headerType == XMainHeaderTypeSort) {
            if ([dict[@"tag"] integerValue] == self.sortType) {
                cell.highlighted = YES;
                self.firstCell = cell;
            }
            else {
                cell.highlighted = NO;
            }
        }
        else if (self.headerType == XMainHeaderTypeFileType) {
            if ([dict[@"tag"] integerValue] == self.fileType) {
                cell.highlighted = YES;
                self.firstCell = cell;
            }
            else {
                cell.highlighted = NO;
            }
        }
        else if (self.headerType == XMainHeaderTypeDefault) {
            if (indexPath.row == 0) {
                cell.titleLabel.text = self.fileTypeStr;
            }
            else if(indexPath.row == 1){
                cell.titleLabel.text = [self fileSortStr];
            }
            else {
                cell.titleLabel.text = dict[@"title"];
            }
        }
        if ([dict[@"tag"] integerValue] > 10) {
            cell.titleLabel.font = KUIFontNR(17);
            cell.backgroundColor = kCOLOR(0xf1f1f1, 0x222222);
        }
        else {
            cell.titleLabel.font = KUIFontNM(18);
            cell.backgroundColor = kDarkCOLOR(0xffffff);
        }
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.firstCell) {
        self.firstCell.highlighted = NO;
        self.firstCell = nil;
    }
    
    NSDictionary *dict = self.mainArray[indexPath.row];
    NSString *tag = dict[@"tag"];
    NSInteger tagInt = tag.integerValue;
    //保存操作
    if (tagInt > 10 && tagInt < 20) {//文件类型
        [kUSerD setInteger:tagInt forKey:kFileType];
        [kUSerD synchronize];
    }
    else
        if (tagInt > 20 && tagInt < 30) {//文件排序
            [kUSerD setInteger:tagInt forKey:kFileSort];
            [kUSerD synchronize];
        }
    
    if (self.headerType == XMainHeaderTypeDefault) {
        self.headerType = indexPath.row +1;
    }
    else if (self.headerType == XMainHeaderTypeSort) {
        self.sortType = [dict[@"tag"] integerValue];
    }
    else if (self.headerType == XMainHeaderTypeFileType) {
        self.fileType = [dict[@"tag"] integerValue];
    }
    
    if (self.headerSelectedHanlder) {
        self.headerSelectedHanlder(tagInt,nil);
    }
}
@end


@implementation MainSectionFooterView
- (void)setModel:(Record *)model {
    self.backgroundColor = kDarkCOLOR(0xf5f5f5);
    _model = model;
    NSLog(@"footer == %@ %@",model.description,KDocumentP);
    self.titleLabel.text = model.name;
    NSString *doStr = @"已看";
    if (self.model.fileType.integerValue == FileTypeAudio) {
        doStr = @"已听";
    }
    if (_model.totalTime.floatValue > 0) {
       self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@%.f%%",[XTOOLS timeStrFromDate:_model.modifyDate],doStr, (model.progress.floatValue/_model.totalTime.floatValue)*100];
    }
    else {
        self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@到：%@",[XTOOLS timeStrFromDate:_model.modifyDate],doStr,[XTOOLS timeSecToStrWithSec:model.progress.floatValue]];
    }
    
    if (model.fileType.integerValue == 0) {
        model.fileType = @([XTOOLS fileFormatWithPath:model.path]);
    }
//    if (model.fileType.integerValue == FileTypeAudio) {
//        [self.headerImageView setImage:[UIImage imageNamed:@"header_audio"]];
//    }
//    else {
//        [self.headerImageView setImage:[UIImage imageNamed:@"header_video"]];
//        NSString *pathlast = kSubDokument(model.path);
//        if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:pathlast]) {
//            self.headerImageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:pathlast];
//        }
//    }
    
}

@end
