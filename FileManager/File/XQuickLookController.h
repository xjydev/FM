//
//  XQuickLookController.h
//  FileManager
//
//  Created by xiaodev on Dec/23/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
@interface XQuickLookController : QLPreviewController
@property (nonatomic, strong)NSArray *itemArray;
@property (nonatomic, assign)NSInteger currentIndex;
@end
