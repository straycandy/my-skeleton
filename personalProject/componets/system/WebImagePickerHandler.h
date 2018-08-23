//
//  WebImagePickerHandler.h
//  SuningEBuy
//
//  Created by wangbin on 16/1/19.
//  Copyright © 2016年 苏宁易购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMCommomViewController.h"

typedef void (^WebImagePickerCancelBlock)();
typedef void (^WebImagePickerDidPickImageBlock)(NSString *filePath, NSString *url);

@interface WebImagePickerHandler : NSObject

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
             didPickImageBlock:(WebImagePickerDidPickImageBlock)didPickImageBlock;

@end
