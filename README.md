ImageScaleCropping
==================

ios 从相册选择图片，按照比例(3:2)裁剪图片

截图:
-----------
[!截图1](https://raw.githubusercontent.com/justzt/ImageScaleCropping/master/screenShot1.png)
[!截图2](https://raw.githubusercontent.com/justzt/ImageScaleCropping/master/screenShot2.png)
如何使用：
-----------

1.开始

    CroppingController *cropVC = [[CroppingController alloc] initWithCompleteBlock:^(UIImage *img) {
          //TODO. 处理图片
    }];
    [self.navigationController pushViewController:cropVC animated:NO];
    
2.修改裁剪图片的比例,在`CroppingController.m`中修改:
    
    CGFloat cropWithd = 300;
    CGFloat cropHeight = 200;
    
