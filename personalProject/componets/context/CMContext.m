//
//  CMContext.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMContext.h"

CMContext *CMContextGet() {
    return ([CMContext sharedContext]);
}

UINavigationController *SNSelectedNavGet() {
    return ([CMContextGet() selected]);
}
@implementation CMContext
+ (CMContext *)sharedContext {
    static CMContext *context = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        context = [[CMContext alloc] init];
    });
    return context;
}

- (UITabBarController *)rootViewController {
    // [UIApplication sharedApplication].keyWindow
    UITabBarController *rootvc = (UITabBarController *)[UIApplication sharedApplication].windows.firstObject.rootViewController;
    if (nil != rootvc && [rootvc isKindOfClass:[UITabBarController class]]) {
        return rootvc;
    }
    return nil;
}

/*
 * 当前选中 index
 * @xzoscar
 */
- (UINavigationController *)selected {
    return [self rootViewController].selectedViewController;
}

/*
 * 当前选中tab下的 topViewController
 * 你应该使用 'SNNavTopGet();'
 * @xzoscar
 */
- (UINavigationController *)topNavigation {
    
    UINavigationController *nav = [self selected];
    // this is not 'return nav.topViewController.navigationController'
    return nav.visibleViewController.navigationController;
}

/*
 * 清除root tabBarController下 所有view controllers
 * @paras 'complete' : clear完成后会调用complete
 * @xzoscar
 */
- (void)clearViewCtrlersWithCommplete:(dispatch_block_t)complete {
    
    BOOL isNeedDelay = [self isNeedDelayWhenClearViewCtrlers];
    [self clearViewCtrlers];
    
    if (isNeedDelay) {
        // Unbalanced calls to begin/end appearance transitions
        // 注意，这里会有个警告、在某些系统上 甚至crash 当dismissViewController时候
        // call 'complete()' after the seconds
        double delayInSeconds = .5f;// not modify value (05f)!!!
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            complete();
        });
    }else {
        if (!( [[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending )) {
            double delayInSeconds = .5f;// not modify value (05f)!!!
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                complete();
            });
        }
        else {
            complete();
        }
        
    }
}

/*
 * 切换到 index tab
 * @xzoscar
 */
- (void)switchToTapIndex:(NSUInteger)index {
    NSInteger count = ([self rootViewController].viewControllers.count);
    if (index < count) {
        [[self rootViewController] setSelectedIndex:index];
    }
}

/*
 * Unbalanced calls to begin/end appearance transitions
 * 注意，这里会有个警告、在某些系统上 甚至crash 当dismissViewController时候
 * 解决方法:延时
 * @xzoscar
 */
- (BOOL)isNeedDelayWhenClearViewCtrlers {
    UITabBarController *vc = [self rootViewController];
    return (nil != vc.presentedViewController) ? YES : NO;
}

/*
 * 清除root tabBarController下 所有view controllers
 * @xzoscar
 */
- (void)clearViewCtrlers {
    UITabBarController *vc = [self rootViewController];
    if (vc.presentedViewController) {
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
    
    NSArray *vcs = [self rootViewController].viewControllers;
    if (nil != vcs && vcs.count > 0) {
        for (UINavigationController *vc in vcs) {
            if (nil != vc && [vc isKindOfClass:[UINavigationController class]]) {
                [vc popToRootViewControllerAnimated:NO];
            }
        }
    }
}
@end
