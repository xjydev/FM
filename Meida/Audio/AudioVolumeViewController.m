//
//  AudioVolumeViewController.m
//  Wenjian
//
//  Created by XiaoDev on 2020/1/17.
//  Copyright © 2020 XiaoDev. All rights reserved.
//

#import "AudioVolumeViewController.h"
#import "VideoAudioPlayer.h"
#import "XTools.h"
@interface AudioVolumeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *volumeTextField;

@end

@implementation AudioVolumeViewController
+ (instancetype)allocFromeStoryBoard {
     UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
       AudioVolumeViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"AudioVolumeViewController"];
       return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *vrlabel = [[ UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 30)];
    vrlabel.text = @"% ";
    vrlabel.textColor = [UIColor blackColor];
    self.volumeTextField.rightViewMode = UITextFieldViewModeAlways;
    self.volumeTextField.rightView = vrlabel;
   self.volumeTextField.text = [NSString stringWithFormat:@"%d",[VideoAudioPlayer defaultPlayer].audio.volume];
}
- (IBAction)volumeMinusButtonAction:(id)sender {
    [[VideoAudioPlayer defaultPlayer].audio volumeDown];
    self.volumeTextField.text = [NSString stringWithFormat:@"%d",[VideoAudioPlayer defaultPlayer].audio.volume];
    [kUSerD setInteger:[VideoAudioPlayer defaultPlayer].audio.volume forKey:kVolume];
    [kUSerD synchronize];
}
- (IBAction)volumeAddButtonAction:(id)sender {
    [[VideoAudioPlayer defaultPlayer].audio volumeUp];
    self.volumeTextField.text = [NSString stringWithFormat:@"%d",[VideoAudioPlayer defaultPlayer].audio.volume];
    [kUSerD setInteger:[VideoAudioPlayer defaultPlayer].audio.volume forKey:kVolume];
    [kUSerD synchronize];
}
- (IBAction)volumeTextFieldValueChange:(UITextField *)sender {
    [VideoAudioPlayer defaultPlayer].audio.volume = sender.text.intValue;
    [kUSerD setInteger:[VideoAudioPlayer defaultPlayer].audio.volume forKey:kVolume];
       [kUSerD synchronize];
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
