//
//  HomePopViewController.h
//  Wenjian
//
//  Created by XiaoDev on 2019/5/5.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePopViewController : UIViewController
@property (nonatomic, strong)NSArray *popItems;
@property (nonatomic, copy) void (^pickerItemBlock)(NSNumber *num,NSString *str);
@end

NS_ASSUME_NONNULL_END
