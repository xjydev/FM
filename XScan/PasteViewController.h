//
//  PasteViewController.h
//  QRcreate
//
//  Created by xiaodev on Aug/31/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasteViewController : UIViewController
{
    __weak IBOutlet UITextView *_mainTextVIew;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    
}
@property (nonatomic, copy)NSString *pasteStr;
@end
