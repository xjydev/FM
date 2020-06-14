

#import <UIKit/UIKit.h>

/**
 * Simple view to display an overlay (a square) over the camera view.
 * @since 2.0.0
 */

@protocol QRCodeReaderViewDelegate <NSObject>
- (void)readerScanResult:(NSString *)result;
- (void)readerCircleScanResults:(NSArray *)results;
@end

@interface QRCodeReaderView : UIView

@property (nonatomic, weak) id<QRCodeReaderViewDelegate> delegate;
@property (nonatomic,strong)UIImageView * readLineView;
@property (nonatomic, strong) UIButton  *circleButton;
@property (nonatomic, assign)BOOL    isCircle;//是否连续扫描；
@property (nonatomic, strong)NSMutableArray  *listArray;
//开启关闭扫描
- (void)start;
- (void)stop;


@end
