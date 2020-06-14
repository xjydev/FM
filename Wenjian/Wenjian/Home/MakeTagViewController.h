//
//  MakeTagViewController.h
//  Wenjian
//
//  Created by xiaodev on Oct/19/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BackTagHandler)(int);
@interface MakeTagViewController : UIViewController
+ (MakeTagViewController *)viewControllerFromStoryboard;
- (void)makeTagBackHandler:(BackTagHandler)backTagHandeler;
@end
