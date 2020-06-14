//
//  WebViewController.m
//  QRcreate
//
//  Created by xiaodev on Mar/26/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "UIColor+Hex.h"
#import "XTools.h"
#import "ShareView.h"
#import "XManageCoreData.h"
#import "SVWebViewControllerActivityChrome.h"
#import "SVWebViewControllerActivitySafari.h"

@interface WebViewController ()<WKNavigationDelegate, WKUIDelegate,UIScrollViewDelegate,NSURLSessionDelegate>
{
    CGFloat    _offsetY;
    UIBarButtonItem *_cancleBackBar;
    BOOL       _isCollector;//是否收藏；
}
@property (nonatomic, strong) UIBarButtonItem *barckBar;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *collectBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;

@end

@implementation WebViewController
- (UIBarButtonItem *)barckBar {
    if (!_barckBar) {
        _barckBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonAction)];
    }
    return _barckBar;
} 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    float top = 64;
    float bottom = 44;
    if (kDevice_Is_iPhoneX) {
        top = 88;
        bottom = 78;
    }
    //创建网页配置对象
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsAirPlayForMediaPlayback = YES;
    // 创建设置对象
    WKPreferences *preference = [[WKPreferences alloc]init];
    //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
    preference.minimumFontSize = 0;
    //设置是否支持javaScript 默认是支持的
    preference.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preference;
    
    // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
    config.allowsInlineMediaPlayback = YES;
    //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
    config.requiresUserActionForMediaPlayback = YES;
    //设置是否允许画中画技术 在特定设备上有效
    config.allowsPictureInPictureMediaPlayback = YES;
    //设置请求的User-Agent信息中应用程序名称 iOS9后可用
    config.applicationNameForUserAgent = @"XiaoDev";
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, top, kScreen_Width, kScreen_Height-top - bottom) configuration:config];
    NSURL *path = [NSURL URLWithString:self.urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:path]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
    
    if (@available(iOS 11.0, *)) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        WKHTTPCookieStore *cookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
        if (cookies.count > 0) {
            for (NSHTTPCookie *cookie in cookies) {
                [cookieStore setCookie:cookie completionHandler:^{
                    
                }];
            }
        }
    }
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
    self.progressView.progressViewStyle = UIProgressViewStyleBar;
    self.progressView.progressTintColor = [UIColor ora_colorWithHex:0x05BC00];
    self.progressView.trackTintColor = kDarkCOLOR(0xffffff);
    [self.webView addSubview:self.progressView];
    
    self.navigationItem.leftBarButtonItem = self.barckBar;
    UIBarButtonItem *moreBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStyleDone target:self action:@selector(moreBarButtonAction)];
    self.navigationItem.rightBarButtonItem = moreBar;
    
//    self.progressView.backgroundColor = [UIColor redColor];
    // 添加KVO监听
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self updateToolbarItems];
    self.navigationController.toolbarHidden = NO;

}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    NSLog(@"kvo === %@",keyPath);
    if (self.webView) {
        if ([keyPath isEqualToString:@"loading"]) {
            if (!self.webView.loading) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [UIView animateWithDuration:0.2 animations:^{
                    if (self.progressView) {
                      self.progressView.alpha = 0;
                    }
                }];
            }
            else {
                if (self.progressView) {
                    self.progressView.alpha = 1.0;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                }
            }
            NSLog(@"loading");
        } else if ([keyPath isEqualToString:@"title"]) {
            self.title = self.webView.title;
        } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
            if (self.progressView) {
                NSLog(@"progress: %f", self.webView.estimatedProgress);
                self.progressView.progress = self.webView.estimatedProgress;
            }
        }
    }
}

- (void)canWebGoBackLeftItem {
    UIBarButtonItem *cancleBackBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelBack"] style:UIBarButtonItemStyleDone target:self action:@selector(cancleBackBarButtonAction)];
    self.navigationItem.leftBarButtonItems = @[self.barckBar,cancleBackBar];
    
}
- (void)moreBarButtonAction {
    NSLog(@"more更多");
    if (self.urlStr) {
       [[ShareView shareView]shareViewWithUrl:self.urlStr Title:self.title];
    }
    else {
        [XTOOLS showMessage:@"无连接"];
    }
}
- (void)cancleBackBarButtonAction {
    [self.webView stopLoading];
    self.navigationController.toolbarHidden = YES;
    if (self.noBackRoot) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
         [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)backBarButtonAction {
    if ([self.webView canGoBack]) {
        [self canWebGoBackLeftItem];
        [self.webView goBack];
    }
    else {
        [self.webView stopLoading];
        self.navigationController.toolbarHidden = YES;
        if (self.noBackRoot) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateToolbarItems];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   self.navigationItem.title = webView.title;
   [self updateToolbarItems];
    [self judgeIsCollected:webView.URL.absoluteString];
    [[XManageCoreData manageCoreData]saveWebHistoryTitle:webView.title url:webView.URL.absoluteString];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error2====%@",error);
    if (error.code == NSURLErrorCannotConnectToHost) {
        [XTOOLS showAlertTitle:@"无法连接网络" message:@"你可以检查手机和应用网络设置" buttonTitles:@[@"取消",@"打开设置"] completionHandler:^(NSInteger num) {
            if (num == 1) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error1==%@",error);
    [self updateToolbarItems];
    [self.webView stopLoading];
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    [XTOOLS showMessage:@"加载错误"];
}
//判断是否已经收藏
- (void)judgeIsCollected:(NSString *)str {
    if ([[XManageCoreData manageCoreData]searchWebUrl:str]) {
        [self.collectBarButtonItem setImage:[UIImage imageNamed:@"collected"]];
        _isCollector = YES;
    }
    else {
        [self.collectBarButtonItem setImage:[UIImage imageNamed:@"collect"]];
        _isCollector = NO;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.webView && scrollView == self.webView.scrollView) {
        if (_offsetY<self.webView.scrollView.contentOffset.y&&self.webView.scrollView.contentOffset.y<self.webView.scrollView.contentSize.height-kScreen_Height&&self.webView.scrollView.contentOffset.y>0) {
            self.navigationController.navigationBarHidden = YES;
            self.navigationController.toolbarHidden = YES;
            float top = 20;
            float bottom = 0;
            if (kDevice_Is_iPhoneX) {
                top = 44;
                bottom = 34;
            }
            self.webView.frame = CGRectMake(0, top, kScreen_Width, kScreen_Height -top - bottom);
        }
        else {
            self.navigationController.navigationBarHidden = NO;
            self.navigationController.toolbarHidden = NO;
            float top = 64;
            float bottom = 44;
            if (kDevice_Is_iPhoneX) {
                top = 88;
                bottom = 78;
            }
            self.webView.frame = CGRectMake(0, top, kScreen_Width, kScreen_Height-top - bottom);
        }
        _offsetY = self.webView.scrollView.contentOffset.y;
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
   if(navigationAction.targetFrame ==nil) {
    [webView loadRequest:navigationAction.request];

    }
    decisionHandler( WKNavigationActionPolicyAllow );
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    NSLog(@"web dealloc");
    [self.webView stopLoading];
    if (self.webView) {
        self.webView.scrollView.delegate = nil;//不加会崩
        [self.webView removeObserver:self forKeyPath:@"loading"];
        [self.webView removeObserver:self forKeyPath:@"title"];
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WebBack"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goBackClicked:)];
        _backBarButtonItem.width = 18.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WebNext"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goForwardClicked:)];
        _forwardBarButtonItem.width = 18.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    if (!_stopBarButtonItem) {
        _stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return _stopBarButtonItem;
}
- (UIBarButtonItem *)collectBarButtonItem {
    if (!_collectBarButtonItem) {
        _collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"collect"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(collectBarButtonAction:)];
    }
    return _collectBarButtonItem;
}
- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return _actionBarButtonItem;
}
- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = self.self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.self.webView.canGoForward;
    self.actionBarButtonItem.enabled = !self.self.webView.isLoading;
    self.collectBarButtonItem.enabled = !self.self.webView.isLoading;
    UIBarButtonItem *refreshStopBarButtonItem = self.self.webView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = [NSArray arrayWithObjects:
                      fixedSpace,
                      self.backBarButtonItem,
                      flexibleSpace,
                      self.forwardBarButtonItem,
                      flexibleSpace,
                      refreshStopBarButtonItem,
                      flexibleSpace,
                      self.collectBarButtonItem,
                      flexibleSpace,
                      self.actionBarButtonItem,
                      fixedSpace,
                      nil];
    
    self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
    self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
    [self setToolbarItems:items animated:YES];
}
- (void)collectBarButtonAction:(UIBarButtonItem *)sender {
    NSString *title = self.webView.title;
    NSString *url = self.webView.URL.absoluteString;
    if (title!=nil && [url hasPrefix:@"http"]) {
        if (_isCollector) {
            if ([[XManageCoreData manageCoreData]deleteWebTitle:title url:url]) {
                [self.collectBarButtonItem setImage:[UIImage imageNamed:@"collect"]];
                _isCollector = NO;
                [XTOOLS showMessage:@"已取消"];
            }
            else {
                [XTOOLS showMessage:@"取消失败"];
            }
        }
        else
        {
            if ([[XManageCoreData manageCoreData] saveWebTitle:title url:url]) {
                [self.collectBarButtonItem setImage:[UIImage imageNamed:@"collected"]];
                _isCollector = YES;
                [XTOOLS showMessage:@"收藏成功"];
            }
            else {
                [XTOOLS showMessage:@"收藏失败"];
            }
        }
    }
    else {
        [XTOOLS showMessage:@"收藏失败"];
    }
}
- (void)goBackClicked:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [self.webView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [self.webView stopLoading];
    [self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender {
    if (self.webView.URL) {
        NSArray *activities = @[[SVWebViewControllerActivitySafari new]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.URL] applicationActivities:activities];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        activityController.popoverPresentationController.barButtonItem = sender;
            activityController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:activityController animated:YES completion:^{
                
            }];

        } else {
            [self presentViewController:activityController animated:YES completion:nil];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS hiddenLoading];
    [self.webView stopLoading];
    self.navigationController.toolbarHidden = YES;
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
}
@end
