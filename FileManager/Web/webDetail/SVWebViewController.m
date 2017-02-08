//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVWebViewControllerActivityChrome.h"
#import "SVWebViewControllerActivitySafari.h"
#import "SVWebViewController.h"
#import "XTools.h"
#import "XManageCoreData.h"
#import "DownLoadCenter.h"
#import <AFNetworking/AFNetworking.h>
#import <WebKit/WebKit.h>
#import "UMMobClick/MobClick.h"

@interface SVWebViewController () <UIWebViewDelegate,UIScrollViewDelegate,NSURLSessionDelegate>
{
    CGFloat    _offsetY;
    UIBarButtonItem *_rightBarButton;
    BOOL       _isCollector;//是否收藏；
    NSMutableArray  *_mArray;
    NSURLSessionDownloadTask *_downloadTask;//下载功能

}
@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;

@property (nonatomic, strong) UILabel   *urlLabel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURL *URL;


- (void)loadURL:(NSString *)URL;

- (void)updateToolbarItems;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation SVWebViewController

#pragma mark - Initialization

- (void)dealloc {
    [self.webView stopLoading];
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.webView.delegate = nil;
}

- (void)loadURL:(NSString *)urlStr {
   
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];

    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _mArray = [NSMutableArray arrayWithCapacity:0];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"goBack"] style:UIBarButtonItemStyleDone target:self action:@selector(leftGoBackButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"collect"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    [self.view addSubview: self.webView];
    [self updateToolbarItems];
    [self loadURL:self.urlStr];
}
- (void)leftGoBackButtonAction:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}
//收藏网站
- (void)rightBarButtonAction:(UIBarButtonItem *)item {
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *url = self.webView.request.URL.absoluteString;
    if (title!=nil && [url hasPrefix:@"http"]) {
        if (_isCollector) {
            if ([[XManageCoreData manageCoreData]deleteWebTitle:title url:url]) {
                self.backRefreshData(2);
                [_rightBarButton setImage:[UIImage imageNamed:@"collect"]];
                _isCollector = NO;
                [XTOOLS showMessage:@"已取消"];
            }
            else
            {
                [XTOOLS showMessage:@"取消失败"];
            }
            
        }
        else
        {
            if ([[XManageCoreData manageCoreData] saveWebTitle:title url:url]) {
                self.backRefreshData(1);
                [_rightBarButton setImage:[UIImage imageNamed:@"collected"]];
                _isCollector = YES;
                [XTOOLS showMessage:@"收藏成功"];
            }
            else
            {
                [XTOOLS showMessage:@"收藏失败"];
            }
        }

    }
    else
    {
      [XTOOLS showMessage:@"收藏失败"];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
	[super viewWillAppear:animated];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    [MobClick beginLogPageView:@"webDetail"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [XTOOLS hiddenLoading];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    [MobClick endLogPageView:@"webDetail"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Getters
- (UIWebView*)webView {
    if(!_webView) {
        _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 64, kScreen_Width, kScreen_Height - 108)];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        _urlLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 30)];
        _urlLabel.textColor = [UIColor lightGrayColor];
        
        _urlLabel.textAlignment = NSTextAlignmentCenter;
        [_webView insertSubview:_urlLabel belowSubview:_webView.scrollView];
        _webView.scrollView.delegate = self;
        
    }
    return _webView;
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

- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return _actionBarButtonItem;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = self.self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.self.webView.canGoForward;
    self.actionBarButtonItem.enabled = !self.self.webView.isLoading;
    
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
                          self.actionBarButtonItem,
                          fixedSpace,
                          nil];
        
        self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.toolbarItems = items;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [XTOOLS showLoading:nil];
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [XTOOLS hiddenLoading];
    _urlLabel.text = webView.request.URL.host;
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [self updateToolbarItems];
    [self judgeIsCollected:webView.request.URL.absoluteString];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"fail === %@",webView.request.URL.absoluteString);
    [XTOOLS showMessage:@"加载失败！"];
    [XTOOLS hiddenLoading];
    [self updateToolbarItems];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    
    NSURLSessionConfiguration *sessionConf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConf.discretionary = YES;
    NSURLSession *downSession = [NSURLSession sessionWithConfiguration:sessionConf delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask * downTask = [downSession downloadTaskWithRequest:request];
    [downTask resume];
    return YES;

}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}
- (void)downloadUrl:(NSString *)urlStr {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否下载链接内容" message:urlStr  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *downloadAction =[UIAlertAction actionWithTitle:@"下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    UIAlertAction *loadAction =[UIAlertAction actionWithTitle:@"继续加载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        
    }];
    
    [alert addAction:downloadAction];
    [alert addAction:loadAction];
    [alert addAction:cancleAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];

}
//判断是否已经收藏
- (void)judgeIsCollected:(NSString *)str {
    if ([[XManageCoreData manageCoreData]searchWebUrl:str]) {
        [_rightBarButton setImage:[UIImage imageNamed:@"collected"]];
        _isCollector = YES;
    }
    else
    {
        [_rightBarButton setImage:[UIImage imageNamed:@"collect"]];
        _isCollector = NO;
    }
    
}
#pragma mark - Target actions

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
    
    NSArray *activities = @[[SVWebViewControllerActivitySafari new]];
    //, [SVWebViewControllerActivityChrome new]
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.request.URL] applicationActivities:activities];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIPopoverController *popover = [[UIPopoverController alloc]initWithContentViewController:activityController];
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }else
    {
       [self presentViewController:activityController animated:YES completion:nil];
    }
   
}

- (void)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _webView.scrollView) {
        if (_offsetY<_webView.scrollView.contentOffset.y&&_webView.scrollView.contentOffset.y<_webView.scrollView.contentSize.height-kScreen_Height&&_webView.scrollView.contentOffset.y>0) {
            self.navigationController.navigationBarHidden = YES;
            self.navigationController.toolbarHidden = YES;
            _webView.frame = CGRectMake(0, 20, kScreen_Width, kScreen_Height -20);
        }
        else
        {
            self.navigationController.navigationBarHidden = NO;
            self.navigationController.toolbarHidden = NO;
            _webView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height-108);
        }
        _offsetY = _webView.scrollView.contentOffset.y;
    }
}

@end
