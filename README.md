---
title: 自定义相机，截取需要的部分存储到相册
tags:
---
最近有个需求需要在拍照时截取线框的部分存储在相册，就写了个demo。
这是相框的位置设定

    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((width - width * 3 / 4) / 2, height * 0.3, width * 3 / 4 , width * 3 / 12)];
    imageV.clipsToBounds = YES;
    imageV.layer.borderColor = [UIColor whiteColor].CGColor;
    imageV.layer.borderWidth = 0.5;
    [self addSubview:imageV];

按说截取的frame要和这个frame一致，但是后面把image放到屏幕为了清晰度用的是 **     UIGraphicsBeginImageContextWithOptions(size,YES,[UIScreen mainScreen].scale);** 而不是**    UIGraphicsBeginImageContext(size);** 所以截取位置的frame **_imageRect**就要用相应的

        CGFloat height2 = height * [UIScreen mainScreen].scale;CGFloat width2 = width * [UIScreen mainScreen].scale;_imageRect = CGRectMake((width2 - width2 * 3 / 4) / 2, height2 * 0.3, width2 * 3 / 4 , width2 * 3 / 12);
