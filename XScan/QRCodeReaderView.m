

#import "QRCodeReaderView.h"
#import <AVFoundation/AVFoundation.h>
#import "XTools.h"
#import "QRCodelistCell.h"
//#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
//#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
//#define widthRate DeviceMaxWidth/320

#define contentTitleColorStr @"666666" //正文颜色较深
#define scanWidth 240.0/320.0*[UIScreen mainScreen].bounds.size.width
@interface QRCodeReaderView ()<AVCaptureMetadataOutputObjectsDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AVCaptureSession * session;
    
    NSTimer * _countTime;
    float   _height;
    BOOL    _scanUp;
    UITableView  *_listTableView;
    UIView       *_downView;
}
@property (nonatomic, strong) CAShapeLayer *overlay;
@property (nonatomic, strong) UIImageView  *scanLineImageView;
@end

@implementation QRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {

        [self instanceDevice];
  }
  
  return self;
}

- (void)instanceDevice
{
    //扫描区域
    UIImage *hbImage=[UIImage imageNamed:@"scanscanBg"];
    UIImageView * scanZomeBack=[[UIImageView alloc] init];
    scanZomeBack.backgroundColor = [UIColor clearColor];
    scanZomeBack.image = hbImage;
    //添加一个背景图片
    CGRect mImagerect = CGRectMake((CGRectGetWidth(self.frame) - scanWidth)/2, (CGRectGetHeight(self.frame) - scanWidth)/2, scanWidth, scanWidth);
    [scanZomeBack setFrame:mImagerect];
    CGRect scanCrop=[self getScanCrop:mImagerect readerViewBounds:self.frame];
    [self addSubview:scanZomeBack];
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    output.rectOfInterest = scanCrop;
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
      [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if (input) {
        [session addInput:input];
    }
    if (output) {
        [session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {//二维码
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    
    [self setOverlayPickerView:self];
    
    //开始捕获
    [session startRunning];
}

- (void)setOverlayPickerView:(QRCodeReaderView *)reader
{
    
    CGFloat wid = (CGRectGetWidth(self.frame) - scanWidth)/2;
    CGFloat heih = (CGRectGetHeight(self.frame) - scanWidth)/2;
    UIColor * backColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), heih)];
    upView.backgroundColor = backColor;
    [reader addSubview:upView];
    //用于说明的label
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(0,64+ (heih-64-40)/2, CGRectGetWidth(self.frame), 40)];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.textColor=kDarkCOLOR(0xffffff);
    labIntroudction.text=@"扫描二维码/条形码";
    labIntroudction.backgroundColor = [UIColor clearColor];
    [upView addSubview:labIntroudction];
    
    //左侧的view
    UIView * cLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, heih, wid, scanWidth)];
    cLeftView.backgroundColor = backColor;
    [reader addSubview:cLeftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-wid, heih, wid,scanWidth)];
    rightView.backgroundColor = backColor;
    [reader addSubview:rightView];
    
    //底部view
    _downView = [[UIView alloc] initWithFrame:CGRectMake(0, heih+scanWidth, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - heih-scanWidth)];
    _downView.backgroundColor = backColor;
    [reader addSubview:_downView];
    
    //开关灯button
    UIButton * turnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    turnBtn.backgroundColor = [UIColor clearColor];
     turnBtn.frame=CGRectMake((CGRectGetWidth(self.frame)-scanWidth)/2,(heih - 80)/2, 80, 80);
    [turnBtn setImage:[UIImage imageNamed:@"scan_lightSelect"] forState:UIControlStateNormal];
    [turnBtn setImage:[UIImage imageNamed:@"scan_lightNormal"] forState:UIControlStateSelected];
    [turnBtn setTitle:@"照明已关闭" forState:UIControlStateNormal];
    [turnBtn setTitle:@"照明已开启" forState:UIControlStateSelected];
   turnBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [turnBtn setImageEdgeInsets:UIEdgeInsetsMake(-turnBtn.titleLabel.intrinsicContentSize.height, 0, 0, -turnBtn.titleLabel.intrinsicContentSize.width)];
    [turnBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -turnBtn.imageView.frame.size.width, -turnBtn.imageView.frame.size.height, 0)];
    [turnBtn addTarget:self action:@selector(turnBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [_downView addSubview:turnBtn];
    //连续扫描的button
    self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.circleButton.backgroundColor = [UIColor clearColor];
     self.circleButton.frame=CGRectMake(CGRectGetWidth(self.frame)/2 +scanWidth/2-80,(heih - 80)/2, 80, 80);
    self.circleButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.circleButton setImage:[UIImage imageNamed:@"scan_offCircle"] forState:UIControlStateNormal];
    [self.circleButton setImage:[UIImage imageNamed:@"scan_circle"] forState:UIControlStateSelected];
    [self.circleButton setTitle:@"连续已关闭" forState:UIControlStateNormal];
    [self.circleButton setTitle:@"连续扫描中" forState:UIControlStateSelected];
    [self.circleButton setImageEdgeInsets:UIEdgeInsetsMake(-self.circleButton.titleLabel.intrinsicContentSize.height, 0, 0, -self.circleButton.titleLabel.intrinsicContentSize.width)];
    [self.circleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.circleButton.imageView.frame.size.width, -self.circleButton.imageView.frame.size.height, 0)];
   
    [self.circleButton addTarget:self action:@selector(circleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_downView addSubview:self.circleButton];
    
    
}
#pragma mark 连续扫描
- (void)circleButtonAction:(UIButton *)button {
    button.selected = !button.selected;
    self.isCircle = button.selected;
    if (self.isCircle) {
        if (!_listTableView) {
            _listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), _downView.frame.size.height-40) style:UITableViewStylePlain];
            _listTableView.backgroundColor = [UIColor clearColor];
            _listTableView.delegate = self;
            _listTableView.dataSource = self;
            _listTableView.rowHeight = 30;
            _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_listTableView registerClass:[QRCodelistCell class]forCellReuseIdentifier:@"scanlistcell"];
            [_downView addSubview:_listTableView];
            [_downView sendSubviewToBack:_listTableView];
            UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 40)];
            footLabel.textAlignment = NSTextAlignmentCenter;
            footLabel.text = @"扫描后，点击进入列表";
            footLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.5];
            footLabel.font = [UIFont systemFontOfSize:15];
            _listTableView.tableFooterView = footLabel;
        }
        if (!_listArray) {
            _listArray = [NSMutableArray arrayWithCapacity:0];
        }
        _listTableView.hidden = NO;
    }
    else
    {
        if (_listTableView) {
            _listTableView.hidden = YES;
        }
    }
}
- (void)turnBtnEvent:(UIButton *)button_
{
    button_.selected = !button_.selected;
    if (button_.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}

- (void)turnTorchOn:(bool)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

- (void)start
{
    [session startRunning];
    if (!_countTime) {
       _countTime = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(moveScanLine) userInfo:nil repeats:YES];
    }
   
}

- (void)stop
{
    [session stopRunning];
    if (_countTime) {
        [_countTime invalidate];
        _countTime = nil;
    }
}
- (void)moveScanLine {
    if (!_readLineView) {
        _readLineView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - scanWidth)/2, (CGRectGetHeight(self.frame) - scanWidth)/2+3, scanWidth, 5)];
        [_readLineView setImage:[UIImage imageNamed:@"scanLine"]];
        [self addSubview:_readLineView];
    }
    if (_scanUp) {
      [UIView animateWithDuration:1.15 animations:^{
          self->_readLineView.center = CGPointMake(CGRectGetWidth(self.frame)/2, (CGRectGetHeight(self.frame)-scanWidth)/2+3);
      } completion:^(BOOL finished) {
          self->_scanUp = NO;
      }];
    }
    else
    {
        [UIView animateWithDuration:1.15 animations:^{
            self->_readLineView.center = CGPointMake(CGRectGetWidth(self.frame)/2, (CGRectGetHeight(self.frame)+scanWidth)/2-3);
        } completion:^(BOOL finished) {
            self->_scanUp = YES;
        }];
    }
}
#pragma mark - 扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects && metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
//        if (![kUSerD boolForKey:kSound]) {
//            SystemSoundID soundID =0;
//            NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
//            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//            AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteback, NULL);
//            AudioServicesPlaySystemSound(soundID);
//        }
        //输出扫描字符串
        if (self.isCircle) {
            [_listArray insertObject:metadataObject.stringValue atIndex:0 ];
            [self stop];
            [self performSelector:@selector(start) withObject:nil afterDelay:0.3];
            [_listTableView reloadData];
        }
        else
        {
            if (_delegate && [_delegate respondsToSelector:@selector(readerScanResult:)]) {
                [_delegate readerScanResult:metadataObject.stringValue];
            }
        }
        
    }
}
void soundCompleteback(SystemSoundID soundID,void * clientData)
{
    NSLog(@"播放完成...");
    
    AudioServicesRemoveSystemSoundCompletion(soundID);
}
#pragma mark - 颜色
//获取颜色
- (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QRCodelistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scanlistcell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentLabel.text =_listArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(readerCircleScanResults:)]) {
        [_delegate readerCircleScanResults:_listArray];
    }
}
@end
