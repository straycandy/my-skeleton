//
//  UIView+CMToast.h
//  SuningEBuy
//
//  Created by xzoscar on 15/11/18.
//  Copyright © 2015年 苏宁易购. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CMToast)

/*
 * toast in this view
 * @xzoscar
 */

- (void)toast:(NSString *)toastString;

/*
 * hide Toast
 * You do not need call this function!
 * @xzoscar
 */
- (void)hideToast;

@end
