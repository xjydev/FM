//
//  QRCreateViewController.m
//  FileManager
//
//  Created by xiaodev on Feb/7/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "QRCreateViewController.h"
#import "UIColor+Hex.h"
#import "XTools.h"
#import "MoveFilesView.h"
@interface QRCreateViewController ()<UITextFieldDelegate,UITextViewDelegate>
{
    __weak IBOutlet UIImageView *_imageView;
    __weak IBOutlet UITextView *_contextTextView;
    __weak IBOutlet UITextField *_widthField;
    __weak IBOutlet UIButton *_selectedButton;
    
    __weak IBOutlet UIButton *_createButton;
    UIImage                  *_qRimage;
    UIImage                  *_centerImage;
    UILongPressGestureRecognizer *_pressGesture;
}
@end

@implementation QRCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码生成";
    self.automaticallyAdjustsScrollViewInsets = NO;
    _widthField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
    _widthField.leftViewMode = UITextFieldViewModeAlways;
    _createButton.layer.borderColor = kMainCOLOR.CGColor;
    _createButton.layer.borderWidth = 1.0;
    _createButton.layer.cornerRadius = 20;
    _createButton.layer.masksToBounds = YES;
    
    _selectedButton.layer.borderColor = kMainCOLOR.CGColor;
    _selectedButton.layer.borderWidth = 1.0;
    _selectedButton.layer.cornerRadius = 15;
    _selectedButton.layer.masksToBounds = YES;
    
    _contextTextView.delegate = self;
    _widthField.delegate = self;
    [XTOOLS showAlertTitle:@"更好用的应用" message:@"更专业，功能更强悍,的二维码生成，扫描工具" buttonTitles:@[NSLocalizedString(@"Cancel", nil),@"去看看"] completionHandler:^(NSInteger num) {
        if (num == 1) {
            NSString *appleID = @"1203565616";
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } else {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
            }
            [XTOOLS umengClick:@"gotoQrcreate"];
//            gotoQrcreate
        }
    }];
//    [self createCoreImage:@"1234"];
}
- (IBAction)selectedCenterImageButtonAction:(id)sender {
    NSArray *array = [kFileM subpathsOfDirectoryAtPath:KDocumentP error:nil];
    NSMutableArray *filesArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString *name in array) {
        if ([XTOOLS fileFormatWithPath:name] == FileTypeImage  ) {
            [filesArray addObject:name];
        }
    }
    MoveFilesView *fileView = [[MoveFilesView alloc]initWithFrame:self.view.bounds];
    fileView.isShow = YES;
    [fileView showWithFolderArray:filesArray withTitle:@"选择图片" backBlock:^(NSString *movePath,NSInteger selectedIndex) {
        self->_centerImage = [UIImage imageWithContentsOfFile:movePath];
    }];

}
- (IBAction)createQRImageButtonAction:(UIButton *)sender {
    if (_contextTextView.text.length>0&&_contextTextView.textColor==[UIColor blackColor]) {
         [sender setTitle:@"重新生成二维码" forState:UIControlStateNormal];
        [self createCoreImage:_contextTextView.text];
    }
    else
    {
        [XTOOLS showMessage:@"请输入内容"];
    }
   
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_widthField resignFirstResponder];
    [_contextTextView resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor != [UIColor blackColor]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
#pragma mark - 生成二维码
- (void)createCoreImage:(NSString *)codeStr{
    
    //1.生成coreImage框架中的滤镜来生产二维码
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    [filter setValue:[codeStr dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    //4.获取生成的图片
    CIImage *ciImg=filter.outputImage;
    //放大ciImg,默认生产的图片很小
    
    //5.设置二维码的前景色和背景颜色
    CIFilter *colorFilter=[CIFilter filterWithName:@"CIFalseColor"];
    //5.1设置默认值
    [colorFilter setDefaults];
    [colorFilter setValue:ciImg forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithRed:0 green:0 blue:0] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithRed:1 green:1 blue:1] forKey:@"inputColor1"];
    //5.3获取生存的图片
    ciImg=colorFilter.outputImage;
    
    CGAffineTransform scale=CGAffineTransformMakeScale(10, 10);
    ciImg=[ciImg imageByApplyingTransform:scale];
    
    //6.在中心增加一张图片
    UIImage *img=[UIImage imageWithCIImage:ciImg];
    //7.生存图片
    CGFloat width = [_widthField.text floatValue];
    CGFloat height = [_widthField.text floatValue];
    //7.1开启图形上下文
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    //7.2将二维码的图片画入
    //BSXPCMessage received error for message: Connection interrupted   why??
    //    [img drawInRect:CGRectMake(10, 10, img.size.width-20, img.size.height-20)];
    [img drawInRect:CGRectMake(0, 0,width , height)];
    //7.3在中心划入其他图片
    if (_centerImage) {
        CGFloat centerW=width/3;
        CGFloat centerH=height/3;
        CGFloat centerX=(width-centerW)*0.5;
        CGFloat centerY=(height -centerH)*0.5;
        
        [_centerImage drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
 
    }
    
    //7.4获取绘制好的图片
    _qRimage=UIGraphicsGetImageFromCurrentImageContext();
    
    //7.5关闭图像上下文
    UIGraphicsEndImageContext();
    //设置图片
    _imageView.image = _qRimage;
    _imageView.userInteractionEnabled = YES;
    //长按手势识别器
    if (!_pressGesture) {
        _pressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        [_imageView addGestureRecognizer:_pressGesture];
    }
    
    
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)uilpgr
{

    if (uilpgr.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //保存到相册
        UIImageWriteToSavedPhotosAlbum(self->_qRimage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"保存到主目录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //保存文件夹
        NSString *imagePath = [NSString stringWithFormat:@"%@/二维码%@.png",KDocumentP,[self->_contextTextView.text substringToIndex:MIN(5,self->_contextTextView.text.length)]];
        if ([UIImagePNGRepresentation(self->_qRimage) writeToFile:imagePath atomically:YES]) {
            [XTOOLS showMessage:@"保存成功"];
        }
        else
        {
            [XTOOLS showMessage:@"保存失败"];
        }
        
    }];

    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    if (IsPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(kScreen_Width/2,kScreen_Height/2,1.0,1.0);
    }
   
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error){
        [XTOOLS showMessage:@"保存成功"];
    }else{
        [XTOOLS showMessage:@"保存失败"];
       
    }  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XTOOLS umengPageBegin:NSStringFromClass(self.class)];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [XTOOLS umengPageEnd:NSStringFromClass(self.class)];
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
