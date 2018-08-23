//
//  UIControl+TapScope.h
//  SuningEBuy
//
//  Created by snping on 15/7/10.
//  Copyright (c) 2015年 Suning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (TapScope)

/**
 *  扩大按钮的点击范围（insets必须不超过button的superview范围,否者超出范围的不起作用）
 */
@property(nonatomic, assign) UIEdgeInsets hitEdgeInsets;

@end
