//
//  XTools.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XTools.h"
#import "AppDelegate.h"
#import "NewVideoViewController.h"
#import "XHUDView.h"
#import "XQuickLookController.h"
#import "AudioViewController.h"
#import "XDPhotoBrowerViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <StoreKit/StoreKit.h>
#include "sys/stat.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

static XTools *tools = nil;

@interface XTools()<GADBannerViewDelegate,GADInterstitialDelegate>
{
    GADBannerView             *_bannerView;//谷歌横条广告
}
@property (nonatomic, strong)UIActivityIndicatorView   *activityView;
@property (nonatomic, strong)UILabel                   *activityLabel;
//@property (nonatomic, strong)GADBannerView             *bannerView;//谷歌横条广告
@property (nonatomic, strong)UILabel *alertLabel;
@property (nonatomic, strong)GADInterstitial *interstitial;

@end
@implementation XTools
+ (instancetype)shareXTools {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[XTools alloc] init];
        
    });
    return tools;
}
+ (BOOL)isiPhoneX {
    if ([UIScreen mainScreen].bounds.size.width == 414 && [UIScreen mainScreen].bounds.size.height == 896) {
        return YES;
    }
    else if ([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 812){
        return YES;
    }
    else if ([UIScreen mainScreen].bounds.size.width ==896 && [UIScreen mainScreen].bounds.size.height == 414){
        return YES;
    }
    else if ([UIScreen mainScreen].bounds.size.width == 812 && [UIScreen mainScreen].bounds.size.height == 375){
        return YES;
    }
    return NO;
}
- (NSString *)hiddenFilePath {
    NSString *path = [NSString stringWithFormat:@"%@/.hiddenFile",KDocumentP];
    if (![kFileM fileExistsAtPath:path]) {
       [kFileM createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
    
}
- (NSDateFormatter *)dateFormater {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
        if (![_dateFormater.dateFormat isEqualToString:@"YYYY-MM-dd HH:mm:ss"]) {
            [_dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        }
    return _dateFormater;
}
- (NSString *)dateStr {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"YYYYMMDDHHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
        if (![_dateFormater.dateFormat isEqualToString:@"YYYYMMDDHHmmss"]) {
            [_dateFormater setDateFormat:@"YYYYMMDDHHmmss"];
        }
    
    NSDate *date = [NSDate date];
    _dateStr = [_dateFormater stringFromDate:date];
    return _dateStr;
}
- (NSString *)timeStr {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"HHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
        if (![_dateFormater.dateFormat isEqualToString:@"HHmmss"]) {
            [_dateFormater setDateFormat:@"HHmmss"];
        }
    NSDate *date = [NSDate date];
    _timeStr = [_dateFormater stringFromDate:date];
    return _timeStr;
}
#pragma mark - 播放文件
- (BOOL)playFileWithPath:(NSString *)path OrigionalWiewController:(UIViewController *)origionalWiewController; {
    switch ([self fileFormatWithPath:path]) {
        case FileTypeVideo:
        {
            NewVideoViewController *nvideo = [NewVideoViewController allocFromStoryBoard];
            nvideo.modalPresentationStyle = UIModalPresentationFullScreen;
            nvideo.videoPath = path;
            [nvideo getVideoArrayCurrentPath];
            [origionalWiewController presentViewController:nvideo animated:YES completion:^{
                
            }];
            
            
        }
            break;
        case FileTypeAudio:
        {
            AudioViewController *audio = [AudioViewController allocFromStoryBoard];
            audio.modalPresentationStyle = UIModalPresentationFullScreen;
            audio.audioPath = path;
            [audio getAudioArrayCurrentPath];
            [origionalWiewController presentViewController:audio animated:YES completion:^{
                
            }];
        }
             break;
        case FileTypeImage:
        {
            if (path) {
                XDPhotoBrowerViewController *VC = [[XDPhotoBrowerViewController alloc]init];
                VC.imagesArray = @[path];
                [origionalWiewController.navigationController pushViewController:VC animated:YES];
            }
            
            
        }
            break;
        case FileTypeDocument:
        {
            XQuickLookController *xql = [[XQuickLookController alloc]init];
            xql.itemArray = @[path];
            [origionalWiewController.navigationController pushViewController:xql animated:YES];
        }
            break;
        case FileTypeCompress:
        {
           return NO;
        }
            break;
            
            
        default://FileTypeDefault
        {
           return NO;
        }
            break;
    }
    return YES;
}

- (FileType )fileFormatWithPath:(NSString *)path {
    return [[XDFileManager defaultManager] fileFormatWithPath:path];
}
- (UILabel *)alertLabel {
    if (!_alertLabel) {
        _alertLabel = [[UILabel alloc]init];
        _alertLabel.bounds = CGRectMake(0, 0, 100, 40);
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.75];
        _alertLabel.textColor = [UIColor whiteColor];
        _alertLabel.layer.cornerRadius = 10;
        _alertLabel.layer.masksToBounds = YES;
        _alertLabel.hidden = YES;
        //        AppDelegate *app =(AppDelegate *)[UIApplication sharedApplication];
        _alertLabel.center = [UIApplication sharedApplication].keyWindow.center;
        [[UIApplication sharedApplication].keyWindow addSubview:_alertLabel];
    }
    return _alertLabel;
}

- (void)showMessage:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddAlertLabel) object:nil];
    self.alertLabel.bounds = CGRectMake(0, 0, 16*title.length+30, 40);
    self.alertLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, CGRectGetHeight([UIScreen mainScreen].bounds)/2); 
    [self.alertLabel.superview bringSubviewToFront:self.alertLabel];
    self.alertLabel.hidden = NO;
    self.alertLabel.text = title;
    [self performSelector:@selector(hiddAlertLabel) withObject:nil afterDelay:title.length * 0.2];
    });
    
}
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        UIView *asuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        asuperView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        asuperView.center =CGPointMake([UIApplication sharedApplication].keyWindow.center.x, [UIApplication sharedApplication].keyWindow.center.y-40);
        asuperView.layer.cornerRadius = 10;
        asuperView.layer.masksToBounds = YES;
        
        _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(10, 0, 80, 80);
        _activityView.color = [UIColor whiteColor];
        _activityView.hidesWhenStopped = YES;
        [asuperView addSubview:_activityView];
        [asuperView addSubview:self.activityLabel];
        [[UIApplication sharedApplication].keyWindow addSubview:asuperView];
        
    }
    return _activityView;
}
- (UILabel *)activityLabel {
    if (!_activityLabel) {
        _activityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 100, 20)];
        _activityLabel.textAlignment = NSTextAlignmentCenter;
        _activityLabel.font = [UIFont systemFontOfSize:14];
        _activityLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return _activityLabel;
}
- (void)hiddAlertLabel {
    [UIView animateWithDuration:0.2 animations:^{
        self.alertLabel.alpha = 0;
    } completion:^(BOOL finished) {
       self.alertLabel.hidden = YES;
        self.alertLabel.alpha = 1;
    }];
}
//completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler
- (void)showAlertTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSInteger i= 0; i<buttonTitles.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completionHandler) {
              completionHandler(i);
            }
        }];
        [alert addAction:action];
    }
   
    [self.topViewController presentViewController:alert animated:YES completion:^{
        
    }];
}
- (void)showAlertTextField:(NSString *)text placeholder:(NSString *)placeHolder title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num,NSString *textValue))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        UITextField *firstTextF = alert.textFields.firstObject;
        firstTextF.placeholder = placeHolder;
        firstTextF.text = text;
        for (NSInteger i= 0; i<buttonTitles.count; i++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (completionHandler) {
                    completionHandler(i,firstTextF.text);
                }
            }];
            [alert addAction:action];
        }
        
        [self.topViewController presentViewController:alert animated:YES completion:^{
            
        }];
    });
}
- (void)showLoading:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.activityView.superview.hidden = NO;
    self.activityLabel.text = title;
    [self.activityView startAnimating];
    });
}
- (void)hiddenLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.activityView.superview.hidden = YES;
    [self.activityView stopAnimating];
    });
}
- (double)timeStrToSecWithStr:(NSString *)str {
    double timeSec = 0;
    NSArray *array = [str componentsSeparatedByString:@":"]; 
    for (NSInteger i = 0; i<array.count; i++) {
        NSString *time = [array objectAtIndex:i];
        
       timeSec = timeSec *60 + labs([time integerValue]);
    }
    
    return timeSec;
}
- (NSString *)timeSecToStrWithSec:(double)sec {
    if (sec/3600>0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d",((int)sec)/3600,(((int)sec)%3600)/60,((int)sec)%60];
    }
    return [NSString stringWithFormat:@"%02d:%02d",(((int)sec)%3600)/60,((int)sec)%60];
    
}
- (float )folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}
- (long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}
//获取手机存储空间信息
- (float)allStorageSpace {
    NSDictionary *att = [kFileM attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    float total = [[att objectForKey:NSFileSystemSize] floatValue];
    return total;
}
- (float)freeStorageSpace {
    NSDictionary *att = [kFileM attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    float total = [[att objectForKey:NSFileSystemFreeSize] floatValue];
    return total;
}
- (NSString *)storageSpaceStringWith:(float)space {
    float sizeKb = space/1000;
    float sizeMb = sizeKb/1000;
    float sizeGb = sizeMb/1000;
    if (sizeGb > 1) {
        return [NSString stringWithFormat:@"%.2fG",sizeGb];
    }
    else if (sizeMb > 1) {
        return [NSString stringWithFormat:@"%.2fM",sizeMb];
    }
    else{
        return [NSString stringWithFormat:@"%.2fKB",sizeKb];
    }

}
#pragma mark -- 加密md5
- (NSString *)md5Fromstr:(NSString *)str {
    if (str) {
        const char *cStr = [str UTF8String];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        //把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了digest这个空间中
        CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", digest[i]];//x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
        return output;
    }
    return nil;
}
- (void)openVPN {
    [self showAlertTitle:@"访问方法" message:@"如果国外网站无法访问，可以去App Store搜索“免费VPN”，选择安装VPN翻墙软件，安装后配置打开VPN然后再次访问此网页。\n推荐“Green”VPN软件" buttonTitles:@[@"知道了"] completionHandler:^(NSInteger num) {
        
    }];
}
//- (void)choose18year {
//    if ([kUSerD integerForKey:@"userage"]==0) {
//        [self showAlertTitle:@"您是否年满18周岁？" message:@"本应用涉及到的互联网内容可能不宜未成年人观看,如果满18周岁,请打开应用通知功能。" buttonTitles:@[@"不满18岁",@"年满18周岁"] completionHandler:^(NSInteger num) {
//            if (num == 0) {
//                [UMessage setAlias:@"18down" type:kUMessageAliasTypeQQ response:^(id responseObject, NSError *error) {
//                    NSLog(@"18down ===%@==%@",responseObject,error);
//                }];
//            }
//            else
//            {
//                
//                [UMessage setAlias:@"18up" type:kUMessageAliasTypeSina response:^(id responseObject, NSError *error) {
//                    NSLog(@"18up ===%@==%@",responseObject,error);
//                }];
//            }
//            [kUSerD setInteger:1 forKey:@"userage"];
//            [kUSerD synchronize];
//        }];
//        
//    }
//}
- (BOOL)goToAppstoreComment {
    if (@available(iOS 10.3, *)) {
        if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
            [SKStoreReviewController requestReview];
            return YES;
        }
    } else {
        // Fallback on earlier versions
    }
//   NSInteger commentNum = [kUSerD integerForKey:@"appstorecomment"];
//
//    NSLog(@"appstore ====%@ ==%@",@(commentNum),@(commentNum+1));
//    if (commentNum>=10) {
//        if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
//            [SKStoreReviewController requestReview];
//            commentNum = -100;
//            [kUSerD setInteger:commentNum forKey:@"appstorecomment"];
//            [kUSerD synchronize];
//            return YES;
//        }else{
//        [self showAlertTitle:@"去App Store给个好评吧" message:@"给个好评，鼓励一下苦逼的程序员。" buttonTitles:@[NSLocalizedString(@"Cancel", nil),@"去评价"] completionHandler:^(NSInteger num) {
//            if (num == 1) {
//                [MobClick event:@"comment"];
//                NSString *appleID = @"1184757517";
//                NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
////                [kUSerD setInteger:-200 forKey:@"appstorecomment"];
//                [self performSelector:@selector(commented) withObject:nil afterDelay:10];
//            }
//            else {
//                [kUSerD setInteger:0 forKey:@"appstorecomment"];
//                [kUSerD synchronize];
//            }
//        }];
//         return YES;
//        }
//    }
//    [kUSerD setInteger:commentNum+1 forKey:@"appstorecomment"];
//    [kUSerD synchronize];
    return NO;
}

- (void)umengClick:(NSString *)eventId {
    [MobClick event:eventId];
}
- (void)umEvent:(NSString *)event label:(NSString *)label {
    [MobClick event:event label:label];
}
- (void)umengPageBegin:(NSString *)pageV {
    [MobClick beginLogPageView:pageV];
}
- (void)umengPageEnd:(NSString *)pageV {
   [MobClick endLogPageView:pageV];
}
- (BOOL)showAdview {
    return ![kUSerD boolForKey:KADBLOCK];
}
- (BOOL)savePravicyPassword:(NSString *)passW {
    if (passW) {
        NSData *sdata = [self encryptAes256WithStr:passW Key:@"xjy12"];
        [kUSerD setObject:sdata forKey:kPassWoed];
        BOOL sav = [kUSerD synchronize];
        return sav;
    }
    else {
        [kUSerD removeObjectForKey:kPassWoed];
        return YES;
    }
   
}
- (NSString *)getPravicyPassWord {
    NSData *aesD = [kUSerD objectForKey:kPassWoed];
    if (aesD) {
        NSData *strD = [self decryptAes256WithData:aesD Key:@"xjy12"];
        return [[NSString alloc]initWithData:strD encoding:NSUTF8StringEncoding];
   
    }
    else
    {
        return nil;
    }
    
}
/**
 显示广告
 */
- (BOOL)showInterstitialAdView {
    NSInteger adNum = [kUSerD integerForKey:kADnum];
    if ([XTOOLS showAdview]&& adNum>3) {
        self.interstitial = [[GADInterstitial alloc]
                             initWithAdUnitID:kAdUnitId];
        self.interstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        [self.interstitial loadRequest:request];
        if (self.interstitial.isReady) {
            [self.interstitial presentFromRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
        adNum ++;
        [kUSerD setInteger:adNum forKey:kADnum];
        [kUSerD synchronize];
        return YES;
    }
    else
    {
        if (adNum <= 3) {
            if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
                [SKStoreReviewController requestReview];
                
            }
            else
            {
                if (adNum ==0) {
                    [self showAlertTitle:@"去App Store给个好评吧" message:@"给个好评，鼓励一下程序员。" buttonTitles:@[@"取消",@"去评价"] completionHandler:^(NSInteger num) {
                        if (num == 1) {
                            [MobClick event:@"comment"];
                            NSString *appleID = kAppleId;
                            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
                            
                            if (@available(iOS 10.0, *)) {
                                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str] options:@{} completionHandler:^(BOOL success) {
                                    
                                }];
                            } else {
                                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
                            }
                            
                        }
                        else {
                            
                        }
                    }];
                }
            }
            if (adNum<0) {
                adNum = 0;
            }
            adNum ++;
            [kUSerD setInteger:adNum forKey:kADnum];
            [kUSerD synchronize];
        }
        
    }
    
    return NO;
}

- (UIView *)bannerAdViewRootViewController:(UIViewController *)rootViewController {
    if (!_bannerView) {
        _bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeSmartBannerPortrait];
        _bannerView.adUnitID = kBanderAdId;
        _bannerView.delegate = self;
        
    }
    if (rootViewController!=_bannerView.rootViewController) {
        _bannerView.rootViewController = rootViewController;
        [_bannerView loadRequest:[GADRequest request]];
    }
    return _bannerView;
}
- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(ios 11.0, *)) {
        // In iOS 11, we need to constrain the view to the safe area.
        [self positionBannerViewFullWidthAtBottomOfSafeArea:bannerView];
    } else {
        // In lower iOS versions, safe area is not available so we use
        // bottom layout guide and view edges.
        [self positionBannerViewFullWidthAtBottomOfView:bannerView];
    }
}

#pragma mark - view positioning

- (void)positionBannerViewFullWidthAtBottomOfSafeArea:(UIView *_Nonnull)bannerView NS_AVAILABLE_IOS(11.0) {
    // Position the banner. Stick it to the bottom of the Safe Area.
    // Make it constrained to the edges of the safe area.
    UILayoutGuide *guide = bannerView.superview.safeAreaLayoutGuide;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [guide.leftAnchor constraintEqualToAnchor:bannerView.leftAnchor],
                                              [guide.rightAnchor constraintEqualToAnchor:bannerView.rightAnchor],
                                              [guide.bottomAnchor constraintEqualToAnchor:bannerView.bottomAnchor]
                                              ]];
}

- (void)positionBannerViewFullWidthAtBottomOfView:(UIView *_Nonnull)bannerView {
    [bannerView.superview addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:bannerView.superview
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [bannerView.superview addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:bannerView.superview
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [bannerView.superview addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
}
/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
   
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

#pragma mark interstitialdelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
    if (self.interstitial.isReady&&!self.interstitial.hasBeenUsed) {
        [self.interstitial presentFromRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}


- (NSData *)encryptAes256WithStr:(NSString *)str Key:(NSString *)key   //加密
{
    NSData *enData = [str dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [enData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          enData.bytes, dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


- (NSData *)decryptAes256WithData:(NSData *)decryptData Key:(NSString *)key   //解密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = decryptData.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          decryptData.bytes, dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    free(buffer);
    return nil;
}
- (NSString *)timeStrFromDate:(NSDate *)date {
    if (date) {
        NSTimeInterval timeInter2 = [[NSDate date] timeIntervalSinceDate:date];
        if (timeInter2<60*60) {
            return @"刚刚";
        }
        else
            if (timeInter2<=24*60*60) {
                return [NSString stringWithFormat:@"%.f小时前",timeInter2/(60.0*60.0)];
            }
            else
            {
                if (![self.dateFormater.dateFormat isEqualToString: @"MM-dd HH:mm"]) {
                    [self.dateFormater setDateFormat:@"MM-dd HH:mm"];
                    
                }
                return [self.dateFormater stringFromDate:date];
            }
    }
    return @"";
    
}
- (NSString *)hmtimeStrFromDate:(NSDate *)date {
    if (![self.dateFormater.dateFormat isEqualToString: @"YYYY-MM-dd HH:mm:ss"]) {
        [self.dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    }
    NSString *timestr = [self.dateFormater stringFromDate:date];
    if (timestr.length>16) {
        return [timestr substringWithRange:NSMakeRange(11, 5)];
    }
    else
    {
        return @"--:--";
    }
    
}
- (BOOL)openURLStr:(NSString *)urlStr {
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlStr]]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            BOOL isOpen = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]];
            return isOpen;
        }
        return YES;
    }
    return NO;
}
- (BOOL)checkNetworkTitle:(NSString *)title State:(void (^)(BOOL is))complete {
    if ([self showAdview]) {
        @weakify(self);
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            if (status == AFNetworkReachabilityStatusNotReachable) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"打开网络连接" message:title preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(self);
                    [self umengClick:@"networkcancel"];
                    [alert dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }];
                UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"打开设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(self);
                    [self umengClick:@"networkopen"];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    } else {
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                [alert addAction:cancleAction];
                [alert addAction:sureAction];
                [self.topViewController presentViewController:alert animated:YES completion:^{
                    
                }];
                if (complete) {
                    complete(NO);
                }
            }
            else {
                if (complete) {
                    complete(YES);
                }
            }
            
            [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
        }];
    }
    else {
        if (complete) {
            complete(YES);
        }
    }
    return YES;
}
- (UIViewController *)topViewController {
    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) {
       return [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    }
    else {
       return [UIApplication sharedApplication].keyWindow.rootViewController;
    }
}
@end
