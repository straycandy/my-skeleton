//
//  UIColor+CMBase.h
//  personalProject
//
//  Created by mengran on 2018/7/30.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CMBase)
+ (UIColor *)colorWithHexString:(NSString *)hexStr;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
@end
