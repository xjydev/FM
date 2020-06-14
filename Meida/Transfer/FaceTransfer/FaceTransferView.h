//
//  FaceTransferView.h
//  FileManager
//
//  Created by xiaodev on Feb/21/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceTransferView : UIView
+(instancetype)defaultTransfer;
- (void)showQRCodeWithStr:(NSString *)str;
@end
