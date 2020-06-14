//
//  XDPurchase.h
//  Wenjian
//
//  Created by XiaoDev on 2019/5/16.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^PurchaseCompleteHandler)(NSDictionary  *_Nullable purchaseDict);
@interface XDPurchase : NSObject
+ (instancetype)defaultManager;
- (BOOL)purchaseProductId:(nullable NSString *)productId complete:(PurchaseCompleteHandler)handler;
@end

NS_ASSUME_NONNULL_END
