

#import <UIKit/UIKit.h>

/**
 * Simple view to display an overlay (a square) over the camera view.
 * @since 2.0.0
 */

@protocol QRCodeReaderViewDelegate <NSObject>
- (void)readerScanResult:(NSString *)result;
@end

@interface QRCodeReaderView : UIView

@property (nonatomic, weak) id<QRCodeReaderViewDelegate> delegate;
@property (nonatomic,copy)UIImageView * readLineView;

//开启关闭扫描
- (void)start;
- (void)stop;


@end
