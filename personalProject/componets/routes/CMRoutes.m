//
//  CMRoutes.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMRoutes.h"
#import "NSString+CMBase.h"
#import "CMRoutesObject.h"
#import "CMCommonHeader.h"
#import "SystemInfo.h"
#import "CMContext.h"
#import "JLRoutes.h"
@interface CMRoutes()
{
    NSDictionary    *__routeFilter;
}

@end

@implementation CMRoutes
+ (CMRoutes *)sharedInstance {
    static CMRoutes *routesObj = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        routesObj = [[CMRoutes alloc] init];
    });
    return routesObj;
}

- (void)handleURL:(NSString * __nullable)url
       onChecking:(void(^ __nullable)(id<CMRoutesProtocol>  __nullable obj))onCheckingBlock
      shouldRoute:(BOOL (^ __nullable )(id<CMRoutesProtocol>  __nullable obj))shouldRouteBlock
         didRoute:(void (^ __nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
           source:(CMRouteSource)source
    navController:(UINavigationController * __nullable)navCon
{
    [[CMRoutes sharedInstance] _handleURL:url
                               onChecking:onCheckingBlock
                              shouldRoute:shouldRouteBlock
                                 didRoute:didRouteBlock
                                   source:source
                            navController:navCon];
}

- (void)_handleURL:(NSString *)url
        onChecking:(void(^)(id<CMRoutesProtocol> __nullable obj))onCheckingBlock
       shouldRoute:(BOOL (^)(id<CMRoutesProtocol> __nullable obj))shouldRouteBlock
          didRoute:(void (^)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
            source:(CMRouteSource)source
     navController:(UINavigationController *)navCon
{
    //5.2版本新增  去掉url左右两边的空格
    url = [url trim];
    
    //根据url生成对象
    CMRoutesObject *obj = [[CMRoutesObject alloc] initWithURLString:url source:source];
    obj.onCheckingBlock = [onCheckingBlock copy];
    obj.shouldRouteBlock = [shouldRouteBlock copy];
    obj.didRouteBlock = [didRouteBlock copy];
    obj.navController = navCon;
    
    [self routingObject:obj];
}

- (void)routingObject:(CMRoutesObject *)obj
{
    //检查obj是否合法
    NSString *adTypeCode = obj.adTypeCode;
    if (!adTypeCode.length) {
        //adTypeCode为空，默认是未识别
        obj.adTypeCode = kRouterUnrecognizedTypeCode;
    }
    
    //根据filter跳转对应的方法
    NSString *selectorString = [[self routefilter] objectForKey:obj.adTypeCode];
    obj.isReady = YES;
    if (selectorString.length)
    {
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, CMRoutesObject*) = (void *)imp;
            func(self, selector, obj);
        }else{
            //未实现该方法，默认是不做任何事情
            [self routeDoNothing:obj];
        }
    }
    else
    {
        //未找到，默认是未识别
        [self routeUnrecognized:obj];
    }
    
    [self finalJump:obj];
    
}

- (void)finalJump:(CMRoutesObject *)obj
{
    if (!obj.isReady) {
        return;
    }
    CMContext *context = [CMContext sharedContext];
    BOOL shouldGo = obj.errorMsg.length?NO:YES; //根据error来判断是否跳转
    if (obj.shouldRouteBlock) {
        shouldGo &= obj.shouldRouteBlock(obj); //回调
    }
    
    if (shouldGo)
    {
        if (obj.doRouteBlock) {     //自定义block跳转法
            obj.doRouteBlock(obj);
        }else if (obj.targetController){
            //跳转到targetController
            //来源: 扫码，客户端原生页面,客户端内嵌web页面, 都带了导航控制器,直接push
            //部分内嵌web页，使用的是scheme,有navController，而在appdelegate里调用的则是没传navController
            if (obj.source == CMRouteSourceScan || obj.source == CMRouteSourceNativeController || obj.source == CMRouteSourceScanHistory ||obj.source == CMRouteSourceYunXinMessage || obj.source == CMRouteSourceWebController || (obj.source == CMRouteSourceOpenUrl && obj.navController)) {
                if (obj.navController) {
                    if (nil != context) {
                        //模态的购物车 不要dissmiss
                        if ([obj.adTypeCode isEqualToString:kRouterPresentRouteShopCartTypeCode]) {
                            [obj.navController pushViewController:obj.targetController animated:YES];
                        } else {
                                if (obj.bPresentModel) { //模态
                                    [obj.navController presentViewController:obj.targetController animated:YES completion:nil];
                                } else {
                                    [obj.navController pushViewController:obj.targetController animated:YES];
                                }
                            };
                        }
                    }
                }
            }
        } else if ([obj.adTypeCode isEqualToString:kRouterDoNothingTypeCode]) {
            // do nothing
        }
        else {
            
            if (nil != obj.errorMsg && obj.errorMsg.length > 0) {
                obj.adTypeCode = kRouterUnrecognizedTypeCode;
            }else {
                NSInteger index = obj.defaultTabIndex;
                if (nil != context) {
                    [context clearViewCtrlersWithCommplete:^{
                        [context switchToTapIndex:index];
                    }];
                }
            }
        }
    
    if (obj.didRouteBlock) {
        obj.didRouteBlock(obj);
    }
}

- (NSDictionary *)routefilter
{
    if (!__routeFilter) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CMRoutes" ofType:@"plist"];
        __routeFilter = [NSDictionary dictionaryWithContentsOfFile:path];
        NSAssert([__routeFilter isKindOfClass:[NSDictionary class]], @"Error Reading `SNRouter.plist` file");
    }
    return __routeFilter;
}

- (id)routeURL:(NSString *)urlString parmas:(NSDictionary *)params
{
    return [JLRoutes routeURL:[NSURL URLWithString:urlString] withParameters:params];
}

//Unrecognized
- (void)routeUnrecognized:(CMRoutesObject *)obj
{
    obj.errorMsg = @"您访问的页面不见了，请尝试在APPSTORE中检查更新后再试";
}

//DoNothing
- (void)routeDoNothing:(CMRoutesObject *)obj
{
    //do nothing
    if (!obj.adTypeCode.length) {
        obj.adTypeCode = kRouterDoNothingTypeCode;
    }
}

#pragma mark -
#pragma mark --------routes--------
//0001  cm首页
-(void)routeToCMRootTabBarViewController:(CMRoutesObject *)obj{
    UIViewController *vc = [self routeURL:kCMRootTabBarVC parmas:nil];
    obj.targetController = vc;
}

//0002  测试的secondVC
-(void)routeToSecondVC:(CMRoutesObject *)obj{
    UIViewController *vc = [self routeURL:ksecondPageVC parmas:nil];
    obj.targetController = vc;
}
@end
