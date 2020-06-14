//
//  PopViewController.h
//  player
//
//  Created by XiaoDev on 2018/6/7.
//  Copyright © 2018 Xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface PopViewController : UIViewController
+ (instancetype)returnFromStoryBoard;
@property (nonatomic, copy) void (^completeSelectBlock)(NSInteger index) ;
@end
