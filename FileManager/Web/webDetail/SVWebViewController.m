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

@interface SVWebViewController () <UIWebViewDelegate,UIScrollViewDelegate>
{
    CGFloat    _offsetY;
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

//- (void)loadView {
//    
//    [self loadURL:self.URL];
//}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.webView];
    [self updateToolbarItems];
    [self loadURL:self.urlStr];
}

- (void)viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
	[super viewWillAppear:animated];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
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
        _webView = [[UIWebView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        //CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-44)
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        _urlLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 30)];
//        _urlLabel.backgroundColor = [UIColor redColor];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat toolbarWidth = 250.0f;
        fixedSpace.width = 35.0f;

        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          self.backBarButtonItem,
                          fixedSpace,
                          self.forwardBarButtonItem,
                          fixedSpace,
                          self.actionBarButtonItem,
                          nil];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }
    
    else {
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
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    _urlLabel.text = webView.request.URL.host;
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
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
        if (_offsetY<_webView.scrollView.contentOffset.y&&_webView.scrollView.contentOffset.y<_webView.scrollView.contentSize.height-_webView.scrollView.bounds.size.height&&_webView.scrollView.contentOffset.y>0) {
            self.navigationController.navigationBarHidden = YES;
            self.navigationController.toolbarHidden = YES;
        }
        else
        {
            self.navigationController.navigationBarHidden = NO;
            self.navigationController.toolbarHidden = NO;
        }
        _offsetY = _webView.scrollView.contentOffset.y;
    }
}

@end
