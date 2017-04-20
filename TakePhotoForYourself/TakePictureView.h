//
//  TakePictureView.h
//  定义相机获取需要部分
//
//  Created by zqy on 2017/4/18.
//  Copyright © 2017年 zqy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePictureView : UIView

// 获取拍照后的图片
@property (nonatomic, copy) void (^getImage)(UIImage *image);

// 是否写入本地
@property (nonatomic, assign) BOOL shouldWriteToSavedPhotos;


- (void)startRunning;
- (void)stopRunning;

// 拍照
- (void)takeAPicture;

// 切换前后镜头
- (void)setFrontOrBackFacingCamera:(BOOL)isUsingFrontFacingCamera;

// 写入本地
- (void)writeToSavedPhotos;


@end
