//
//  UIImage+ChangeImage.h
//  定义相机获取需要部分
//
//  Created by zqy on 2017/4/18.
//  Copyright © 2017年 zqy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ChangeImage)

/**
 *将图片缩放到指定的CGSize大小
 * UIImage image 原始的图片
 * CGSize size 要缩放到的大小
 */
+(UIImage*)image:(UIImage *)image scaleToSize:(CGSize)size;


+(UIImage*)imageView:(UIImageView *)imageView scaleToSize:(CGSize)size;



/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
+(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;


+(UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;

@end
