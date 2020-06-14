//
//  HomeFeedModel.h
//  FileManager
//
//  Created by 阿凡树 on 2017/4/7.
//  Copyright © 2017年 xiaodev. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol HomeFeedModel @end
@interface HomeFeedAPI : JSONModel
@property (nonatomic, readwrite, retain) NSArray<HomeFeedModel> *data;
@end
@interface HomeFeedModel : JSONModel
@property (nonatomic, readwrite, strong) NSString *title;
@property (nonatomic, readwrite, assign) NSInteger size;
@property (nonatomic, readwrite, strong) NSString *videourl;
@property (nonatomic, readwrite, strong) NSString *videopic;
@property (nonatomic, readwrite, assign) NSInteger height;
@property (nonatomic, readwrite, strong) NSString *author;
@property (nonatomic, readwrite, assign) NSInteger width;
@property (nonatomic, readwrite, assign) NSInteger count;
@end
