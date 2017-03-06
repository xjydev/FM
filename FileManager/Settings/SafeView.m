//
//  safeView.m
//  FileManager
//
//  Created by xiaodev on Feb/25/17.
//  Copyright © 2017 xiaodev. All rights reserved.
//

#import "safeView.h"
#import "AppDelegate.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "XTools.h"
#import "CLLockItemView.h"
#import "CoreLockConst.h"

#define ItemWidth 60
#define PreTag 300
static SafeView *_safeView = nil;
@interface SafeView()
{
    UILabel    *_titleLabel;
    NSString   *_firstPassWord;
     NSString   *_oldPassWord;
    BOOL        _isWrong;
   
    

}
@property (nonatomic, strong)NSMutableArray *touchItemArray;
@property (nonatomic, strong)NSMutableString *passWordStr;
@property (nonatomic, strong)LAContext    *touchContext;
@end
@implementation SafeView
+ (instancetype)defaultSafeView {
    if (!_safeView) {
        _safeView = [[SafeView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    }
    return _safeView;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)touchIDButtonAction:(UIButton *)button {
    if (self.supportTouchID) {
       [self touchIDWithMessage:@"验证指纹密码进入应用"];
    }
    else
    {
        [XTOOLS showMessage:@"此设备不支持指纹"];
    }
   
}
- (void)changeButtonAction:(UIButton *)button {
    
}
- (void)cancleButtonAction:(UIButton *)button {
    [self removeFromSuperview];
    _safeView = nil;
//    self.throughPassWord(3);
}
- (NSMutableString *)passWordStr {
    if (!_passWordStr) {
        _passWordStr = [NSMutableString stringWithCapacity:10];
    }
    return _passWordStr;
}
- (NSMutableArray*)touchItemArray {
    if (!_touchItemArray) {
        _touchItemArray = [NSMutableArray arrayWithCapacity:9];
    }
    return _touchItemArray;
}
- (LAContext *)touchContext {
    if (!_touchContext) {
        _touchContext = [[LAContext alloc] init];
    }
    return _touchContext;
}
- (BOOL)supportTouchID {
    NSError *error;
    BOOL support = [self.touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication
                                                  error:&error];
    switch (error.code) {
        case LAErrorTouchIDNotEnrolled://指纹识别在此设备无法使用
        {
            
        }
            break;
        case LAErrorPasscodeNotSet://因为未在此设备设置密码
        {
            
        }
            break;
        default:
            //指纹识别在此设备无法使用
            break;
    }
    return support;
    
}
//设置底部的忘记密码和指纹按钮
- (void)setBottomButton {
    if (self.type == PassWordTypeDefault) {
        UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        changeButton.frame = CGRectMake(kScreen_Width/11, kScreen_Height-90, 80, 70);
        [changeButton setImage:[UIImage imageNamed:@"forgetPassWord"] forState:UIControlStateNormal];
        [changeButton setTitleColor:SelectedColor forState:UIControlStateNormal];
        [changeButton setTitle:@"忘记密码" forState:UIControlStateNormal];
        changeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [changeButton setImageEdgeInsets:UIEdgeInsetsMake(2, 18, 25, 0)];
        [changeButton setTitleEdgeInsets:UIEdgeInsetsMake(35, -30, 0, 0)];
        [changeButton addTarget:self action:@selector(changeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changeButton];
        
        UIButton *touchIDButton = [UIButton buttonWithType:UIButtonTypeCustom];
        touchIDButton.frame = CGRectMake(kScreen_Width/11*10-80, kScreen_Height-90, 80, 70);
        [touchIDButton setImage:[UIImage imageNamed:@"touchId"] forState:UIControlStateNormal];
        [touchIDButton setTitleColor:SelectedColor forState:UIControlStateNormal];
        [touchIDButton setTitle:@"指纹密码" forState:UIControlStateNormal];
        touchIDButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [touchIDButton setImageEdgeInsets:UIEdgeInsetsMake(2, 18, 25, 0)];
        [touchIDButton setTitleEdgeInsets:UIEdgeInsetsMake(35, -30, 0, 0)];
        [touchIDButton addTarget:self action:@selector(touchIDButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:touchIDButton];
    }
    else
    {
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame = CGRectMake((kScreen_Width-80)/2, kScreen_Height-90, 80, 70);
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton setTitleColor:SelectedColor forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancleButton];
    }
}
- (void)showSafeViewHandle:(ThroughPassWord)handle {
    [self setBottomButton];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
    }
   
    
    self.throughPassWord = handle;
    if (self.type == PassWordTypeSet) {
      [self gestureWithTitle:@"设置手势密码"];
    }
    else
        if (self.type == PassWordTypeReset) {
            _oldPassWord = [kUSerD objectForKey:KPassWord];
            [self gestureWithTitle:@"重置手势密码,先验证旧密码"];
            
        }
    else
    {
        [self gestureWithTitle:@"验证手势密码"];
        if ([kUSerD boolForKey:kTouchPassWord]) {
            [self touchIDWithMessage:@"验证指纹密码进入应用"];
        }
    }
    
}
- (void)setHeaderTitle:(NSString *)title wrong:(BOOL)isWrong {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kScreen_Height/2-(kScreen_Width/11*4)-100, kScreen_Width, 60)];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
    }
    if (isWrong) {
       _titleLabel.textColor = [UIColor redColor];
    }
    else
    {
       _titleLabel.textColor = [UIColor blackColor];
    }
    _titleLabel.text = title;
}

#pragma mark -- 指纹密码
- (void)touchIDWithMessage:(NSString *)message {
    [self setHeaderTitle:@"验证指纹解锁" wrong:NO];
    
    NSError *error = nil;
    NSString *detail;
    if (!message.length) {
        detail = @"验证指纹密码";
    }else {
        detail = message;
    }
    
    // 判断设备是否支持指纹识别

    if (self.supportTouchID) {
        [self.touchContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:detail reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                // 验证成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self removeFromSuperview];
                    _safeView = nil;
                    self.throughPassWord(1);
                });

                
            }else {
                
                switch (error.code) {
                    case LAErrorSystemCancel://程序切换到其他APP
                    {
                        NSLog(@"程序切换到其他APP");
                    }
                        break;
                    case LAErrorUserCancel://用户取消
                    {
                       NSLog(@"用户取消");
                        [self setHeaderTitle:@"验证手势密码解锁" wrong:NO];
                    }
                        break;
                    case LAErrorUserFallback://用户选择输入密码
                    {
                       NSLog(@"用户选择输入密码");
                        [self setHeaderTitle:@"验证手势密码解锁" wrong:NO];
                    }
                        break;
                    case LAErrorTouchIDLockout://这种情况是由于尝试了太多次数的指纹解锁，除非使用系统密码进行解锁
                    {
                       NSLog(@"尝试了太多次数的指纹解锁，除非使用系统密码进行解锁");
                        [self setHeaderTitle:@"验证手势密码解锁" wrong:NO];
                    }
                    case LAErrorAppCancel://程序验证过程中被其他程序挂起
                    {
                       NSLog(@"中被其他程序挂起");
                    }
                    case LAErrorInvalidContext://识别上下文被销毁
                    {
                       NSLog(@"识别上下文被销毁");
                    }
                    default://未知原因，验证失败
                        
                        break;
                }
                
            }
        }];
    }else {
        // 不支持指纹识别
         [self setHeaderTitle:@"验证手势密码解锁" wrong:NO];
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled://指纹识别在此设备无法使用
            {
                
            }
                break;
            case LAErrorPasscodeNotSet://因为未在此设备设置密码
            {
                
            }
                break;
            default:
                //指纹识别在此设备无法使用
                break;
        }
    }
    
}
#pragma mark -- 手势解锁
- (void)gestureWithTitle:(NSString *)title {
    [self setHeaderTitle:title wrong:NO];
    for (NSUInteger i=0; i<9; i++) {
        
        CLLockItemView *itemView = [[CLLockItemView alloc] initWithFrame:CGRectMake(kScreen_Width/22*3 +i%3*(kScreen_Width/11*3), kScreen_Height/2-(kScreen_Width/11*4)+i/3*(kScreen_Width/11*3), kScreen_Width/11*2, kScreen_Width/11*2)];
        itemView.tag = PreTag + i;
        [self addSubview:itemView];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self gestureBegan];
    [self lockHandle:touches];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     [self lockHandle:touches];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self gestureEnd];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   [self gestureEnd];
}
/*
 *  解锁处理
 */
-(void)lockHandle:(NSSet *)touches{
    
    //取出触摸点
    UITouch *touch = [touches anyObject];
    
    CGPoint loc = [touch locationInView:self];
    
    CLLockItemView *itemView = [self itemViewWithTouchLocation:loc];
    
    //如果为空，返回
    if(itemView ==nil) return;
    
    //如果已经存在，返回
    if([self.touchItemArray containsObject:itemView]) return;
    
    //添加
    [self.touchItemArray addObject:itemView];
    
    //记录密码
    [self.passWordStr appendFormat:@"%@",@(itemView.tag-PreTag)];
    
    
    //计算方向：每添加一次itemView就计算一次
    [self calDirect];
    
    //item处理
    [self itemHandel:itemView];
}
/*
 *  计算方向：每添加一次itemView就计算一次
 */
-(void)calDirect{
    
    NSUInteger count = self.touchItemArray.count;
    
    if(self.touchItemArray==nil || count<=1) return;
    
    //取出最后一个对象
    CLLockItemView *last_1_ItemView = self.touchItemArray.lastObject;
    
    //倒数第二个
    CLLockItemView *last_2_ItemView =self.touchItemArray[count -2];
    
    //计算倒数第二个的位置
    CGFloat last_1_x = last_1_ItemView.frame.origin.x;
    CGFloat last_1_y = last_1_ItemView.frame.origin.y;
    CGFloat last_2_x = last_2_ItemView.frame.origin.x;
    CGFloat last_2_y = last_2_ItemView.frame.origin.y;
    
    //倒数第一个itemView相对倒数第二个itemView来说
    //正上
    if(last_2_x == last_1_x && last_2_y > last_1_y) {
        last_2_ItemView.direct = LockItemViewDirecTop;
    }
    
    //正左
    if(last_2_y == last_1_y && last_2_x > last_1_x) {
        last_2_ItemView.direct = LockItemViewDirecLeft;
    }
    
    //正下
    if(last_2_x == last_1_x && last_2_y < last_1_y) {
        last_2_ItemView.direct = LockItemViewDirecBottom;
    }
    
    //正右
    if(last_2_y == last_1_y && last_2_x < last_1_x) {
        last_2_ItemView.direct = LockItemViewDirecRight;
    }
    
    //左上
    if(last_2_x > last_1_x && last_2_y > last_1_y) {
        last_2_ItemView.direct = LockItemViewDirecLeftTop;
    }
    
    //右上
    if(last_2_x < last_1_x && last_2_y > last_1_y) {
        last_2_ItemView.direct = LockItemViewDirecRightTop;
    }
    
    //左下
    if(last_2_x > last_1_x && last_2_y < last_1_y) {
        last_2_ItemView.direct = LockItemViewDirecLeftBottom;
    }
    
    //右下
    if(last_2_x < last_1_x && last_2_y < last_1_y) {
        last_2_ItemView.direct = LockItemViewDiretRightBottom;
    }
    
}
-(CLLockItemView *)itemViewWithTouchLocation:(CGPoint)loc{
    for (int i =0; i<9; i++) {
        CLLockItemView *itemView = [self viewWithTag:i+PreTag];
        if(CGRectContainsPoint(itemView.frame, loc)){
            return itemView;
        }
    }
    return nil;
}
/*
 *  item处理
 */
-(void)itemHandel:(CLLockItemView *)itemView{
    
    //选中
    itemView.selected = YES;
    
    //绘制
    [self setNeedsDisplay];
}
- (void)gestureBegan {
    _isWrong = NO;
    if (self.touchItemArray.count>0) {
        for (CLLockItemView *itemView in self.touchItemArray) {
            
            itemView.selected = NO;
            itemView.isWrong = NO;
            //清空方向
            itemView.direct = 0;
        }
        
        //清空数组所有对象
        [self.touchItemArray removeAllObjects];
        
        //再绘制
        [self setNeedsDisplay];
        
        //清空密码
        self.passWordStr = nil;
    }
}
#pragma mark -- 手势结束，验证密码
-(void)gestureEnd{
    
    //设置密码检查
    if(self.passWordStr.length != 0){
        
        if (self.type == PassWordTypeReset) {//重置密码
            if (_firstPassWord) {//是否有第一次的密码，来判断是第一次还是第二次输入的密码
                if ([self.passWordStr isEqualToString:_firstPassWord]) {
                    [kUSerD setObject:_firstPassWord forKey:KPassWord];
                    [kUSerD removeObjectForKey:KPassWord];
                    [kUSerD synchronize];
                    [self removeFromSuperview];
                    _safeView = nil;
                    self.throughPassWord(5);//重置密码成功
                }
                else {
                    [self setHeaderTitle:@"手势密码不一致" wrong:YES];
                    [self wrongGesturePassWord];
                }
            }
            else
            {
                
                if (_oldPassWord.length>0) {
                    if ([self.passWordStr isEqualToString:_oldPassWord]) {
                        _oldPassWord = nil;
                        [self setHeaderTitle:@"请输入新手势密码" wrong:NO];
                        [self gestureBegan];
                    }
                    else
                    {
                        [self setHeaderTitle:@"旧手势密码验证失败" wrong:YES];
                        [self wrongGesturePassWord];
                    }
                }
                else
                {
                    _firstPassWord = self.passWordStr;
                    [self setHeaderTitle:@"请再次输入确认密码" wrong:NO];
                    [self gestureBegan];
                }
            }
        }
        else
            if (self.type == PassWordTypeSet) {
                if (_firstPassWord) {//是否有第一次的密码，来判断是第一次还是第二次输入的密码
                    if ([self.passWordStr isEqualToString:_firstPassWord]) {
                        [kUSerD setObject:_firstPassWord forKey:KPassWord];
                        [kUSerD synchronize];
                        [self removeFromSuperview];
                        _safeView = nil;
                        self.throughPassWord(4);//重置密码成功
                    }
                    else {
                        [self setHeaderTitle:@"手势密码不一致" wrong:YES];
                        [self wrongGesturePassWord];
                    }
                }
                else
                {
                    
                    _firstPassWord = self.passWordStr;
                    [self setHeaderTitle:@"请再次输入确认密码" wrong:NO];
                    [self gestureBegan];
                    
                }
            }
            else
            {
                NSString *passwords =[kUSerD objectForKey:KPassWord];
                if ([self.passWordStr isEqualToString:passwords]) {
                    [self removeFromSuperview];
                    _safeView = nil;
                    self.throughPassWord(2);
                }
                else
                {
                    
                    [self setHeaderTitle:@"密码错误" wrong:YES];
                    [self wrongGesturePassWord];
                    
                }
            }
        
    }
    
    
    
}
- (void)wrongGesturePassWord {
    _isWrong = YES;
    for (CLLockItemView *itemView in self.touchItemArray) {
        //错误手势密码
        itemView.isWrong = YES;
        
    }
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //数组为空直接返回
    if(self.touchItemArray == nil || self.touchItemArray.count == 0) return;
    
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //添加路径
    CGContextAddRect(ctx, rect);
    
    //添加圆形路径
    //遍历所有的itemView
    [self.touchItemArray enumerateObjectsUsingBlock:^(CLLockItemView *itemView, NSUInteger idx, BOOL *stop) {
        
        CGContextAddEllipseInRect(ctx, itemView.frame);
    }];
    
    //剪裁
    CGContextEOClip(ctx);
    
    //新建路径：管理线条
    CGMutablePathRef pathM = CGPathCreateMutable();
    
    //设置上下文属性
    //1.设置线条颜色
    if (_isWrong) {
       [[UIColor redColor] set];
    }
    else
    {
       [SelectedColor set];
    }
    
    
    //线条转角样式
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    //设置线宽
    CGContextSetLineWidth(ctx, 1.0f);
    
    //遍历所有的itemView
    [self.touchItemArray enumerateObjectsUsingBlock:^(CLLockItemView *itemView, NSUInteger idx, BOOL *stop) {
        
        CGPoint directPoint = itemView.center;
        
        if(idx == 0){//第一个
            
            //添加起点
            CGPathMoveToPoint(pathM, NULL, directPoint.x, directPoint.y);
            
        }else{//其他
            
            //添加路径线条
            CGPathAddLineToPoint(pathM, NULL, directPoint.x, directPoint.y);
        }
    }];
    
    //将路径添加到上下文
    CGContextAddPath(ctx, pathM);
    
    //渲染路径
    CGContextStrokePath(ctx);
    
    //释放路径
    CGPathRelease(pathM);
}


@end
