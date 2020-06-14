//
//  XYButton.m
//  FileManager
//
//  Created by xiaodev on Aug/13/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "XYButton.h"

@implementation XYButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.borderColor = self.currentTitleColor.CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 3.0;
}


@end
