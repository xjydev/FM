//
//  XDPurchase.m
//  Wenjian
//
//  Created by XiaoDev on 2019/5/16.
//  Copyright © 2019 XiaoDev. All rights reserved.
//

#import "XDPurchase.h"
#import "XTools.h"
#import <StoreKit/StoreKit.h>
#import <AFNetworking/AFNetworking.h>

@interface XDPurchase ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (nonatomic, copy)PurchaseCompleteHandler purchaseCompleteHandler;
@property (nonatomic, copy)NSString *productId;
@end

static XDPurchase *purchaseObject = nil;
@implementation XDPurchase
+ (instancetype)defaultManager {
    if (!purchaseObject) {
        purchaseObject = [[XDPurchase alloc]init];
    }
    return purchaseObject;
}
- (instancetype)init {
    self = [super init];
    if (self) {
       [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    }
    return self;
}
- (BOOL)purchaseProductId:(nullable NSString *)productId complete:(PurchaseCompleteHandler)handler {
    self.productId =  productId;
    self.purchaseCompleteHandler = handler;
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请打开网络" message:@"此页面操作需要连接网络，请打开网络再次操作！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                [XTOOLS umengClick:@"paynetworkcancel"];
                [alert dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
            UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"打开网络" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [XTOOLS umengClick:@"paynetworkopen"];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
            [alert addAction:cancleAction];
            [alert addAction:sureAction];
            [XTOOLS.topViewController presentViewController:alert animated:YES completion:^{
                
            }];
        }
        else {
            @strongify(self);
            [self startPay];
        }
        [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    }];
    
    return YES;
}
- (void)startPay {
    if ([SKPaymentQueue canMakePayments]) {
        [XTOOLS showLoading:@"加载中"];
        if (self.productId.length > 0) {//如果有值就购买，无值就恢复。
            NSSet *paySet = [NSSet setWithArray:@[self.productId]];
            SKProductsRequest *payRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:paySet];
            if (!payRequest.delegate) {
                payRequest.delegate = self;
            }
            [XTOOLS umengClick:@"payStart"];
            [payRequest start];
        }
        else {
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        }
    }
    else {
        [XTOOLS showAlertTitle:@"无法支付" message:@"此设备无法支付，请检查您的设备或App Store账号。" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
            
        }];
    }
}
#pragma mark -- 获取App Store产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self viewUserInteractionEnabled:NO];
    NSArray *myProducts = response.products;
    NSLog(@"request ==%@",response);
    if (myProducts.count == 0) {
        [XTOOLS hiddenLoading];
        [self viewUserInteractionEnabled:YES];
        [XTOOLS showAlertTitle:@"支付失败" message:@"没有获取支付信息，请重试。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
            [XTOOLS hiddenLoading];
        }];
    }
    else {
        [XTOOLS showLoading:@"加载中"];
        [self viewUserInteractionEnabled:NO];
        for (SKProduct *product in myProducts) {
            SKMutablePayment *mpayment = [SKMutablePayment paymentWithProduct:product];
            if ([[SKPaymentQueue defaultQueue]respondsToSelector:@selector(addPayment:)]) {
                [[SKPaymentQueue defaultQueue]addPayment:mpayment];
            }
            else {
                [XTOOLS hiddenLoading];
                [self viewUserInteractionEnabled:YES];
                [XTOOLS showAlertTitle:@"支付失败" message:@"支付失败，可以重新尝试。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                    
                }];
            }
        }
    }
}
#pragma mark -- 支付结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    [XTOOLS showLoading:@"信息确认中"];
    [self viewUserInteractionEnabled:NO];
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"state == %@",@(transaction.transactionState));
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                NSLog(@"123========交易完成========");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing://商品添加进列表
            {
                NSLog(@"123========添加进列表========");
                if (![transaction.payment.productIdentifier isEqualToString:self.productId]) {
                    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                }
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过商品
            {
                NSLog(@"123========已购买========");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                NSLog(@"123========失败交易========");
                [XTOOLS showMessage:@"交易失败"];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                [XTOOLS hiddenLoading];
                [self viewUserInteractionEnabled:YES];
            }
                break;
                
            default:
                break;
        }
        
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    NSString * errorstr = @"购买失败";
    NSString * contentStr = @"购买失败，可以重新尝试。";
    [self viewUserInteractionEnabled:YES];
    [XTOOLS showAlertTitle:errorstr message:contentStr buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
        
    }];
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"==============finished===========");
}

//沙盒测试环境验证
#if DEBUG
#define AppStore @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
#endif
- (void)verifyPurchaseWithPaymentTransaction{
    [XTOOLS showLoading:@"确认中"];
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = NO;
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json",@"text/javascript",@"application/json",@"text/plain",@"text/html",@"application/xhtml+xml",@"application/xml",nil];
    manager.responseSerializer = responseSerializer;
    NSDictionary *parameter = @{@"receipt-data":receiptString};
    [manager POST:AppStore parameters:parameter headers:nil constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self viewUserInteractionEnabled:YES];
        [XTOOLS hiddenLoading];
        NSDictionary *dic = responseObject;
        if (self.purchaseCompleteHandler) {
            self.purchaseCompleteHandler(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       [self viewUserInteractionEnabled:YES];
        [XTOOLS hiddenLoading];
        NSLog(@"验证订阅过程中发生错误，错误信息：%@",error.localizedDescription);
        NSString *  errorstr = @"购买失败";
        NSString *  contentStr = @"购买失败，可以重新尝试。如果扣款成功，不会再次扣款。";
        
        [XTOOLS showAlertTitle:errorstr message:contentStr buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
            
        }];
    }];
}
- (void) viewUserInteractionEnabled:(BOOL)is{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = is;
    });
}
- (void)dealloc {
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
    [XTOOLS hiddenLoading];
}
@end
