//
//  DrawerViewController.m
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import "DrawerViewController.h"
#import "XTools.h"

@interface DrawerViewController ()
{
    
}
@property (nonatomic, strong) UIViewController *mainVC;
@property (nonatomic, strong) UIViewController *leftVC;
@property (nonatomic, assign) CGFloat leftWidth;
@property (nonatomic, strong) UIButton *coverBtn;
@end

@implementation DrawerViewController
+ (instancetype)shareDrawer {
    return (DrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}
- (instancetype)initMainVC:(UIViewController *)mainVC leftVC:(UIViewController *)leftVC leftWidth:(CGFloat)leftWidth {
    self = [super init];
    self.mainVC = mainVC;
    self.leftVC = leftVC;
    self.leftWidth = leftWidth;
    [self.view addSubview:self.leftVC.view];
    [self.view addSubview:self.mainVC.view];
    [self addChildViewController:self.leftVC];
    [self addChildViewController:self.mainVC];
    return self;
}
- (UIButton *)coverBtn {
    if (!_coverBtn) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverBtn.backgroundColor = [UIColor clearColor];
        _coverBtn.frame = self.mainVC.view.bounds;
        [_coverBtn addTarget:self action:@selector(closeLeftMenu) forControlEvents:UIControlEventTouchUpInside];
        [_coverBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panCloseLeftMenu:)]];
    }
    return _coverBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftVC.view.transform = CGAffineTransformMakeTranslation(-250, 0);
//    for (UIViewController *childVC in self.mainVC.childViewControllers) {
//        [self addScreenEdgePanGestureRecognizerToView:childVC.view];
//    }
    if ([self.mainVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *mainNav = (UINavigationController *)self.mainVC;
        [self addScreenEdgePanGestureRecognizerToView:mainNav.topViewController.view];
    }
    else {
        [self addScreenEdgePanGestureRecognizerToView:self.mainVC.view];
    }
}
- (void)addScreenEdgePanGestureRecognizerToView:(UIView *)view {
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(edgePanGesture:)];
    pan.edges = UIRectEdgeLeft;
    [view addGestureRecognizer:pan];
}

- (void)panCloseLeftMenu:(UIPanGestureRecognizer *)pan {
    float offsetX = [pan translationInView:pan.view].x;
    if (offsetX >0) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateChanged && offsetX >= -self.leftWidth ) {
        
        self.mainVC.view.transform = CGAffineTransformMakeTranslation(self.leftWidth + offsetX, 0);
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(offsetX*0.6, 0);
    }
    else
        if (pan.state == UIGestureRecognizerStateEnded ||pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
            if (offsetX > kScreen_Width *0.4 ) {
                [self openLeftMenu];
            }
            else
            {
                [self closeLeftMenu];
            }
        }
}
- (void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)pan {
    float offsetX = [pan translationInView:pan.view].x;
    if (pan.state == UIGestureRecognizerStateChanged && offsetX <= self.leftWidth ) {
        self.mainVC.view.transform = CGAffineTransformMakeTranslation(MAX(offsetX, 0), 0);
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(offsetX - self.leftWidth, 0);
    }
    else
        if (pan.state == UIGestureRecognizerStateEnded ||pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
            if (offsetX > kScreen_Width *0.4 ) {
                [self openLeftMenu];
            }
            else
            {
                [self closeLeftMenu];
            }
        }
}
- (void)openLeftMenu {
    
        [UIView animateWithDuration:0.25 animations:^{
            self.leftVC.view.transform = CGAffineTransformMakeTranslation(0, 0);
            self.mainVC.view.transform = CGAffineTransformMakeTranslation(self.leftWidth, 0);
        } completion:^(BOOL finished) {
            [self.mainVC.view addSubview:self.coverBtn];
        }];
    
}
- (void)closeLeftMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self.leftVC.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth, 0);
        self.mainVC.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.coverBtn removeFromSuperview];
    }];
}
- (void)pushViewController:(UIViewController *)vc {
    if (vc) {
        [(UINavigationController *)self.mainVC pushViewController:vc animated:NO];
    }
    [self closeLeftMenu];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (IsPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL)shouldAutorotate {
    return YES;
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
