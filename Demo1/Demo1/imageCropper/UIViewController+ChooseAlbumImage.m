//
//  UIViewController+ChooseAlbumImage.m
//  横屏裁剪图片
//
//  Created by zt on 14-3-6.
//  Copyright (c) 2014年 zt. All rights reserved.
//

#import "UIViewController+ChooseAlbumImage.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface UIViewController()

@end

@implementation UIViewController (ChooseAlbumImage)
- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller{
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (controller == nil)){
        return NO;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    //[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    
    [controller presentViewController:mediaUI animated:NO completion:nil];
    return YES;
}

- (void)albumImageChoosed:(UIImage*)img{
    //controller must overwrite this function,必须覆盖方法
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:NO completion:^{
        [self albumImageChoosed:image];
    }];
}
@end
