//
//  AboutAppViewController.m
//  FileManager
//
//  Created by xiaodev on Nov/30/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "AboutAppViewController.h"
#import "XTools.h"
@interface AboutAppViewController ()
{
    __weak IBOutlet UITextView *_mainTextView;
}
@end

@implementation AboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDarkCOLOR(0xffffff);
//rmvb,asf,avi,divx,flv,m2ts,m4v,mkv,mov,mp4,ps,ts,vob,wmv,dts,swf,dv,gxf,m1v,m2v,mpeg,mpeg1,mpeg2,mpeg4,mpg,mts,mxf,ogm,a52,m4a,mka,mod,
//    mp3,ogg,wav,ac3,eac3,ape,cda,au,midi,mac,aac,f4v,wma,flac,cue,amr,vorbis,m4p,mp1,mp2,
//    gif,jpeg,bmp,tif,jpg,pcd,qti,qtf,tiff,png,
//    pdf,doc,text,txt,htm,dot,dotx,rtf,ppt,pots,pot,pps,numbers,pages,keynote,
    _mainTextView.backgroundColor = [UIColor whiteColor];
    _mainTextView.editable = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
