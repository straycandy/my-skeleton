//
//  CMSharedManage.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMSharedManage.h"
#import "CMRootTabBarViewModel.h"
#import "CMRoutes.h"
#import "CMContext.h"

static  NSString * const st_tabBarInfo = @"CM_TabBarInfo.plist";
static  NSString * const st_bottomIconBackgroundImageURLStr = @"CM_bottomIconBackgroundImageURLStr.plist";


void routerToTargetURL(NSString * targetURL) {
    CMRoutes *route = [CMRoutes sharedInstance];
    [route  handleURL:targetURL
             onChecking:nil
            shouldRoute:^BOOL(id<CMRoutesProtocol> obj) {
                if (obj.errorMsg) {
                    return NO;
                }else{
                    obj.navController = [CMSharedManage selectedNavi];
                    return YES;
                }
            }
               didRoute:nil
                 source:CMRouteSourceNativeController
          navController:[CMSharedManage selectedNavi]];
}
@interface CMSharedManage()
/**
 底部tabBar数据,strong,只会有一个
 */
@property (nonatomic, strong) NSArray           *tabBarInfoArray;
@end

@implementation CMSharedManage
+ (CMSharedManage *)shared {
    static dispatch_once_t once;
    static CMSharedManage *_obj = nil;
    dispatch_once(&once, ^{
        _obj = [[CMSharedManage alloc] init];
    });
    return _obj;
}

+ (UINavigationController *)selectedNavi {
    CMContext *context = [CMContext sharedContext];
    return [context selected];
}

#pragma mark -
#pragma mark --------DataManage--------
-(NSString *)filePathWithStr:(NSString *)str{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:str];
}

- (NSArray *)getTabBarInfoArray{
    if (!_tabBarInfoArray) {
        //获取路径
        NSString *path = [self filePathWithStr:st_tabBarInfo];
        //从路径中取
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!array || array.count < 4) {
            //本地无数据，获取默认的
            array = [CMRootTabBarViewModel getInitialTabBarInfo];
        }
        _tabBarInfoArray = array;
    }
    return _tabBarInfoArray;
}
@end
