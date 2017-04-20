//
//  TakePictureView.m
//  定义相机获取需要部分
//
//  Created by zqy on 2017/4/18.
//  Copyright © 2017年 zqy. All rights reserved.
//

#import "TakePictureView.h"

#import <AVFoundation/AVFoundation.h>
// 为了导入系统相册
#import <AssetsLibrary/AssetsLibrary.h>

#import <Photos/Photos.h>
#import "UIImage+ChangeImage.h"

#import "AppDelegate.h"

@interface TakePictureView ()

{
    CGRect _imageRect;//用来截取的frame
}
@property (nonatomic, strong) AVCaptureSession *session;/**< 输入和输出设备之间的数据传递 */
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;/**< 输入设备 */
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;/**< 照片输出流 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;/**< 预览图片层 */
@property (nonatomic, strong) UIImage *image;

@end

@implementation TakePictureView
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initAVCaptureSession];
    [self initCameraOverlayView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initAVCaptureSession];
        [self initCameraOverlayView];
    }
    return self;
}

- (void)startRunning
{
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)stopRunning
{
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)initCameraOverlayView
{
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((width - width * 3 / 4) / 2, height * 0.3, width * 3 / 4 , width * 3 / 12)];
    imageV.clipsToBounds = YES;
    imageV.layer.borderColor = [UIColor whiteColor].CGColor;
    imageV.layer.borderWidth = 0.5;
    [self addSubview:imageV];
    
    
    /**
     * UIGraphicsBeginImageContextWithOptions(size,YES,[UIScreen mainScreen].scale);
     * 为了提高照片就用[UIScreen mainScreen].scale，所以_imageRect就要用相应的倍数
     */
    CGFloat height2 = height * [UIScreen mainScreen].scale;
    CGFloat width2 = width * [UIScreen mainScreen].scale;
    _imageRect = CGRectMake((width2 - width2 * 3 / 4) / 2, height2 * 0.3, width2 * 3 / 4 , width2 * 3 / 12);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageV.frame.origin.y - 20, width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"请把需要获取的部分放入相框内";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor greenColor];
    [self addSubview:label];
    
}

- (void)initAVCaptureSession {
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    
    // 设置闪光灯自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
//        NSLog(@"%@", error);
    }
    // 照片输出流
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    // 设置输出图片格式
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    // 初始化预览层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResize];
    self.previewLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.layer addSublayer:self.previewLayer];
    
}

// 获取设备方向

- (AVCaptureVideoOrientation)getOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        return AVCaptureVideoOrientationLandscapeRight;
    } else if ( deviceOrientation == UIDeviceOrientationLandscapeRight){
        return AVCaptureVideoOrientationLandscapeLeft;
    }
    return (AVCaptureVideoOrientation)deviceOrientation;
}

// 拍照
- (void)takeAPicture
{
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avOrientation = [self getOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avOrientation];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        //获取原图
        UIImage *image = [UIImage imageWithData:jpegData];

        //先把image放到屏幕的相对位置
        image = [UIImage image:image scaleToSize:self.bounds.size];
        
        //截取想要的区域
        image = [UIImage imageFromImage:image inRect:_imageRect];
        self.image = image;
        
//        self.getImage(image);
        // 写入相册
        if (self.shouldWriteToSavedPhotos) {
            [self writeToSavedPhotos];
        }
        
    }];
    
}

- (void)writeToSavedPhotos
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
//        NSLog(@"无权限访问相册");
        return;
    }
    
    // 首先判断权限
    if ([self haveAlbumAuthority]) {
        //写入相册
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image: didFinishSavingWithError:contextInfo:), nil);
        
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [self showIsSuccessOrFailureWithStr:@"保存相册失败"];
    } else {
        self.image = image;
        // 需要修改相册
        [self showIsSuccessOrFailureWithStr:@"保存相册成功"];
    }
}

- (BOOL)haveAlbumAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
    
}

- (void)setFrontOrBackFacingCamera:(BOOL)isUsingFrontFacingCamera {
    AVCaptureDevicePosition desiredPosition;
    if (isUsingFrontFacingCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    
}
- (void)showIsSuccessOrFailureWithStr:(NSString *)string{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor blackColor];
    label.text = string;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 8;
    label.layer.masksToBounds = YES;
    label.alpha = 0.0;
    label.center = app.window.center;
    label.numberOfLines = 0;
    [app.window addSubview:label];
    CGSize tipLabelSize = [label sizeThatFits:CGSizeMake(200, FLT_MAX)];
    label.bounds = CGRectMake(0, 0, 200, tipLabelSize.height + 20);
    //动画
    [UIView animateWithDuration:1.0 animations:^{
        label.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            label.alpha = 0.0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
