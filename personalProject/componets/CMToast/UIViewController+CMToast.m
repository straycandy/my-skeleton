//
//  UIViewController+CMToast.m
//  SuningEBuy
//
//  Created by xzoscar on 15/11/18.
//  Copyright © 2015年 苏宁易购. All rights reserved.
//

#import "UIViewController+CMToast.h"
#import "CMToast.h"

@implementation UIViewController (CMToast)

/*
 * toast in self.view
 * @xzoscar
 */

- (void)toast:(NSString *)toastString {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CMToast toast:toastString view:self.view];
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
