//
//  UIViewController+ChooseAlbumImage.h

//  从相册选择图片的辅助类
//  使用方法：在你的controller种导入h文件，调用startMediaBrowserFromViewController即可展示系统默认的图片选择器，
//  处理选择的图片需要覆盖albumImageChoosed

#import <UIKit/UIKit.h>

@interface UIViewController (ChooseAlbumImage)<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller;
- (void)albumImageChoosed:(UIImage*)img;//必须覆盖方法
@end
