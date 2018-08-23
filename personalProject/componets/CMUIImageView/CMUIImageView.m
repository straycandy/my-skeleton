//
//  CMUIImageView.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMUIImageView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

void CMLoadImage(NSString *urlStr, void(^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL), void(^completion)(UIImage *image))
{
    NSURL *url;
    if ([urlStr isKindOfClass:[NSString class]] && ![urlStr isEqualToString:@""])
    {
        url = [NSURL URLWithString:urlStr];
    }
    else if ([urlStr isKindOfClass:[NSURL class]] && ![[(NSURL *)urlStr absoluteString] isEqualToString:@""]){
        url = (NSURL *)urlStr;
    }else{
        return;
    }
    
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageContinueInBackground progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        completion(image);
    }];
}

void CMLoadImages(NSArray *urlStrArray, void(^completion)(NSArray *imagesArray)){
    if (urlStrArray.count == 0) {
        completion([NSArray array]);
    }
    NSMutableArray *mutArray = [[NSMutableArray alloc]initWithCapacity:urlStrArray.count];
    for (NSInteger i = 0;i < urlStrArray.count;i++) {
        NSString *urlStr = [urlStrArray objectAtIndex:i];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageRetryFailed|SDWebImageContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                if (mutArray.count > i) {
                    [mutArray insertObject:image atIndex:i];
                }else{
                    [mutArray addObject:image];
                }
            }else{
                [mutArray insertObject:[UIImage imageNamed:@""] atIndex:i];
            }
            if (mutArray.count == urlStrArray.count) {
                completion([NSArray arrayWithArray:mutArray]);
            }
        }];
        
    }
    
}

@interface CMUIImageView()

@end
@implementation CMUIImageView

-(instancetype)init{
    if (self = [super init]) {
        self.placeholderImage = [UIImage imageNamed:@"CM_PlaceholderImage"];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGest)];
        [self addGestureRecognizer:tapGest];
    }
    return self;
}

-(void)tapGest{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)setImageURL:(NSString *)imageURL
{
    //容错处理，如果以//:开头，默认加上https by chupeng 2016.12.13,客户端4.8.0版本
    if ([imageURL hasPrefix:@"//"])
    {
        NSString *urlStr = imageURL;
        imageURL = [NSString stringWithFormat:@"http:%@", urlStr];
    }
    [self sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
}

@end
