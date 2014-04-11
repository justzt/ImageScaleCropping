//
//  CroppingController.h
//  MyCropping
//
//  Created by zt on 14-4-9.
//  Copyright (c) 2014年 zt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CroppingController : UIViewController

@property (nonatomic,retain) UIImage *croppedImage;

- (id)initWithCompleteBlock:(void (^)(UIImage *img))block;
@end
