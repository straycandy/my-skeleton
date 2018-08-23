//
//  CMToast.h
//  SuningEBuy
//
//  Created by xzoscar on 15/11/16.
//  Copyright © 2015年 苏宁易购. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMToast : NSObject

/*
 * toast on top window
 * @xzoscar
 */

+ (void)toast:(NSString *)toastString;

/*
 * toast on top 'fromView'
 * @xzoscar
 */

+ (void)toast:(NSString *)toastString view:(UIView *)fromView;

/*
 * toast on top window
 * @xzoscar
 */
+ (void)toastSuccess:(NSString *)toastString;

/*
 * toast on top 'fromView'
 * @xzoscar
 */

+ (void)toastSuccess:(NSString *)toastString view:(UIView *)fromView;

/*
 * hide Toast
 * You do not need call this function!
 * @xzoscar
 */
+ (void)hideToast;

@end
