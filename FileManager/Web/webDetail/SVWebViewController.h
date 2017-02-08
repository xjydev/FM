//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

typedef void (^ BackRefreshData )(NSInteger state);
@interface SVWebViewController : UIViewController
@property (nonatomic ,copy)NSString * urlStr;
@property (nonatomic, strong)BackRefreshData backRefreshData;
@end
