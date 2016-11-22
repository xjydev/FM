//
//  WebDetailViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "WebDetailViewController.h"
#import "XTools.h"
@interface WebDetailViewController ()<UIWebViewDelegate,UIScrollViewDelegate>
{
    UIWebView *_mainWebView;
}
@end

@implementation WebDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _mainWebView.delegate = self;
    _mainWebView.scrollView.delegate = self;
    _mainWebView.scalesPageToFit = YES;
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrlStr]]];
    NSLog(@"web==%@",self.webUrlStr);
    self.view = _mainWebView;
}
- (void)setWebUrlStr:(NSString *)webUrlStr {
    if ([webUrlStr hasPrefix:@"http"]) {
        _webUrlStr = webUrlStr;
    }
    else
    {
        _webUrlStr =[NSString stringWithFormat:@"https://www.baidu.com/s?wd=%@",webUrlStr];
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [XTools startLoadingWithTitle:@"加载中……"];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    [XTools finishLoading];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
