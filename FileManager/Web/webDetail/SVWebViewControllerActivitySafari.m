//
//  SVWebViewControllerActivitySafari.m
//
//  Created by Sam Vermette on 11 Nov, 2013.
//  Copyright 2013 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController


#import "SVWebViewControllerActivitySafari.h"

@implementation SVWebViewControllerActivitySafari

- (NSString *)activityTitle {
//	return NSLocalizedStringFromTable(@"Open in Safari", @"SVWebViewController", nil);
    return @"Safari打开";
}
- (UIImage *)activityImage {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [UIImage imageNamed:@"Safari_iPad"];
    else
        return [UIImage imageNamed:@"Safari"];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
			return YES;
		}
	}
	return NO;
}

- (void)performActivity {
	BOOL completed = [[UIApplication sharedApplication] openURL:self.URLToOpen];
	[self activityDidFinish:completed];
}

@end
