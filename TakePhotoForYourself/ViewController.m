//
//  ViewController.m
//  TakePhotoForYourself
//
//  Created by zqy on 2017/4/19.
//  Copyright © 2017年 zqy. All rights reserved.
//

#import "ViewController.h"
#import "TakePictureView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (strong, nonatomic) TakePictureView *cameraView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cameraView = [[TakePictureView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    // 是否在按照成功直接写入本地
    self.cameraView.shouldWriteToSavedPhotos = YES;
    //    [self.cameraView setGetImage:^(UIImage *image){
    //
    //    }];
    [self.view addSubview:self.cameraView];
    [self createUI];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.cameraView startRunning];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.cameraView stopRunning];
}
- (void)createUI{
    
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhotoButton.frame = CGRectMake((self.view.bounds.size.width - 96) / 2, self.view.bounds.size.height - 100, 96, 96);
    [takePhotoButton addTarget:self action:@selector(takePictureNow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoButton];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 23, 46, 46)];
    imageView.image = [UIImage imageNamed:@"camera_icon.png"];
    [takePhotoButton addSubview:imageView];
    
}
- (void)takePictureNow:(UIButton *)button{
    
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return;
    }
    [self.cameraView takeAPicture];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
