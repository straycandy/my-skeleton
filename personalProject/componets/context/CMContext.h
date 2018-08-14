//
//  CMContext.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXTERN UINavigationController *CMSelectedNavGet(void);// 获取当前选中的tab下NavigationController

@interface CMContext : NSObject
+ (CMContext *)sharedContext;

/*
 * 获取当前选中tab下的 root UINavigationController
 * 你应该使用 ‘CMSelectedNavGet()’
 * @xzoscar
 */
- (UINavigationController *)selected;

/*
 * 当前选中tab下的 topViewController
 * 你应该使用 'CMNavTopGet();'
 * @xzoscar
 */
- (UINavigationController *)topNavigation;

/*
 * 清除root tabBarController下 所有view controllers
 * @paras 'complete' : clear完成后会调用complete
 * @xzoscar
 */
- (void)clearViewCtrlersWithCommplete:(dispatch_block_t)complete;

/*
 * 切换到 index tab
 * @xzoscar
 */
- (void)switchToTapIndex:(NSUInteger)index;
@end
