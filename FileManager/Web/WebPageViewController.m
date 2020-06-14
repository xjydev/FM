//
//  WebPageViewController.m
//  FileManager
//
//  Created by XiaoDev on 2017/12/27.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import "WebPageViewController.h"
#import "WebViewController.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import <AFNetworking/AFNetworking.h>
@interface WebPageViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>
{
    NSMutableArray     *_searchArray;
    UISearchBar        *_searchBar;
    UIBarButtonItem    *_leftBar;
    UIBarButtonItem    *_rightBar;
    NSArray            *_homeArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@end

@implementation WebPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = kDarkCOLOR(0xffffff);
       if (@available(iOS 11.0, *)) {
           self.mainCollectionView .contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
       }else {
           self.automaticallyAdjustsScrollViewInsets = NO;
       }
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未连接网络" message:@"连接网络，才能搜索和访问网页，是否检查应用网络设置？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                
                //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
            }];
            [alert addAction:cancleAction];
            [alert addAction:sureAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
        [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    }];
    _leftBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"collectHistory"] style:UIBarButtonItemStyleDone target:self action:@selector(leftScanButtonAction:)];
    self.navigationItem.leftBarButtonItem = _leftBar;
    _rightBar = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Search", nil) style:UIBarButtonItemStyleDone target:self action:@selector(rightDownLoadButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBar;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width - 80, 40)];
    _searchBar.barTintColor = kNavCOLOR;
    _searchBar.placeholder = NSLocalizedString(@"Search or enter the url", nil);
    [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _searchBar.keyboardType = UIKeyboardTypeURL;
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    [kNOtificationC addObserver:self selector:@selector(webPageShow) name:kWebPage object:nil];
    //1，百度，2，QQ，3.头条 4，UC
    [self webPageShow];
}
- (void)webPageShow {
    if ([kUSerD boolForKey:kWebPage]) {
        _homeArray = nil;
    }
    else {
     _homeArray =
        @[@[@{@"title":@"百度",@"image":@"web_baidu_y",@"url":@"https://m.baidu.com/",@"type":@"1"},
            @{@"title":@"腾讯",@"image":@"web_tengxun_y",@"url":@"https://xw.qq.com/",@"type":@"2"},
            @{@"title":@"淘宝",@"image":@"web_taobao_y",@"url":@"https://m.taobao.com/#index",@"type":@"2"},
            @{@"title":@"新浪",@"image":@"web_xinlang_y",@"url":@"https://sina.cn/",@"type":@"3"},
            @{@"title":@"搜狐",@"image":@"web_shouhu_y",@"url":@"http://m.sohu.com/",@"type":@"1"},
            @{@"title":@"美团",@"image":@"web_wangyi_y",@"url":@"http://meituan.com/",@"type":@"1"},],
    //      //视频
    //      @[@{@"title":@"腾讯视频",@"image":@"web_txshipin",@"url":@"http://m.v.qq.com/index.html",@"type":@"2"},
    //        @{@"title":@"优酷视频",@"image":@"web_youku",@"url":@"https://www.youku.com/",@"type":@"1"},
    //        @{@"title":@"爱奇艺",@"image":@"web_iqiyi",@"url":@"http://m.iqiyi.com/",@"type":@"2"},
    //        @{@"title":@"搜狐视频",@"image":@"web_souhu",@"url":@"https://m.tv.sohu.com/",@"type":@"3"},
    //        @{@"title":@"影视视频",@"image":@"web_shipin",@"url":@"http://6v.129yue.com/?http://mp.weixinbridge.com/mp/wapredirect?url=http",@"type":@"2"},
    //        @{@"title":@"哔哩哔哩",@"image":@"web_bili",@"url":@"https://m.bilibili.com/index.html",@"type":@"1"},],
          //新闻
          @[@{@"title":@"天天快报",@"image":@"web_tiantiankuaibao_y",@"url":@"http://kb.qq.com/local.htm",@"type":@"2"},
            @{@"title":@"今日头条",@"image":@"web_jinritoutiao_y",@"url":@"https://m.toutiao.com/?W2atIF=1",@"type":@"3"},
            @{@"title":@"一点资讯",@"image":@"web_yidianzixun_y",@"url":@"http://www.yidianzixun.com",@"type":@"2"},
            @{@"title":@"澎湃新闻",@"image":@"web_pengpaixinwen_y",@"url":@"http://m.thepaper.cn/",@"type":@"1"},
            @{@"title":@"百度新闻",@"image":@"web_baiduxinwen_y",@"url":@"https://news.baidu.com/",@"type":@"1"},
            @{@"title":@"凤凰新闻",@"image":@"web_fenghuangxinwen_y",@"url":@"http://i.ifeng.com/",@"type":@"1"},
          @{@"title":@"人民网",@"image":@"web_renminwang_y",@"url":@"http://m.people.cn/",@"type":@"1"},
          @{@"title":@"新华网",@"image":@"web_xinhuawang_y",@"url":@"http://m.xinhuanet.com/",@"type":@"1"},
          @{@"title":@"光明网",@"image":@"web_guangmingwang_y",@"url":@"http://m.gmw.cn/",@"type":@"1"},
          @{@"title":@"央视网",@"image":@"web_yangshiwang_y",@"url":@"http://m.cctv.com/",@"type":@"1"},
          @{@"title":@"环球网",@"image":@"web_huanqiuwang_y",@"url":@"https://m.huanqiu.com/",@"type":@"1"},
          @{@"title":@"参考消息",@"image":@"web_cankaoxiaoxi_y",@"url":@"http://m.cankaoxiaoxi.com/",@"type":@"1"},],
        @[@{@"title":@"天猫",@"image":@"web_tianmao_y",@"url":@"https://jx.tmall.com/",@"type":@"1"},
          @{@"title":@"京东",@"image":@"web_jingdong_y",@"url":@"https://m.jd.com/",@"type":@"1"},
          @{@"title":@"聚美优品",@"image":@"web_jumeiyoupin_y",@"url":@"http://h5.jumei.com/",@"type":@"1"},
          @{@"title":@"当当网",@"image":@"web_dangdangwang_y",@"url":@"http://m.dangdang.com/",@"type":@"1"},
          @{@"title":@"唯品会",@"image":@"web_weipinhui_y",@"url":@"https://m.vip.com/",@"type":@"1"},
          @{@"title":@"亚马逊",@"image":@"web_yamaxun_y",@"url":@"https://www.amazon.cn/",@"type":@"1"},],
        @[@{@"title":@"易车网",@"image":@"web_yichewang_y",@"url":@"http://m.yiche.com/",@"type":@"1"},
          @{@"title":@"汽车之家",@"image":@"web-qichehzijia_y",@"url":@"https://m.autohome.com.cn/",@"type":@"1"},
          @{@"title":@"58同城",@"image":@"web_58tongcheng_y",@"url":@"http://m.58.com/",@"type":@"1"},
          @{@"title":@"赶集网",@"image":@"web_ganjiwang_y",@"url":@"https://3g.ganji.com/",@"type":@"1"},
          @{@"title":@"去哪儿",@"image":@"web_quna_y",@"url":@"http://touch.qunar.com/",@"type":@"1"},
          @{@"title":@"携程",@"image":@"web_xiecheng_y",@"url":@"https://m.ctrip.com/",@"type":@"1"},
          @{@"title":@"拉勾网",@"image":@"web_lagouwang_y",@"url":@"https://m.lagou.com/",@"type":@"1"},
          @{@"title":@"猎聘网",@"image":@"web_liepinwang_y",@"url":@"https://m.liepin.com/",@"type":@"1"},
          @{@"title":@"链家",@"image":@"web_lianjia_y",@"url":@"https://m.lianjia.com",@"type":@"1"},
          @{@"title":@"房天下",@"image":@"web-fangtianxia_y",@"url":@"https://m.fang.com/",@"type":@"1"},],
        @[
          @{@"title":@"知乎",@"image":@"web_zhihu_y",@"url":@"https://www.zhihu.com/",@"type":@"1"},
          @{@"title":@"豆瓣",@"image":@"web_douban_y",@"url":@"https://m.douban.com/",@"type":@"1"},
          @{@"title":@"百度百科",@"image":@"web_baidubaike_y",@"url":@"https://wapbaike.baidu.com/",@"type":@"1"},
          @{@"title":@"百度贴吧",@"image":@"web_baidutieba_y",@"url":@"https://tieba.baidu.com/",@"type":@"1"},
          @{@"title":@"糗事百科",@"image":@"web_qiushibaike_y",@"url":@"https://www.qiushibaike.com/",@"type":@"1"},
          @{@"title":@"快看漫画",@"image":@"web_kuaikanmanhua_y",@"url":@"http://m.kuaikanmanhua.com/",@"type":@"1"},
          @{@"title":@"起点\n中文网",@"image":@"web_qidianzhongwenwang_y",@"url":@"https://m.qidian.com/",@"type":@"1"},
          @{@"title":@"百度音乐",@"image":@"web_baiduyinyue_y",@"url":@"http://music.baidu.com/",@"type":@"1"},
          @{@"title":@"网易\n云音乐",@"image":@"web_wangyiyunyinyue_y",@"url":@"http://music.163.com/m/",@"type":@"1"},
          ],
        @[
          @{@"title":@"stack overflow",@"image":@"web_stackoverflow_y",@"url":@"https://stackoverflow.com/",@"type":@"1"},
          @{@"title":@"github",@"image":@"web_github_y",@"url":@"https://github.com/",@"type":@"1"},
          @{@"title":@"CSDN",@"image":@"web_CSDN_y",@"url":@"https://www.csdn.net/",@"type":@"1"},
          @{@"title":@"cocoa china",@"image":@"web_cocoachina_y",@"url":@"http://www.cocoachina.com/",@"type":@"1"},
          @{@"title":@"w3 school",@"image":@"web_w3school_y",@"url":@"http://www.w3school.com.cn/",@"type":@"1"},
          @{@"title":@"Android",@"image":@"web_Android_y",@"url":@"http://hukai.me/android-training-course-in-chinese/index.html",@"type":@"1"},
          ]];
    }
    [self.mainCollectionView reloadData];
}
- (void)leftScanButtonAction:(UIBarButtonItem *)item {
    [self performSegueWithIdentifier:@"HistoryViewController" sender:nil];
}
- (void)rightDownLoadButtonAction:(UIBarButtonItem *)item {
    if (_searchBar.text.length>0) {
      [self gotoWebWithSearchText:_searchBar.text];
    }
    else
    {
        [_searchBar becomeFirstResponder];
        [XTOOLS showMessage:NSLocalizedString(@"Input", nil)];
    }
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"===%@",text);
    if ([text isEqualToString:@"\n"]&&searchBar.text.length>0) {
        
        [self gotoWebWithSearchText:_searchBar.text];
    }
    return YES;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = _homeArray[section];
    return array.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _homeArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"webpagecell" forIndexPath:indexPath];
    cell.backgroundColor = kDarkCOLOR(0xffffff);
     NSArray *array = _homeArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    UIImageView *imageView = [cell viewWithTag:401];
    UILabel   *label = [cell viewWithTag:402];
    [imageView setImage:[UIImage imageNamed:dict[@"image"]]];
    label.text =dict[@"title"];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreen_Width-10)/6, 80);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
      return CGSizeMake(kScreen_Width, 30);
    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
//        if (indexPath.section!=0) {
            UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        header.backgroundColor = kDarkCOLOR(0xffffff);
        UILabel *label = [header viewWithTag:501];
        if (indexPath.section == 0) {
            label.text = @"推荐";
        }
        else
            if (indexPath.section == 1) {
                label.text = @"新闻";
            }
            else
            if (indexPath.section == 2) {
               label.text = @"购物";
            }
            else if (indexPath.section == 3) {
              label.text = @"生活";
            }
            else if (indexPath.section == 4) {
             label.text = @"知识";
            }
            else
            {
                label.text = @"技术";
            }
            
            return header;
    } else
    {
        return (UICollectionReusableView *)[[UIView alloc]init];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *array = _homeArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    [XTOOLS umEvent:@"webpage" label:dict[@"title"]];
    WebViewController *web = [[WebViewController alloc]init];
    web.hidesBottomBarWhenPushed = YES;
    web.urlStr = dict[@"url"];
//    web.Type = [dict[@"type"] integerValue];
    [self.navigationController pushViewController:web animated:YES];
    
}
-(void)gotoWebWithSearchText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    [_searchBar resignFirstResponder];
    
    //如果不是网址无法打开就百度搜索
    if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:text]]) {
        if ([text hasSuffix:@".com"]||[text hasSuffix:@".cn"]||[text hasPrefix:@"www."]||[text hasSuffix:@".net"]) {
            if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",text]]]) {
                text = [NSString stringWithFormat:@"http://%@",text];
            }
            else
                if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",text]]]) {
                    text = [NSString stringWithFormat:@"https://%@",text];
                }
            
        }
        else
        {
            NSString *encodedString = (NSString *)
            CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                      (CFStringRef)text,
                                                                      NULL,
                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                      kCFStringEncodingUTF8));
            text =[NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",encodedString];
        }
        
    }
    [self pushWebDetailWithurl:text];
}
- (void)pushWebDetailWithurl:(NSString *)url{
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.urlStr = url;
//    webViewController.Type = 0;
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.backRefreshData = ^(NSInteger state){
    };
    
    [self.navigationController pushViewController:webViewController animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
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
