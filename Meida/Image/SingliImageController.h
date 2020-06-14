//
//  SingliImageController.h
//  FileManager
//
//  Created by XiaoDev on 14/04/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SingleImageBack)(NSInteger index,NSInteger type);
@interface SingliImageController : UIViewController
+ (instancetype)viewControllerFromeStoryBoard;
@property (nonatomic, assign)NSInteger  index;
@property (nonatomic,strong)SingleImageBack selectedBack;
@end
