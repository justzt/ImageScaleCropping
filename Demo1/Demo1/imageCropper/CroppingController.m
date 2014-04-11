//
//  CroppingController.m
//  MyCropping
//
//  Created by zt on 14-4-9.
//  Copyright (c) 2014年 zt. All rights reserved.
//

#import "CroppingController.h"
#import "UIViewController+ChooseAlbumImage.h"

#define ImageWithName(name)  ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]])

@interface CroppingController (){
    __block void(^cropCompleteBlock)(UIImage*img);
    UIView *contentView;
    CGFloat imageScale;//default zoomscale
    UIImage *originImage;
    UIImageView *originImageView;//原图view
    UIImageView *reviewImageView;//预览view
    CGRect originImageViewFrame;//默认的图片frame
    UIImageView *dashedBoxView;//裁剪框
    UIImageView *errView;//选择竖屏图片的时候错误提示
    UIButton *confirmButton;//确定按钮
    UIButton *cancelButton;//取消裁剪
}

@end

@implementation CroppingController

- (void)dealloc{
    contentView = nil;
    originImage = nil;
    originImageView = nil;
    dashedBoxView = nil;
}

- (id)initWithCompleteBlock:(void (^)(UIImage *img))block{
    self = [super init];
    if (self) {
        cropCompleteBlock = block;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // 从相册选图片
    [self startMediaBrowserFromViewController:self];
}

// 图片选择后准备工作
- (void)albumImageChoosed:(UIImage*)img{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // 非横屏照片不处理，提示错误
    if (img.size.width < img.size.height) {
        [self portraitImageCase];
        return;
    }
    
    switch (img.imageOrientation) {
        case UIImageOrientationLeft:{//90 deg CCW
            img = [self image:img rotatedByDegrees:-90];
            img = [self scaleImage:img toSize:CGSizeMake(img.size.height, img.size.width)];
            break;
        }
        case UIImageOrientationRight:{//90 deg CW
            img = [self image:img rotatedByDegrees:90];
            img = [self scaleImage:img toSize:CGSizeMake(img.size.height, img.size.width)];
            break;
        }
        case UIImageOrientationDown:{// 180 deg rotation
            // 180 deg rotation
            img = [self image:img rotatedByDegrees:180];
            break;
        }
        default:
            break;
    }
    // 原图片
    originImage = img;//[UIImage imageNamed:@"test.jpg"];
    NSLog(@"image size:%@",[NSValue valueWithCGSize:originImage.size]);
    
    // 所有ui的容器
    contentView = [[UIView alloc] init];
    contentView.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    contentView.frame = self.view.bounds;
    contentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:contentView];

    
    originImageView = [[UIImageView alloc] init];
    originImageView.image = originImage;
    originImageView.clipsToBounds = NO;
    originImageView.userInteractionEnabled = YES;
    imageScale = contentView.frame.size.height/originImage.size.height;
    originImageView.frame = CGRectMake(0, 0, originImage.size.width*imageScale, originImage.size.height*imageScale);
    originImageView.center = CGPointMake(contentView.frame.size.height/2.0, contentView.frame.size.width/2.0);
    [contentView addSubview:originImageView];
    [self addUserGustrue];
    originImageViewFrame = originImageView.frame;
    
    // 虚线框
    CGFloat cropWithd = 300;
    CGFloat cropHeight = 200;
    dashedBoxView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cropWithd, cropHeight)];
    dashedBoxView.userInteractionEnabled = NO;
    dashedBoxView.image = ImageWithName(@"caijian_bg@2x");
    dashedBoxView.center = originImageView.center;
    
    // 预览view
    reviewImageView = [[UIImageView alloc] initWithFrame:dashedBoxView.frame];
    reviewImageView.userInteractionEnabled = NO;
    [contentView addSubview:reviewImageView];
    [contentView addSubview:dashedBoxView];
    
    // 确定按钮
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.hidden = YES;
    confirmButton.frame = CGRectMake(CGRectGetHeight(contentView.frame)-65, (320-72)/2, 65, 72);
    [confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setImage:ImageWithName(@"caijian_queding@2x") forState:UIControlStateNormal];
    [contentView addSubview:confirmButton];

    // 裁剪按钮
    UIButton *cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cropButton.frame = CGRectMake(CGRectGetMinX(dashedBoxView.frame)-25, CGRectGetMaxY(dashedBoxView.frame)-25, 50, 50);
    [cropButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [cropButton setImage:ImageWithName(@"caijian_caijian@2x") forState:UIControlStateNormal];
    [contentView addSubview:cropButton];
    
    // 取消按钮
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.hidden = YES;
    cancelButton.frame = CGRectMake(CGRectGetMinX(cropButton.frame)-60, CGRectGetMinY(cropButton.frame), 50, 50);
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:ImageWithName(@"caijian_guanbi@2x") forState:UIControlStateNormal];
    [contentView addSubview:cancelButton];
    
    // 返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 51, 63);
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:ImageWithName(@"caijian_fanhui@2x") forState:UIControlStateNormal];
    [contentView addSubview:backButton];
    
    [self addUserGustrue];
}

// 照片竖屏处理
- (void)portraitImageCase{
    UIImage *image = [UIImage imageNamed:@"xiangce_tishi"];
    UIEdgeInsets edge = UIEdgeInsetsMake(1, 160, image.size.height-2, 159);
    image = [image resizableImageWithCapInsets:edge];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.image = image;
    imgView.backgroundColor = [UIColor blackColor];
    imgView.userInteractionEnabled = YES;
    [self.view addSubview:imgView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonAction)];
    [tapGesture setNumberOfTapsRequired:1];
    [imgView addGestureRecognizer:tapGesture];
}

// 添加手势
- (void)addUserGustrue{
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    [originImageView addGestureRecognizer:scaleGes];
    
    
    UIPanGestureRecognizer *moveGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
    [moveGes setMinimumNumberOfTouches:1];
    [moveGes setMaximumNumberOfTouches:1];
    [originImageView addGestureRecognizer:moveGes];
}

// 取消裁剪
- (void) cancelButtonAction{
    // 显示裁剪结果
    reviewImageView.image = nil;
    // 隐藏原图
    originImageView.hidden = NO;
    // 置空裁剪结果
    self.croppedImage = nil;
    // 隐藏确定按钮
    confirmButton.hidden = YES;
    // 隐藏取消按钮
    cancelButton.hidden = YES;
}

// 返回
- (void)backButtonAction{
    [self.navigationController  popViewControllerAnimated:YES];
}

// 确定按钮
- (void)confirmButtonAction{
    //回调
    if (self.croppedImage != nil) {
        cropCompleteBlock(self.croppedImage);
    }

    [self backButtonAction];
}

// 裁剪
- (void)buttonAction{
    float zoomScale = originImageView.frame.size.height/originImage.size.height;
    CGFloat originX = dashedBoxView.frame.origin.x-originImageView.frame.origin.x;
    CGFloat originY = dashedBoxView.frame.origin.y-originImageView.frame.origin.y;
    CGSize cropSize = CGSizeMake(dashedBoxView.frame.size.width/zoomScale, dashedBoxView.frame.size.height/zoomScale);
    
    
    CGRect cropRect = CGRectMake(originX/zoomScale, originY/zoomScale, cropSize.width, cropSize.height);
    NSLog(@"originX:%lf originY:%lf,corpRect:%@",originX,originY,[NSValue valueWithCGRect:cropRect]);
    
    CGImageRef tmp = CGImageCreateWithImageInRect([originImage CGImage], cropRect);
    self.croppedImage = [UIImage imageWithCGImage:tmp scale:originImage.scale orientation:originImage.imageOrientation];
    NSLog(@"image size:%@",[NSValue valueWithCGSize:self.croppedImage.size]);
    if (self.croppedImage.size.width > 720) {
        self.croppedImage = [self scaleImage:self.croppedImage toSize:CGSizeMake(720, 480)];
    }
    
    // 显示裁剪结果
    reviewImageView.image = self.croppedImage;
    // 隐藏原图
    originImageView.hidden = YES;
    // 显示确定按钮
    confirmButton.hidden = NO;
    // 显示取消按钮
    cancelButton.hidden = NO;
}

// 处理缩放
float _lastScale = 1.0;
- (void)scaleImage:(UIPinchGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
        return;
    }
    
    
    CGFloat scale = [sender scale]/_lastScale;
    
    if([sender state] == UIGestureRecognizerStateEnded) {
        // 裁剪框必须在图片内部
        if (![self dashebBoxInsideOriginImageView]) {
            return;
        }
    }
    
    CGAffineTransform currentTransform = originImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [originImageView setTransform:newTransform];
    
    
    _lastScale = [sender scale];
}

// 处理移动
float _lastTransX = 0.0, _lastTransY = 0.0;
- (void)moveImage:(UIPanGestureRecognizer *)sender
{
    CGPoint translatedPoint = [sender translationInView:contentView];
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        _lastTransX = 0.0;
        _lastTransY = 0.0;
    }
    
    if([sender state] == UIGestureRecognizerStateEnded) {
        if (![self dashebBoxInsideOriginImageView]) {
            return;
        }
    }
    
    CGAffineTransform trans = CGAffineTransformMakeTranslation(translatedPoint.x - _lastTransX, translatedPoint.y - _lastTransY);
    CGAffineTransform newTransform = CGAffineTransformConcat(originImageView.transform, trans);
    _lastTransX = translatedPoint.x;
    _lastTransY = translatedPoint.y;
    
    originImageView.transform = newTransform;
}


// 检查裁剪框是否还在图片矩形内部，不在还原
- (BOOL)dashebBoxInsideOriginImageView{
    if(!CGRectContainsRect(originImageView.frame, dashedBoxView.frame)){
        [self recoverOriginImageviewStatus];
        return NO;
    }
    return YES;
}

// 恢复originImageview的默认状态
- (void)recoverOriginImageviewStatus{
    [UIView animateWithDuration:0.3
                     animations:^{
                         originImageView.frame = originImageViewFrame;
                     }
                     completion:^(BOOL finished){}];
}

#pragma mark - Navigationbar delegate
- (void)navgationBar:(id)bar leftButtonAction:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - CroppingController private
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

- (UIImage *)image:(UIImage*)image rotatedByRadians:(CGFloat)radians{
    return [self image:image rotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)image:(UIImage*)image rotatedByDegrees:(CGFloat)degrees{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}

//等比例缩放
-(UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end


