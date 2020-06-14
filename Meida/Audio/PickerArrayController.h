//
//  PickerArrayController.h
//  FileManager
//
//  Created by XiaoDev on 23/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerArrayController : UITableViewController
+ (instancetype)pickerControllerFromStroyboardType:(NSInteger)type;
@property (nonatomic, copy) void (^pickerArrayBlock)(NSNumber *num,NSString *str);
@end
