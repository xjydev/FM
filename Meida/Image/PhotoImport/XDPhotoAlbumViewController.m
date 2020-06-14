//
//  XDPhotoAlbumViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2019/9/2.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPhotoAlbumViewController.h"
#import "XDPhotoModel.h"
#import "XDPhotoAssetViewController.h"
#import "XDPhotoViewController.h"
#import <Photos/Photos.h>
#import "XTools.h"
#define aCellId @"photoalbumcellid"

@interface XDPhotoAlbumCell : UITableViewCell
@property (nonatomic, strong) XDPhotoAlbumModel *model;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIImageView *headerImageView;
@end
@implementation XDPhotoAlbumCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.headerImageView];
        [self.contentView addSubview:self.titleLabel];
    }
    
    return self;
}
- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImageView.clipsToBounds = YES;
    }
    return _headerImageView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, 150, 70)];
        
    }
    return _titleLabel;
}
- (void)setModel:(XDPhotoAlbumModel *)model {
    _model = model;
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:kDarkCOLOR(0x000000)}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:kCOLOR(0x333333, 0x999999)}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    id asset = [model.result firstObject];
    if ([asset isKindOfClass:[PHAsset class]]) {
       
        CGSize thuSize = CGSizeMake(200, 200);
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.networkAccessAllowed = NO;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:thuSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self.headerImageView setImage:result];
        }];
    }
}
@end

@interface XDPhotoAlbumViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation XDPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    self.title = @"照片";
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarButtonAction)];
    self.tableView.rowHeight = 70;
    [self.tableView registerClass:[XDPhotoAlbumCell class] forCellReuseIdentifier:aCellId];
}
- (void)cancelBarButtonAction {
    XDPhotoViewController *photoVC = (XDPhotoViewController *)self.navigationController;
    if (photoVC.photoCompleteHandler) {
        photoVC.photoCompleteHandler(nil, XDPhotoStatusCancel);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
- (void)setAlbumArray:(NSArray *)albumArray {
    _albumArray = albumArray;
    [self.tableView reloadData];
    if (_albumArray.count > 0) {
        XDPhotoAssetViewController *assetVC = [[XDPhotoAssetViewController alloc]init];
        assetVC.albumModel = _albumArray.firstObject;
        [self.navigationController pushViewController:assetVC animated:NO];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XDPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:aCellId forIndexPath:indexPath];
    XDPhotoAlbumModel *model = self.albumArray[indexPath.row];
    cell.model = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XDPhotoAlbumModel *model = self.albumArray[indexPath.row];
    XDPhotoAssetViewController *assetVC = [[XDPhotoAssetViewController alloc]init];
    assetVC.albumModel = model;
    [self.navigationController pushViewController:assetVC animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
@end
