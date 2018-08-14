//
//  CMUIImageView.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <UIKit/UIKit.h>

//下载图片
void CMLoadImage(NSString *urlStr, void(^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL), void(^completion)(UIImage *image));

/**
 批量下载图片

 @param urlStrArray 图片urlStr的array
 按照顺序返回的image,没有则为空的图片
 */
void CMLoadImages(NSArray *urlStrArray, void(^completion)(NSArray *imagesArray));

typedef void (^CMImageViewClickBlock)(void);
@interface CMUIImageView : UIImageView
@property (nonatomic, strong) UIImage               *placeholderImage;
@property (nonatomic, copy) NSString                *imageURL;
@property (nonatomic, copy) CMImageViewClickBlock   clickBlock;


@end


