//
//  CMTabBar.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 回调block
 */
typedef void (^CMTabBarClickBlock)(NSInteger index);
@interface CMTabBar : UITabBar
@property (nonatomic, copy) CMTabBarClickBlock          clickBlock;
/**
 路由dic，如果选中的index是其中的某个key，只需要selectindex，其他的比如设置图片高亮等操作不需要进行
 */
@property (nonatomic, strong) NSDictionary              *routeDic;

/**
 选中某个index
 
 @param index 选中的index，从0开始
 */
-(void)selectIndex:(NSInteger)index;
@end
