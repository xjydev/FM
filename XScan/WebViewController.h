//
//  WebViewController.h
//  QRcreate
//
//  Created by xiaodev on Mar/26/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ BackRefreshData )(NSInteger state);
@interface WebViewController : UIViewController
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, assign)BOOL   noBackRoot;
@property (nonatomic, strong)BackRefreshData backRefreshData;
@end
