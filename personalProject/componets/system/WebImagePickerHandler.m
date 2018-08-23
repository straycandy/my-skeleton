//
//  WebImagePickerHandler.m
//  SuningEBuy
//
//  Created by wangbin on 16/1/19.
//  Copyright © 2016年 苏宁易购. All rights reserved.
//

#import "WebImagePickerHandler.h"
#import <UIKit/UIKit.h>
#import "CMCommomViewController.h"

//#import "DefineConstant.h"
//#import "ZYQAssetPickerController.h"
//#import "WebViewPictureUploadRequest.h"
//#import "UIImage-Extensions.h"

@interface WebImagePickerHandler ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//@property(nonatomic, assign) CMCommomViewController *controller;
@property(nonatomic, copy) NSString *pictureUrl;
@property(nonatomic, assign) BOOL multiplePictures;
@property(nonatomic, copy) WebImagePickerCancelBlock cancelBlock;
@property(nonatomic, copy) WebImagePickerDidPickImageBlock didPickImageBlock;
//@property (nonatomic, strong) WebViewPictureUploadRequest      *uploadService;

@end

@implementation WebImagePickerHandler

static WebImagePickerHandler *handler = nil;

/**
 *  从相册选取图片
 *
 *  @param controller
 *  @param pictureUrl        图片url地址
 *  @param multiplePictures  是否多张图片
 *  @param cancelBlock       取消block
 *  @param didPickImageBlock 选中block
 */
+ (void)pickImageInController:(CMCommomViewController *)controller
                   pictureUrl:(NSString *)pictureUrl
             multiplePictures:(BOOL)multiplePictures
                  cancelBlock:(WebImagePickerCancelBlock)cancelBlock
            didPickImageBlock:(WebImagePickerDidPickImageBlock)didPickImageBlock {
    @synchronized(handler) {
        if (handler == nil) {
            handler = [[WebImagePickerHandler alloc] init];
//            handler.controller = controller;
            handler.pictureUrl = pictureUrl;
            handler.multiplePictures = multiplePictures;
            handler.cancelBlock = cancelBlock;
            handler.didPickImageBlock = didPickImageBlock;
            [handler pickImage];
        }
    }
}

/**
 *  是否选择图片actionsheet
 */
- (void)pickImage {
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                       delegate:self
//                                              cancelButtonTitle:L(@"BTCancel")
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:L(@"BTTakePic"),L(@"BTSelectFromPhotoAlbum"), nil];
//
//    [sheet showInView:self.controller.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (0 == buttonIndex) {
//        // 拍照
//        UIImagePickerController *ctrler = [[UIImagePickerController alloc] init];
//        ctrler.sourceType    = UIImagePickerControllerSourceTypeCamera;
////        ctrler.allowsEditing = YES;
//        ctrler.delegate      = self;
//        [self.controller presentViewController:ctrler animated:YES completion:^{
//
//        }];
//    } else if (1 == buttonIndex) {
//        if (self.multiplePictures) {
//            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
//            picker.maximumNumberOfSelection = 5;
//            picker.assetsFilter = [ALAssetsFilter allPhotos];
//            picker.showEmptyGroups = YES;
//            picker.canSelectDifferentAlbum = YES;
//            picker.delegate = self;
//            picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//                return YES;
//            }];
//            [self.controller presentViewController:picker animated:YES completion:NULL];
//        }else {
//            // 从相册 获取
//            UIImagePickerController *ctrler = [[UIImagePickerController alloc] init];
//            ctrler.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
//            ctrler.allowsEditing = YES;
//            ctrler.delegate      = self;
//            [self.controller presentViewController:ctrler animated:YES completion:^{
//
//            }];
//        }
//    } else {
//        [self endHandler];
//    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info {
//    UIImage* editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    editedImage = [editedImage fixOrientation:editedImage];
//
//    __weak typeof(self) weakSelf = self;
//    if (IsStrEmpty(self.pictureUrl)) {
//        [picker dismissViewControllerAnimated:YES completion:^{
//
//            NSData *imgData = UIImageJPEGRepresentation(editedImage,1.0f);
//
//            if (imgData.length > (1024*1024)/4/*250k左右*/) {
//                imgData = UIImageJPEGRepresentation(editedImage,0.5f);
//            }
//
//            NSString *fileName = [[NSDate date].description stringByAppendingString:@".jpg"];
//            NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
//
//            [imgData writeToFile:filePath atomically:YES];
//
//            if (weakSelf.didPickImageBlock) {
//                weakSelf.didPickImageBlock(filePath, nil);
//            }
//            [weakSelf endHandler];
//        }];
//    } else{
//        [picker dismissViewControllerAnimated:YES completion:^{
//            NSData *imgData = UIImageJPEGRepresentation(editedImage,1.0f);
//            if (imgData.length > (1024*1024)/4/*250k左右*/) {
//                imgData = UIImageJPEGRepresentation(editedImage,0.5f);
//            }
//            float volat = imgData.length/(1024*1024*2);
//            //压缩到2m以内
//            if (volat>1) {
//                imgData = UIImageJPEGRepresentation(editedImage,(1024*1024*2)/imgData.length);
//            }
//
//            NSString *fileName = [[NSDate date].description stringByAppendingString:@".jpg"];
//            NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
//
//            [imgData writeToFile:filePath atomically:YES];
//
//            if ([weakSelf.controller respondsToSelector:@selector(displayOverFlowActivityView)]) {
//                [weakSelf.controller performSelector:@selector(displayOverFlowActivityView) withObject:nil];
//            }
//            weakSelf.uploadService = [[WebViewPictureUploadRequest alloc] init];
//            [weakSelf.uploadService beginUploadImage:weakSelf.pictureUrl uploadImages:[NSArray arrayWithObject:filePath] block:^(NSString *url, NSString *error) {
//                if ([weakSelf.controller respondsToSelector:@selector(removeOverFlowActivityView)]) {
//                    [weakSelf.controller performSelector:@selector(removeOverFlowActivityView) withObject:nil];
//                }
//
//                if (weakSelf.didPickImageBlock) {
//                    weakSelf.didPickImageBlock(nil, url);
//                }
//                [weakSelf endHandler];
//            }];
//        }];
//    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self endHandler];
    }];
}

#pragma mark ZYQAssetPickerControllerDelegate
//多张图片
//- (void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @autoreleasepool {
//            NSMutableArray *newImagePaths = [NSMutableArray array];
//            for (int i=0; i<assets.count; i++) {
//                ALAsset *asset=assets[i];
//                UIImage *tempImg = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//                tempImg = [tempImg fixOrientation:tempImg];
//                NSString* file = [self writeTempImage:tempImg name:asset.defaultRepresentation.filename];
//                [newImagePaths addObject:file];
//            }
//
//            __weak typeof(self) weakSelf = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([weakSelf.controller respondsToSelector:@selector(displayOverFlowActivityView)]) {
//                    [weakSelf.controller performSelector:@selector(displayOverFlowActivityView) withObject:nil];
//                }
//                self.uploadService = [[WebViewPictureUploadRequest alloc] init];
//                [weakSelf.uploadService beginUploadImage:weakSelf.pictureUrl uploadImages:newImagePaths block:^(NSString *url, NSString *error) {
//                    if ([weakSelf.controller respondsToSelector:@selector(removeOverFlowActivityView)]) {
//                        [weakSelf.controller performSelector:@selector(removeOverFlowActivityView) withObject:nil];
//                    }
//
//                    if (weakSelf.didPickImageBlock) {
//                        weakSelf.didPickImageBlock(nil, url);
//                    }
//                    [weakSelf endHandler];
//                }];
//            });
//        }
//    });
//}

/**
 *  保存图片到本地
 *
 *  @param image 图片
 *  @param name  名称
 *
 *  @return 图片文件路径
 */
- (NSString*)writeTempImage:(UIImage*)image name:(NSString*)name {
    NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%@",((int)CFAbsoluteTimeGetCurrent() ),name]];
    [UIImageJPEGRepresentation(image, .5) writeToFile:file atomically:YES];
    return file;
}

//-(void)assetPickerControllerDidCancel:(ZYQAssetPickerController *)picker {
//    if (self.cancelBlock) {
//        self.cancelBlock();
//    }
//    [self endHandler];
//}

/**
 *  结束处理
 */
- (void)endHandler {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        handler = nil;
    });
}

@end
