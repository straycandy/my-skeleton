//
//  UIView+CMToast.m
//  SuningEBuy
//
//  Created by xzoscar on 15/11/18.
//  Copyright © 2015年 苏宁易购. All rights reserved.
//

#import "UIView+CMToast.h"
#import "CMToast.h"

@implementation UIView (CMToast)

/*
 * toast in this view
 * @xzoscar
 */
- (void)toast:(NSString *)toastString {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CMToast toast:toastString view:self];
    });
    
}

/*
 * hide Toast
 * You do not need call this function!
 * @xzoscar
 */
- (void)hideToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CMToast hideToast];
    });
}

@end
