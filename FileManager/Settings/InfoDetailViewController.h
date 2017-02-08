//
//  InfoDetailViewController.h
//  FileManager
//
//  Created by xiaodev on Feb/7/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , InfoDetailType) {
    InfoDetailTypeDevice,
    InfoDetailTypeApp,
};
@interface InfoDetailViewController : UIViewController
@property (nonatomic, assign)InfoDetailType type;
@end
